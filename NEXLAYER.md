# Nexlayer — analytics

<!-- nexlayer:meta version=1 analyzed=2026-08-20T17:23:53Z repo=https://github.com/KatieHarris2397/analytics branch=master -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
Plausible Analytics is an open-source, privacy-first web analytics platform that provides a lightweight, cookie-free alternative to Google Analytics. It offers GDPR/CCPA/PECR-compliant website traffic measurement with a simple dashboard, built on Elixir/Phoenix with a ClickHouse-based ingestion pipeline.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Elixir | language | ~> 1.18 | mix.exs |
| Phoenix | framework | 1.7 | mix.exs |
| Erlang/OTP | language | 27.3.4.6 | Dockerfile |
| Node.js | language | 23.11.1 | Dockerfile |
| PostgreSQL | database | 16 | config/runtime.exs |
| ClickHouse | database | latest | config/config.exs |
| Redis | cache | 7 | config/runtime.exs |
| Tailwind CSS | framework | 4.1.12 | config/config.exs |
| esbuild | build | 0.17.11 | config/config.exs |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- lib/ — Elixir application source (Phoenix app, ingestion, analytics)
- assets/ — Frontend assets (JS, CSS, dashboard)
- tracker/ — Lightweight tracking script
- priv/ — Static assets, database migrations, country database
- config/ — Environment configuration files
- rel/ — Release configuration and entrypoint scripts
- extra/ — Additional modules for enterprise edition
- test/ — Test suite
- e2e/ — End-to-end tests
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- Sentry (error tracking)
- Postmark (email delivery)
- Paddle (billing API)
- Google API (for Google Analytics import)
- MaxMind GeoIP (country database)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Elixir >= 1.18
- Erlang/OTP >= 27
- Node.js >= 23
- PostgreSQL >= 16
- ClickHouse
- Redis

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
BASE_URL=http://localhost:8000
SECRET_KEY_BASE=your-secret-key
DATABASE_URL=postgresql://localhost:5432/plausible
CLICKHOUSE_DATABASE_URL=http://localhost:8123/plausible
REDIS_URL=redis://localhost:6379
HTTP_PORT=8000
```

### Steps

1. `mix deps.get` — Install Elixir dependencies
2. `npm install --prefix assets && npm install --prefix tracker` — Install frontend dependencies
3. `mix ecto.create && mix ecto.migrate` — Create and migrate PostgreSQL database
4. `mix run --no-halt` — Start development server on http://localhost:8000

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `app` | `BASE_URL` | `"https://<% URL %>"` | plain |
| `app` | `SECRET_KEY_BASE` | `"${SECRET_KEY_BASE}"` | inter-pod |
| `app` | `DATABASE_URL` | `"postgresql://app:${POSTGRES_PASSWORD}@postgres.pod:5432/app"` | inter-pod |
| `app` | `CLICKHOUSE_DATABASE_URL` | `"http://clickhouse.pod:8123/plausible"` | plain |
| `app` | `LISTEN_IP` | `"0.0.0.0"` | plain |
| `app` | `HTTP_PORT` | `"8000"` | plain |
| `app` | `MIX_ENV` | `"ce"` | plain |
| `postgres` | `POSTGRES_USER` | `"app"` | plain |
| `postgres` | `POSTGRES_PASSWORD` | `"${POSTGRES_PASSWORD}"` | inter-pod |
| `postgres` | `POSTGRES_DB` | `"app"` | plain |
| `analytics-postgres-data` | `size` | `10Gi` | plain |
| `analytics-postgres-data` | `mountPath` | `/var/lib/postgresql` | plain |
| `clickhouse` | `CLICKHOUSE_DB` | `plausible` | plain |
| `analytics-clickhouse-data` | `size` | `10Gi` | plain |
| `analytics-clickhouse-data` | `mountPath` | `/var/lib/clickhouse` | plain |

### nexlayer.yaml

```yaml
application:
  name: analytics
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01krc1n44dd49btzyv6vht92v2/analytics:1a02031b8e3"
      path: /
      servicePorts:
        - 8000
      vars:
        BASE_URL: "https://<% URL %>"
        SECRET_KEY_BASE: "${SECRET_KEY_BASE}"
        DATABASE_URL: "postgresql://app:${POSTGRES_PASSWORD}@postgres.pod:5432/app"
        CLICKHOUSE_DATABASE_URL: "http://clickhouse.pod:8123/plausible"
        LISTEN_IP: "0.0.0.0"
        HTTP_PORT: "8000"
        MIX_ENV: "ce"
    - name: postgres
      image: mirror.gcr.io/library/postgres:16-alpine
      servicePorts:
        - 5432
      vars:
        POSTGRES_USER: "app"
        POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"
        POSTGRES_DB: "app"
      volumes:
        - name: analytics-postgres-data
          size: 10Gi
          mountPath: /var/lib/postgresql
    - name: clickhouse
      image: mirror.gcr.io/library/clickhouse/clickhouse-server:24.8-alpine
      servicePorts:
        - 8123
      vars:
        CLICKHOUSE_DB: plausible
      volumes:
        - name: analytics-clickhouse-data
          size: 10Gi
          mountPath: /var/lib/clickhouse
```

<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| web | mirror.gcr.io/library/elixir:1.19.4-erlang-27.3.4.6-alpine-3.22.2 | 8000 | web |
| db | mirror.gcr.io/library/postgres:16-alpine | 5432 | database |
| clickhouse | mirror.gcr.io/library/clickhouse/clickhouse-server:latest | 8123 | database |
| redis | mirror.gcr.io/library/redis:7-alpine | 6379 | cache |

### Deployment notes

- Web pod connects to PostgreSQL via db.pod:5432 (the <podName>.pod:<port> form)
- Web pod connects to ClickHouse via clickhouse.pod:8123
- Web pod connects to Redis via redis.pod:6379
- All database services are separate pods per Nexlayer rules
- The web pod runs the Phoenix server and handles all HTTP traffic
- ClickHouse is used for analytics event storage and querying
- Redis is used for caching and session storage
- The tracker script is served from the web pod at /js/script.js

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-08-20T17:31:14Z  
**Live URL:** https://xenial-tern-analytics.qa.cluster.vibeship.work  
**Runtime:** node · **Port:** 8000  
**Deploy branch:** master  

```yaml
application:
  name: analytics
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01krc1n44dd49btzyv6vht92v2/analytics:1a02031b8e3"
      path: /
      servicePorts:
        - 8000
      vars:
        BASE_URL: "https://<% URL %>"
        SECRET_KEY_BASE: "${SECRET_KEY_BASE}"
        DATABASE_URL: "postgresql://app:${POSTGRES_PASSWORD}@postgres.pod:5432/app"
        CLICKHOUSE_DATABASE_URL: "http://clickhouse.pod:8123/plausible"
        LISTEN_IP: "0.0.0.0"
        HTTP_PORT: "8000"
        MIX_ENV: "ce"
    - name: postgres
      image: mirror.gcr.io/library/postgres:16-alpine
      servicePorts:
        - 5432
      vars:
        POSTGRES_USER: "app"
        POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"
        POSTGRES_DB: "app"
      volumes:
        - name: analytics-postgres-data
          size: 10Gi
          mountPath: /var/lib/postgresql
    - name: clickhouse
      image: mirror.gcr.io/library/clickhouse/clickhouse-server:24.8-alpine
      servicePorts:
        - 8123
      vars:
        CLICKHOUSE_DB: plausible
      volumes:
        - name: analytics-clickhouse-data
          size: 10Gi
          mountPath: /var/lib/clickhouse
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-08-20T17:23:53Z | analyzed | initial repo analysis |
| 2026-08-20T17:31:14Z | success | deployed https://xenial-tern-analytics.qa.cluster.vibeship.work |
<!-- nexlayer:end -->
