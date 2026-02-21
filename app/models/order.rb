class Order < TenantRecord
  belongs_to :user, optional: true
  belongs_to :shop, optional: true

  validates :order_number, presence: true, uniqueness: true
end
