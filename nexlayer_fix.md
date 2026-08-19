# Nexlayer working build fix

This file is the authoritative, pinned build solution for this repo. Nexlayer uses it verbatim on every run and will not override it. If a future build with this fix fails, Nexlayer appends/updates it rather than regenerating.

## Fixed Dockerfile

```dockerfile
ARG ALPINE_VERSION=3.22.2

#### Builder
FROM mirror.gcr.io/hexpm/elixir:1.19.4-erlang-27.3.4.6-alpine-${ALPINE_VERSION} AS buildcontainer

ARG MIX_ENV=ce

ENV MIX_ENV=$MIX_ENV
ENV NODE_ENV=production
ENV NODE_OPTIONS=--openssl-legacy-provider

ARG ERL_FLAGS
ENV ERL_FLAGS=$ERL_FLAGS

RUN mkdir /app
WORKDIR /app

RUN apk add --no-cache git "nodejs-current=23.11.1-r0" yarn npm python3 ca-certificates wget gnupg make gcc libc-dev brotli

COPY mix.exs ./
COPY mix.lock ./
COPY config ./config
RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix deps.get --only ${MIX_ENV} && \
  mix deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
COPY tracker/package.json tracker/package-lock.json ./tracker/

RUN npm install --prefix ./assets && \
  npm install --prefix ./tracker

COPY assets ./assets
COPY tracker ./tracker
COPY priv ./priv
COPY lib ./lib
COPY extra ./extra

RUN npm run deploy --prefix ./tracker && \
  mix assets.deploy && \
  mix phx.digest priv/static && \
  mix download_country_database && \
  mix sentry.package_source_code

WORKDIR /app
COPY rel rel
RUN mix release plausible

# Main Docker Image
FROM mirror.gcr.io/library/alpine:${ALPINE_VERSION}
LABEL maintainer="plausible.io <hello@plausible.io>"

ARG BUILD_METADATA={}
ENV BUILD_METADATA=$BUILD_METADATA
ENV LANG=C.UTF-8
ARG MIX_ENV=ce
ENV MIX_ENV=$MIX_ENV

RUN adduser -S -H -u 999 -G nogroup plausible

RUN apk upgrade --no-cache
RUN apk add --no-cache openssl ncurses libstdc++ libgcc ca-certificates \
  && if [ "$MIX_ENV" = "ce" ]; then apk add --no-cache certbot; fi

COPY --from=buildcontainer --chmod=555 /app/_build/${MIX_ENV}/rel/plausible /app
COPY --chmod=755 ./rel/docker-entrypoint.sh /entrypoint.sh

RUN mkdir -p /var/lib/plausible && chmod ugo+rw -R /var/lib/plausible

USER 999
WORKDIR /app
ENV LISTEN_IP=0.0.0.0
ENV SECRET_KEY_BASE=placeholder_secret_key_base_that_is_at_least_32_bytes_long_1234567890
ENV BASE_URL=http://localhost:8000
ENV DATABASE_URL=postgresql://plausible:plausible@postgres.pod:5432/plausible
ENV CLICKHOUSE_DATABASE_URL=http://clickhouse.pod:8123/plausible
ENV CLICKHOUSE_DATABASE=plausible
ENV CLICKHOUSE_HOST=clickhouse.pod
ENV CLICKHOUSE_PORT=8123
ENV CLICKHOUSE_USER=default
ENV CLICKHOUSE_PASSWORD=
ENV PGHOST=postgres.pod
ENV PGPORT=5432
ENV PGUSER=plausible
ENV PGPASSWORD=plausible
ENV PGDATABASE=plausible
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 8000
ENV DEFAULT_DATA_DIR=/var/lib/plausible
VOLUME /var/lib/plausible
CMD ["run"]

```

## Fixed nexlayer.yaml

```yaml
application:
  name: analytics
  pods:
    - name: app
      image: "# filled by pipeline"
      port: 8000
      env:
        - name: SECRET_KEY_BASE
          value: "<SECRET_KEY_BASE>"
        - name: BASE_URL
          value: "<% URL %>"
        - name: DATABASE_URL
          value: "postgresql://plausible:plausible@postgres.pod:5432/plausible"
        - name: CLICKHOUSE_DATABASE_URL
          value: "http://clickhouse.pod:8123"
    - name: postgres
      image: mirror.gcr.io/library/postgres:16-alpine
      port: 5432
      env:
        - name: POSTGRES_USER
          value: plausible
        - name: POSTGRES_PASSWORD
          value: plausible
        - name: POSTGRES_DB
          value: plausible
    - name: clickhouse
      image: clickhouse/clickhouse-server:latest
      port: 8123

```
