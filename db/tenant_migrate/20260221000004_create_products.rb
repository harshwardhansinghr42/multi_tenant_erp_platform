class CreateProducts < TenantMigration
  def change
    create_table :products do |t|
      t.string :sku, null: false
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, default: 0, null: false
      t.references :shop, foreign_key: false

      t.timestamps
    end
    add_index :products, :sku
  end
end
