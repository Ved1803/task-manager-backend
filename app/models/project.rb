class Project < ApplicationRecord
  acts_as_paranoid
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  has_many :tasks, dependent: :destroy
  has_many :project_users
  has_many :users, through: :project_users
  has_many :milestones, dependent: :destroy
  has_many :activities, as: :trackable, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :created_by, presence: true
  enum priority: { low: 1, medium: 0, high: 2 }
  enum status: {
    active: 0,
    planned: 1,
    on_hold: 2,
    completed: 3,
    cancelled: 4,
    archived: 5
  }

  scope :search, ->(query) {
    where("name ILIKE :q OR description ILIKE :q", q: "%#{sanitize_sql_like(query)}%")
  }
end
