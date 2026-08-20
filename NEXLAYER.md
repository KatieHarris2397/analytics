# Nexlayer — analytics

<!-- nexlayer:meta version=1 analyzed=2026-08-20T15:32:30Z repo=https://github.com/KatieHarris2397/analytics branch=master -->

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
Plausible Analytics is an open-source, privacy-first web analytics platform built with Elixir and Phoenix, offering a lightweight, cookie-free alternative to Google Analytics with GDPR/CCPA/PECR compliance.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Elixir | language | ~> 1.18 | mix.exs |
| Phoenix | framework | 1.7 | mix.exs |
| PostgreSQL | database | 16 | config/runtime.exs |
| ClickHouse | database | 24 | config/runtime.exs |
| Redis | cache | 7 | config/runtime.exs |
| Tailwind CSS | build | 4.1.12 | config/config.exs |
| esbuild | build | 0.17.11 | config/config.exs |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- lib/plausible/ — core application logic
- lib/plausible_web/ — Phoenix web controllers and views
- assets/ — frontend assets (JS, CSS)
- tracker/ — JavaScript tracker script
- priv/ — static files and database seeds
- config/ — runtime and environment configuration
- rel/ — release and deployment scripts
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- Postmark API (POSTMARK_API_KEY) for email delivery
- Sentry (SENTRY_DSN) for error tracking
- Google API (GOOGLE_API_KEY) for Google Search Console integration
- Paddle API (PADDLE_API_KEY) for billing
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Elixir >= 1.18
- Erlang/OTP >= 27
- Node.js >= 20
- PostgreSQL >= 16
- ClickHouse >= 24
- Redis >= 7

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
BASE_URL=http://localhost:8000
SECRET_KEY_BASE=any-64-char-string
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/plausible_dev
CLICKHOUSE_DATABASE_URL=http://localhost:8123/plausible_dev
REDIS_URL=redis://localhost:6379
POSTMARK_API_KEY=your-postmark-key
```

### Steps

1. `mix deps.get` — Install Elixir dependencies
2. `npm install --prefix assets && npm install --prefix tracker` — Install frontend dependencies
3. `mix ecto.create && mix ecto.migrate` — Create and migrate PostgreSQL database
4. `mix run priv/repo/seeds.exs` — Seed initial data
5. `mix phx.server` — Start Phoenix server on http://localhost:8000

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### nexlayer.yaml

```yaml
application:
  name: analytics
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01krc1n44dd49btzyv6vht92v2/analytics:a01fcc4-fix1"
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
| web | mirror.gcr.io/library/elixir:1.18-alpine | 8000 | web |
| db | mirror.gcr.io/library/postgres:16-alpine | 5432 | database |
| clickhouse | mirror.gcr.io/library/clickhouse/clickhouse-server:24-alpine | 8123 | database |
| redis | mirror.gcr.io/library/redis:7-alpine | 6379 | cache |

### Deployment notes

- Web pod connects to PostgreSQL via db.pod:5432, ClickHouse via clickhouse.pod:8123, and Redis via redis.pod:6379.
- All database and cache services are separate pods as required by Nexlayer rules.
- Use mirror.gcr.io for all Docker Hub images to avoid registry failures.
- Set SECRET_KEY_BASE to a strong random value in production.
- Configure BASE_URL to the public URL of the analytics instance.

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-08-20T15:38:11Z  
**Live URL:** https://xenial-tern-analytics.qa.cluster.vibeship.work  
**Runtime:** node · **Port:** 8000  
**Deploy branch:** master  

```yaml
application:
  name: analytics
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01krc1n44dd49btzyv6vht92v2/analytics:a01fcc4-fix1"
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
| 2026-08-20T15:32:30Z | analyzed | initial repo analysis |
| 2026-08-20T15:38:11Z | success | deployed https://xenial-tern-analytics.qa.cluster.vibeship.work |
<!-- nexlayer:end -->
