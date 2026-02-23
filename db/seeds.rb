# Seeds for host `Company` records and sample tenant data.
# This file is idempotent and safe to re-run.

companies = [
  {
    name: "Acme Corporation",
    slug: "acme",
    # For Postgres demo we use a DB name per tenant. In production this may be a full URL.
    db_path: ENV.fetch("TENANT_DB_A", "multi_tenant_erp_acme"),
    external_api_key: ENV.fetch("ACME_EXTERNAL_API_KEY", "acme-secret-token")
  },
  {
    name: "Beta Traders",
    slug: "beta",
    db_path: ENV.fetch("TENANT_DB_B", "multi_tenant_erp_beta"),
    external_api_key: ENV.fetch("BETA_EXTERNAL_API_KEY", "beta-secret-token")
  }
]

# Create or update host Company rows and ensure tenant schema/migrations are present.
companies.each do |attrs|
  company = Company.find_or_create_by!(slug: attrs[:slug]) do |c|
    c.name = attrs[:name]
    c.db_path = attrs[:db_path]
    c.external_api_key = attrs[:external_api_key]
  end

  # Run tenant migrations for the company. This will switch the connection to the
  # tenant DB and run migrations under `db/tenant_migrate/`.
  TenantMigrationService.call(company: company)
end

# Seed tenant data (users, shops, and products) for each company
Company.find_each do |company|
  TenantSwitcher.with(tenant: company) do
    # Create a default admin user per tenant
    admin_email = "#{company.slug}@example.com"
    User.find_or_create_by!(email: admin_email) do |u|
      u.name = "#{company.name} Admin"
      u.password = ENV.fetch('TENANT_ADMIN_PASSWORD', 'password')
    end

    # Create a default shop
    shop = Shop.find_or_create_by!(name: 'Main')

    # Create a sample product if none exists
    sample_sku = "SKU-#{company.slug.upcase}-001"
    product = Product.find_or_initialize_by(sku: sample_sku)
    product.assign_attributes(
      name: 'Sample Product',
      description: 'This is a sample product.',
      price_cents: 1000,
      shop: shop
    )
    product.save!
  end
end

# Notes:
# - Tenant DB creation may require separate steps depending on your Postgres privileges.
#   If your local Postgres user can create databases, you can create them manually
#   or use a helper task such as `db:prepare_tenant` if available.
# - To seed everything locally:
#   1. Configure Postgres env vars (POSTGRES_USER/POSTGRES_PASSWORD/etc.)
#   2. Run `bin/rails db:create db:migrate`
#   3. Manually create tenant DBs or ensure your user can create them
#   4. Run `bin/rails db:seed`
