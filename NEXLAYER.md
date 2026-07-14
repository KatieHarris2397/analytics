# Nexlayer — analytics

<!-- nexlayer:meta version=1 analyzed=2026-07-14T21:22:56Z repo=https://github.com/KatieHarris2397/analytics branch=master -->

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
Plausible Analytics is a privacy-first, open-source web analytics tool designed as a lightweight, cookie-free alternative to Google Analytics.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Elixir | language | 1.19.4 | Dockerfile |
| Phoenix | framework | latest | Dockerfile, mix.exs |
| Erlang | language | 27.3.4.6 | Dockerfile |
| Node.js | language | 23.11.1 | Dockerfile |
| PostgreSQL | database | latest | README.md |
| ClickHouse | database | latest | README.md |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- lib/ — Core Elixir/Phoenix business logic and controllers
- assets/ — Frontend static assets and CSS
- tracker/ — JS tracking script source
- priv/ — Static files and database migrations
- config/ — Application environment configuration
- rel/ — Release and deployment scripts
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- Sentry (SENTRY_DSN)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Elixir 1.19+
- Erlang 27+
- Node.js 23+
- PostgreSQL
- ClickHouse

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/plausible
CLICKHOUSE_URL=http://localhost:8123
SECRET_KEY_BASE=generated_secret_key
```

### Steps

1. `mix deps.get` — Install Elixir dependencies
2. `npm install --prefix assets` — Install frontend dependencies
3. `mix ecto.setup` — Run migrations and seed the database
4. `mix phx.server` — Start the Phoenix server on http://localhost:4000

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `app` | `NODE_ENV` | `"production"` | plain |
| `app` | `PORT` | `"8000"` | plain |
| `app` | `HOSTNAME` | `"0.0.0.0"` | plain |
| `app` | `DATABASE_URL` | `"postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres.pod:5432/app"` | inter-pod |
| `app` | `REDIS_URL` | `"redis://redis.pod:6379"` | plain |
| `app` | `SECRET_KEY_BASE` | `"${SECRET_KEY_BASE}"` | inter-pod |
| `postgres` | `POSTGRES_USER` | `"app"` | plain |
| `postgres` | `POSTGRES_PASSWORD` | `${POSTGRES_PASSWORD}` | inter-pod |
| `postgres` | `POSTGRES_DB` | `"app"` | plain |
| `analytics-postgres-data` | `size` | `10Gi` | plain |
| `analytics-postgres-data` | `mountPath` | `/var/lib/postgresql/data` | plain |

### nexlayer.yaml

```yaml
application:
  name: analytics
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kna6j8vrcfj9q0wjtq5qsq3n/analytics:19f62827419"
      path: /
      servicePorts:
        - 8000
      vars:
        NODE_ENV: "production"
        PORT: "8000"
        HOSTNAME: "0.0.0.0"
        DATABASE_URL: "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres.pod:5432/app"
        REDIS_URL: "redis://redis.pod:6379"
        SECRET_KEY_BASE: "${SECRET_KEY_BASE}"
    - name: postgres
      image: mirror.gcr.io/library/postgres:16-alpine
      servicePorts:
        - 5432
      vars:
        POSTGRES_USER: "app"
        POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
        POSTGRES_DB: "app"
      volumes:
        - name: analytics-postgres-data
          size: 10Gi
          mountPath: /var/lib/postgresql/data
    - name: redis
      image: mirror.gcr.io/library/redis:7-alpine
      servicePorts:
        - 6379
      vars: {}
```

<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| plausible-web | mirror.gcr.io/library/alpine:3.22.2 | 4000 | web |
| postgres | mirror.gcr.io/library/postgres:16-alpine | 5432 | database |
| clickhouse | mirror.gcr.io/library/clickhouse-server:latest | 8123 | database |

### Deployment notes

- The application pod communicates with PostgreSQL via postgres.pod:5432
- The application pod communicates with ClickHouse via clickhouse.pod:8123
- Separate pods are used for relational and columnar databases to ensure scalability and adhere to the one-service-per-pod rule.

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-07-14T21:28:35Z  
**Live URL:** https://kitbear-studio-analytics.cloud.nexlayer.ai  
**Runtime:** node · **Port:** 8000  
**Deploy branch:** master  

```yaml
application:
  name: analytics
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kna6j8vrcfj9q0wjtq5qsq3n/analytics:19f62827419"
      path: /
      servicePorts:
        - 8000
      vars:
        NODE_ENV: "production"
        PORT: "8000"
        HOSTNAME: "0.0.0.0"
        DATABASE_URL: "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres.pod:5432/app"
        REDIS_URL: "redis://redis.pod:6379"
        SECRET_KEY_BASE: "${SECRET_KEY_BASE}"
    - name: postgres
      image: mirror.gcr.io/library/postgres:16-alpine
      servicePorts:
        - 5432
      vars:
        POSTGRES_USER: "app"
        POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
        POSTGRES_DB: "app"
      volumes:
        - name: analytics-postgres-data
          size: 10Gi
          mountPath: /var/lib/postgresql/data
    - name: redis
      image: mirror.gcr.io/library/redis:7-alpine
      servicePorts:
        - 6379
      vars: {}
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-07-14T21:22:56Z | analyzed | initial repo analysis |
| 2026-07-14T21:28:35Z | success | deployed https://kitbear-studio-analytics.cloud.nexlayer.ai |
<!-- nexlayer:end -->
