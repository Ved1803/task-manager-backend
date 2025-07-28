class Activity < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :user
end