# frozen_string_literal: true

class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def up
    add_column :users, :role, :integer, default: 0
    change_column :users, :role, :integer, using: 'role::integer'
  end

  def down
    remove_column :users, :role
  end
end
