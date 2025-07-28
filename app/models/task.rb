# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user
  belongs_to :reporter, class_name: "User", foreign_key: "reported_by", optional: true
  belongs_to :assignee, class_name: "User", foreign_key: "assigned_to", optional: true
  belongs_to :project
  has_many :comments, as: :commentable, dependent: :destroy
  has_many_attached :images
  has_many :activities, as: :trackable, dependent: :destroy

  enum status: {
    todo: 0,
    in_progress: 1,
    review: 2,
    done: 3
  }, _prefix: true

  enum priority: { low: 0, medium: 1, high: 2, critical: 3 }, _prefix: true

  # validates :status, presence: true
  def as_json(options = {})
    super(options).merge(created_at: created_at.strftime("%d-%m-%Y"))
  end
end
