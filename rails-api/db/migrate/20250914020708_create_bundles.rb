class CreateBundles < ActiveRecord::Migration[7.2]
  def change
    create_table :bundles do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :total_original_price, precision: 10, scale: 2, null: false
      t.decimal :bundle_price, precision: 10, scale: 2, null: false
      t.integer :discount_percentage, null: false
      t.integer :available_quantity, default: 0, null: false
      t.datetime :expires_at, null: false
      t.string :image

      t.timestamps
    end

    add_index :bundles, :expires_at
    add_index :bundles, [:merchant_id, :available_quantity]
  end
end
