# frozen_string_literal: true

class AddDeviseToCustomers < ActiveRecord::Migration[7.2]
  def self.up
    change_table :customers do |t|
      ## Database authenticatable - email already exists, replace password_digest with encrypted_password
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at
    end

    # Remove password_digest column and add Devise fields
    remove_column :customers, :password_digest

    # Email index already exists, just add reset_password_token index
    add_index :customers, :reset_password_token, unique: true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
