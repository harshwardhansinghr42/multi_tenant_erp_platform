class Company < ApplicationRecord
  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  # Return the tenant DB target for this company. This may be:
  # - a full DB URL stored in `db_path` (preferred for Postgres)
  # - a database name stored in `db_path`
  # - a default name derived from the host Postgres DB and company slug
  def tenant_db_target
    db_path.presence || "multi_tenant_erp_#{slug}"
  end
end
