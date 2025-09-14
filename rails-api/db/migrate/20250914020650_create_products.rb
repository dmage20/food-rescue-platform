class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :category, null: false
      t.decimal :original_price, precision: 10, scale: 2, null: false
      t.decimal :discounted_price, precision: 10, scale: 2, null: false
      t.integer :discount_percentage, null: false
      t.integer :available_quantity, default: 0, null: false
      t.json :allergens
      t.json :dietary_tags
      t.datetime :expires_at, null: false
      t.json :images

      t.timestamps
    end

    add_index :products, :category
    add_index :products, :expires_at
    add_index :products, [:merchant_id, :available_quantity]
  end
end
