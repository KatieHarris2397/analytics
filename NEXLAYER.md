# Nexlayer — analytics

<!-- nexlayer:meta version=1 analyzed=2026-08-19T20:31:28Z repo=https://github.com/KatieHarris2397/analytics branch=master -->

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
Plausible Analytics is an open-source, privacy-first web analytics platform that provides a lightweight, cookie-free alternative to Google Analytics. It offers GDPR/CCPA/PECR-compliant website traffic measurement with a simple dashboard and a lightweight tracking script.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Elixir | language | ~> 1.18 | mix.exs |
| Phoenix | framework | 1.7 | mix.exs |
| Erlang/OTP | language | 27.3.4.6 | Dockerfile |
| PostgreSQL | database | 16 | config/config.exs |
| ClickHouse | database | latest | config/config.exs |
| Node.js | language | 23.11.1 | Dockerfile |
| Tailwind CSS | framework | 4.1.12 | config/config.exs |
| esbuild | build | 0.17.11 | config/config.exs |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- lib/ — Elixir application source code
- lib/plausible_web/ — Phoenix web layer (controllers, views, endpoints)
- lib/plausible/ — Core business logic and domain modules
- assets/ — Frontend assets (JS, CSS, dashboard)
- tracker/ — Lightweight tracking script
- priv/ — Static files, database migrations, release assets
- config/ — Configuration files (runtime, dev, prod, test)
- rel/ — Release configuration and entrypoint scripts
- extra/ — Additional modules for community edition
- test/ — Test suite
- e2e/ — End-to-end tests
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- Sentry (error tracking)
- Postmark (email delivery)
- Paddle (billing API)
- Google API (for Google Search Console integration)
- MaxMind GeoIP database (country detection)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Elixir >= 1.18
- Erlang/OTP >= 27
- Node.js >= 23
- PostgreSQL >= 16
- ClickHouse (optional for analytics storage)
- Docker (for containerized development)

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
BASE_URL=http://localhost:8000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/plausible_dev
CLICKHOUSE_DATABASE_URL=http://localhost:8123/plausible_dev
SECRET_KEY_BASE=generate-a-random-secret
HTTP_PORT=8000
LISTEN_IP=0.0.0.0
```

### Steps

1. `mix deps.get` — Install Elixir dependencies
2. `npm install --prefix assets && npm install --prefix tracker` — Install frontend dependencies
3. `mix ecto.create && mix ecto.migrate` — Create and migrate PostgreSQL database
4. `mix phx.server` — Start development server on http://localhost:8000

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### nexlayer.yaml

```yaml
application:
  name: analytics
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01krc1n44dd49btzyv6vht92v2/analytics:a01bb73-fix2"
      path: /
      servicePorts:
        - 8000
      vars: {}
```

<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| web | mirror.gcr.io/library/alpine:3.22.2 | 8000 | web |
| db | mirror.gcr.io/library/postgres:16-alpine | 5432 | database |
| clickhouse | mirror.gcr.io/library/clickhouse/clickhouse-server:latest | 8123 | database |

### Deployment notes

- The web pod connects to PostgreSQL via db.pod:5432 and ClickHouse via clickhouse.pod:8123 (using the <podName>.pod:<port> form)
- The Dockerfile builds a release with MIX_ENV=ce (community edition) and runs the Plausible application as a single service
- The web pod uses the Alpine-based release image built from the Dockerfile, not a pre-built Docker Hub image
- ClickHouse is a separate database pod for analytics event storage, while PostgreSQL stores application metadata
- The tracker script is served from the web pod at /js/script.js for client-side analytics collection
- For production, BASE_URL must be set to the public URL of the analytics instance
- SECRET_KEY_BASE must be a strong random string for production security

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-08-19T20:39:01Z  
**Live URL:** https://xenial-tern-analytics.qa.cluster.vibeship.work  
**Runtime:** node · **Port:** 8000  
**Deploy branch:** master  

```yaml
application:
  name: analytics
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01krc1n44dd49btzyv6vht92v2/analytics:a01bb73-fix2"
      path: /
      servicePorts:
        - 8000
      vars: {}
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-08-19T20:31:28Z | analyzed | initial repo analysis |
| 2026-08-19T20:39:01Z | success | deployed https://xenial-tern-analytics.qa.cluster.vibeship.work |
<!-- nexlayer:end -->
