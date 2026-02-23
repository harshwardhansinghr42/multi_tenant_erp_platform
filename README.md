# Multi-tenant Rails ERP Prototype

Overview
 - Small Rails 8 prototype demonstrating a host/tenant multi-DB pattern.
 - Host DB stores `Company` registry and connection metadata (one row per tenant).
 - Each tenant has its own database (sqlite for quick demos or Postgres for prod).
 - Tenant models inherit from `TenantRecord` and are connected via `TenantSwitcher`.
 - Authentication is JWT-based (login authenticates against tenant DB users).

Architecture
 - Host DB: `companies` table with `name`, `slug`, `db_path`, `external_api_key`.
 - Tenant DBs: per-company schemas (users, shops, products, orders) migrated using tenant migrations under `db/tenant_migrate/`.
 - Services:
	- `TenantSwitcher` — temporarily establishes `TenantRecord` connection for tenant operations.
	- `TenantMigrationService` — runs tenant migrations inside a tenant connection.
	- `OrderReportingJob` / `ProductSyncJob` — background jobs that operate within tenant context.

Local setup (development)
1. Prerequisites
	- Ruby (matching `.ruby-version`), Node (optional), Postgres (or sqlite for demo), Bundler.

2. Install gems
```bash
bundle install
```

3. Configure environment
 - The app reads DB connection details from env vars: `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `POSTGRES_TEST_DB`.
 - For JWT secrets and other credentials, use `bin/rails credentials:edit` or environment variables.

4. Create & migrate host DB
```bash
bin/rails db:create
bin/rails db:migrate
```

5. Create tenant DBs (local demo)
 - For security, tenant DB creation is manual by default. Example (Postgres):
```sql
-- as a postgres superuser or a user with CREATE DATABASE privilege:
CREATE DATABASE multi_tenant_erp_acme;
CREATE DATABASE multi_tenant_erp_beta;
```
 - Or run the helper example:
```bash
bin/rails runner 'Rake::Task["db:prepare_tenant"].invoke("company-slug")'
```

6. Seed host and tenant data
```bash
bin/rails db:seed
```
This will create `Company` rows in the host DB and run tenant migrations and sample tenant seeds for each company.

Running tests
 - Tests use Minitest. If you change the `Gemfile`, run `bundle install` first.
```bash
bin/rails test
```

Background jobs
 - Jobs use ActiveJob + configured adapter (Sidekiq in production). Start Sidekiq locally if needed.

Product sync & ordering reporting
 - `tenants:sync_products` rake task iterates companies and enqueues `ProductSyncJob` per tenant.
 - `OrderReportingJob` sends order payloads to an external API using `Company.external_api_key`.

Notes
 - The repository includes `db/tenant_migrate/` tenant migrations; use `TenantMigrationService` to run them inside tenant connections.
 - For production use, switch tenant DB engine and credentials (e.g., Postgres instances) and store full DB URLs in `Company.db_path`.
 - JWT secret and external API URLs/keys must be configured in credentials or environment variables.
