class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :db_path
      t.string :external_api_key

      t.timestamps
    end

    add_index :companies, :slug, unique: true
  end
end

