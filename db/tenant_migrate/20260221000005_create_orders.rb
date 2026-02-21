class CreateOrders < TenantMigration
  def change
    create_table :orders do |t|
      t.string :order_number, null: false
      t.references :user, foreign_key: false
      t.references :shop, foreign_key: false
      t.json :items
      t.integer :total_cents, default: 0, null: false
      t.string :status, default: 'pending'

      t.timestamps
    end
    add_index :orders, :order_number, unique: true
  end
end
