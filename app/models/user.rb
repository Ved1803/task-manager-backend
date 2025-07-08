# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include Rails.application.routes.url_helpers

  devise :database_authenticatable, :registerable, :recoverable, :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: self

  has_many :tasks
  has_many :reported_tasks, class_name: "Task", foreign_key: "reported_by", dependent: :destroy
  has_many :assigned_tasks, class_name: "Task", foreign_key: "assigned_to", dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :created_projects, class_name: 'Project', foreign_key: 'created_by', dependent: :destroy
  has_one_attached :avatar

  has_many :project_users
  has_many :projects, through: :project_users

  enum role: { member: 0, admin: 1 }

  def avatar_url
    avatar.attached? ? rails_blob_url(avatar, only_path: false) : nil
  end
end
