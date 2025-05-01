class Project < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :created_by, presence: true
end
