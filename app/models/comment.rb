# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :activities, as: :trackable, dependent: :destroy

  validates :body, presence: true
end
