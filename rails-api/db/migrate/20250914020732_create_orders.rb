class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :merchant, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.string :confirmation_code, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.datetime :pickup_window_start, null: false
      t.datetime :pickup_window_end, null: false
      t.datetime :picked_up_at
      t.text :special_instructions

      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :confirmation_code, unique: true
    add_index :orders, :pickup_window_start
  end
end
