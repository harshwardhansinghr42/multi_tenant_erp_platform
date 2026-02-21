class Shop < TenantRecord
  has_many :products
  has_many :orders

  validates :name, presence: true
end
