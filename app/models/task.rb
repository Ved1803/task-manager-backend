# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user

  enum status: {
    pending: 0,
    done: 1,
    todo: 2,
    in_progress: 3
  }, _prefix: true

  # validates :status, presence: true
    def as_json(options = {})
      super(options).merge(created_at: created_at.strftime("%d-%m-%Y"))
    end  
end
