# frozen_string_literal: true

class TaskSerializer
    include JSONAPI::Serializer
    attributes :id, :title, :description, :status, :priority, :due_date, :category, :user_id, :project_id

    attribute :created_at do |object|
        object.created_at.strftime('%Y-%m-%d %H:%M:%S')
    end

    attribute :updated_at do |object|
        object.updated_at.strftime('%Y-%m-%d %H:%M:%S')
    end

    attribute :assignee do |object|
      object.assignee.as_json(only: %i[id name])
    end

    attribute :reporter do |object|
        object.reporter.as_json(only: %i[id name])
    end
end
