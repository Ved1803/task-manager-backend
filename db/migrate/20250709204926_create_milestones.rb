class CreateMilestones < ActiveRecord::Migration[7.1]
  def change
    create_table :milestones do |t|
      t.string :title
      t.text :description
      t.date :due_date
      t.integer :status
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
