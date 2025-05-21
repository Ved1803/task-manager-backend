# frozen_string_literal: true

class ProjectSerializer
    include JSONAPI::Serializer
    attributes :id, :name, :description

    # TaskSerializer
    attribute :tasks do |object|
        object.tasks.map do |task|
            TaskSerializer.new(task).serializable_hash[:data][:attributes]
        end
    end

    attribute :creator do |object|
        object.creator.as_json(only: %i[id name email])
    end

    attribute :totalTasks do |object|
        object.tasks&.count
    end

    attribute :completedTasks do |object|
        object.tasks&.where(status: 'done')&.count
    end
    
    attribute :pendingTasks do |object|
        object.tasks&.where(status: 'pending')&.count
    end

    attribute :inProgressTasks do |object|
        object.tasks&.where(status: 'in_progress')&.count
    end

    attribute :created_at do |object|
        object.created_at.strftime('%Y-%m-%d %H:%M:%S')
    end

    # attribute :assignedUsers do |object|
    #     object.users.map do |user|
    #         user.as_json(only: %i[id name email]).merge(
    #             avatar_url: (user.avatar.attached? ? url_for(user.avatar) : nil)
    #           )
    #     end
    # end
end
