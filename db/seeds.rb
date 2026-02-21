# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
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

companies.each do |attrs|
	Company.find_or_create_by!(slug: attrs[:slug]) do |c|
		c.name = attrs[:name]
		c.db_path = attrs[:db_path]
		c.external_api_key = attrs[:external_api_key]
	end
end

puts "Seeded companies: #{Company.pluck(:slug).join(', ')}"
