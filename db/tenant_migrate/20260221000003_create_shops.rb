class CreateShops < TenantMigration
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.string :code

      t.timestamps
    end
    add_index :shops, :code, unique: true
  end
end
