class CreateMerchants < ActiveRecord::Migration[7.2]
  def change
    create_table :merchants do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :address, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.json :business_hours
      t.text :pickup_instructions
      t.string :specialty
      t.string :image
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :merchants, :email, unique: true
    add_index :merchants, [:latitude, :longitude]
  end
end
