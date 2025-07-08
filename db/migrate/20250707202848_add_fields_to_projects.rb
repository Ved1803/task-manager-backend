class AddFieldsToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :status, :integer, default: 0
    add_column :projects, :start_date, :date
    add_column :projects, :end_date, :date
    add_column :projects, :priority, :integer, default: 1 
    add_column :projects, :budget, :decimal
    add_column :projects, :client_name, :string
  end
end
