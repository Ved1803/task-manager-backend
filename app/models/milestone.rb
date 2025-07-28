class Milestone < ApplicationRecord  
  belongs_to :project
  has_many :activities, as: :trackable, dependent: :destroy

  enum status: { pending: 0, in_progress: 1, completed: 2 }

  validates :title, :due_date, presence: true

  before_validation :set_status_based_on_due_date

  private

  def set_status_based_on_due_date
    return if due_date.blank?

    today = Date.today

    self.status =
      if due_date > today
        :pending
      elsif due_date == today
        :in_progress
      else
        :completed
      end
  end
end
