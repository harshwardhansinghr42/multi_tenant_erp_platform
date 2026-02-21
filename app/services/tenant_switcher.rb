class TenantSwitcher
  # Usage:
  # TenantSwitcher.with(tenant: company) do
  #   # tenant models (inheriting from TenantRecord) are connected to tenant DB
  # end

  def self.with(tenant:)
    raise ArgumentError, "tenant is required" unless tenant

    # Persist previous config to restore after yield
    previous_config = nil
    previous_config = TenantRecord.connection_db_config.configuration_hash if defined?(TenantRecord) && TenantRecord.connected?

    # Tenant can store a DB URL in `db_path` (e.g. postgres://...) or just a name/path.
    db_target = tenant.db_path.presence

    if db_target && db_target.match?(/^postgres(?:ql)?:\/\//)
      # If db_path is a full Postgres URL, use it directly
      TenantRecord.establish_connection(db_target)
    else
      # Build a Postgres connection config per-tenant using ENV fallbacks.
      db_name = if db_target.present?
                  db_target
                else
                  "multi_tenant_erp_#{tenant.slug}"
                end

      new_config = {
        adapter:  'postgresql',
        host:     ENV.fetch('POSTGRES_HOST', 'localhost'),
        port:     ENV.fetch('POSTGRES_PORT', 5432),
        username: ENV.fetch('POSTGRES_USER', 'postgres'),
        password: ENV.fetch('POSTGRES_PASSWORD', nil),
        database: db_name,
        pool:     ENV.fetch('RAILS_MAX_THREADS') { 5 }
      }

      TenantRecord.establish_connection(new_config)
    end

    yield

  ensure
    if previous_config
      TenantRecord.establish_connection(previous_config)
    else
      # If there was no previous config, disconnect the tenant connection to avoid leaking handles
      TenantRecord.connection_pool.disconnect! if defined?(TenantRecord) && TenantRecord.connected?
    end
  end
end
