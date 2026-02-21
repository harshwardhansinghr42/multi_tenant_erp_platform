namespace :tenant_db do
  def migrate_company(company)
    migrations_path = Rails.root.join("db", "tenant_migrate")

    TenantSwitcher.with(tenant: company) do
      pool = TenantRecord.connection_pool

      schema_migration = ActiveRecord::SchemaMigration.new(pool)
      internal_metadata = ActiveRecord::InternalMetadata.new(pool)

      migration_context = ActiveRecord::MigrationContext.new(
        migrations_path,
        schema_migration,
        internal_metadata
      )

      migration_context.migrate
    end
  end

  task migrate: :environment do
    slug = ENV.fetch("COMPANY")
    company = Company.find_by!(slug: slug)
    migrate_company(company)
  end

  task migrate_all: :environment do
    Company.find_each do |company|
      migrate_company(company)
    end
  end
end
