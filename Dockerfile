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
ENV SECRET_KEY_BASE=placeholder_secret_key_base_32_bytes_minimum_1234567890
ENV BASE_URL=http://localhost:8000
ENV DATABASE_URL=postgresql://postgres:postgres@postgres.pod:5432/plausible
ENV CLICKHOUSE_DATABASE_URL=http://clickhouse.pod:8123/plausible
ENV REDIS_URL=redis://redis.pod:6379
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 8000
ENV DEFAULT_DATA_DIR=/var/lib/plausible
VOLUME /var/lib/plausible
CMD ["run"]
