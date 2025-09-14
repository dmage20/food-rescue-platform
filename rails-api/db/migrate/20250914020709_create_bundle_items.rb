class CreateBundleItems < ActiveRecord::Migration[7.2]
  def change
    create_table :bundle_items do |t|
      t.references :bundle, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :bundle_items, [:bundle_id, :product_id], unique: true
  end
end
