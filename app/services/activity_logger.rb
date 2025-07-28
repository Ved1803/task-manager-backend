# app/services/activity_logger.rb
class ActivityLogger
    def self.log(user:, trackable:, action:)
      return if user.blank? || trackable.blank? || action.blank?
  
      Activity.create!(
        user: user,
        trackable: trackable,
        action: action
      )
    end
  end
  