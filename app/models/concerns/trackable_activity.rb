module TrackableActivity
    extend ActiveSupport::Concern
  
    included do
      has_many :activities, as: :trackable, dependent: :destroy
  
      after_create :log_create_activity
      after_update :log_update_activity
      after_destroy :log_destroy_activity
    end
  
    private
  
    def log_create_activity
      log_activity('created')
    end
  
    def log_update_activity
      log_activity('updated')
    end
  
    def log_destroy_activity
      log_activity('deleted')
    end
  
    def log_activity(action)
        debugger
      return unless Current.user
  
      Activity.create!(
        user: Current.user,
        action: "#{action}_#{self.class.name.underscore}",
        trackable: self
      )
    end
  end