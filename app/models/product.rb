class Product < TenantRecord
  belongs_to :shop, optional: true

  validates :sku, :name, presence: true
  validates :sku, uniqueness: true

  def master_catalog?
    shop_id.nil?
  end
end
