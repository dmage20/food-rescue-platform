class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.string :item_type, null: false # 'product' or 'bundle'
      t.bigint :item_id, null: false
      t.string :name, null: false # snapshot of name at purchase time
      t.integer :quantity, null: false, default: 1
      t.decimal :price_at_purchase, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :order_items, [:item_type, :item_id]
  end
end
