class AddFieldsToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :reported_by, :bigint
    add_column :tasks, :assigned_to, :bigint
    add_column :tasks, :priority, :integer
    add_column :tasks, :due_date, :datetime
    add_column :tasks, :category, :string

    add_foreign_key :tasks, :users, column: :reported_by
    add_foreign_key :tasks, :users, column: :assigned_to
    add_index :tasks, :reported_by
    add_index :tasks, :assigned_to
  end
end
