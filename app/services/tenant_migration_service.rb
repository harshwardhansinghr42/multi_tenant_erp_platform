# Service responsible for running tenant migration.
class TenantMigrationService
  def self.call(company:)
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
end
