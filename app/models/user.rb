# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :recoverable, :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: self

  has_many :tasks
  has_many :reported_tasks, class_name: "Task", foreign_key: "reported_by", dependent: :destroy
  has_many :assigned_tasks, class_name: "Task", foreign_key: "assigned_to", dependent: :destroy

  enum role: { member: 0, admin: 1 }
end
