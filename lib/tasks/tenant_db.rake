namespace :tenant_db do
  task migrate: :environment do
    slug = ENV.fetch("COMPANY")
    company = Company.find_by!(slug: slug)
    TenantMigrationService.call(company: company)
  end

  task migrate_all: :environment do
    Company.find_each do |company|
      TenantMigrationService.call(company: company)
    end
  end
end
