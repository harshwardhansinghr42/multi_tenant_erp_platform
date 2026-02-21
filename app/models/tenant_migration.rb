class TenantMigration < ActiveRecord::Migration[8.0]
  def connection
    TenantRecord.connection
  end
end