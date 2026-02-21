class User < TenantRecord
  has_secure_password validations: false

  has_many :orders

  validates :email, presence: true, uniqueness: true
end
