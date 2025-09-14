class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.decimal :preferred_radius, precision: 4, scale: 1, default: 5.0
      t.json :dietary_preferences
      t.json :favorite_categories
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :customers, :email, unique: true
  end
end
