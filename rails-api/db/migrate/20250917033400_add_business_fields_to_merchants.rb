class AddBusinessFieldsToMerchants < ActiveRecord::Migration[7.2]
  def change
    add_column :merchants, :business_type, :string
    add_column :merchants, :description, :text
  end
end