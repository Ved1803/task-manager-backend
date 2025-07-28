# frozen_string_literal: true

module Api
  module V1
    class TasksController < ApplicationController
      before_action :authenticate_user!
      before_action :current_user_and_admin_task, only: %i[update destroy]
      after_action :log_task_activity, only: %i[create update destroy]

      def index
        tasks = current_user.admin? ? Task.includes(:user).order(created_at: :desc) : current_user.tasks.order(created_at: :desc)
        render json: tasks, status: :ok
      end

      def show
        task = Task.find_by(id: params[:id])

        if task
          render json: {
            task: task.as_json(
              include: {
                assignee: { only: [:id, :name, :email] },
                reporter: { only: [:id, :name, :email] }
              }
            ).merge(
              image_urls: (task.images.map { |image| url_for(image) } if task.images.any?)
            )
          }, status: :ok
        else
          render json: { error: "Task Not Found" }, status: :not_found
        end
      end

      def create
        task = current_user.tasks.build(task_params)
        if task.save
          render json: { message: 'Task added', task: task.as_json.merge(
            image_urls: (task.images.map { |image| url_for(image) } if task.images.any?)
          ) }, status: :created
        else
          render json: { error: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @task.update(task_params)
          render json: { message: 'Task updated successfully', task: @task }, status: :ok
        else
          render json: { error: 'Failed to update task status', errors: @task.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def destroy
        if @task.destroy
          render json: { message: 'Task deleted' }, status: :ok
        else
          render json: { message: 'Failed to delete task' }, status: :unprocessable_entity
        end
      end

      def grouped_by_status
        user = params[:user_id]
        project = Project.find(params[:project_id])
        
        tasks = if user.present?
                  project.tasks.where(assigned_to: user).group_by(&:status)
                else
                  project.tasks.all.group_by(&:status)
                end
      
        render json: tasks.transform_values { |tasks| tasks.map { |task| task } }, status: :ok
      
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error 
      end      

      private

      def task_params
        params.require(:task).permit(:title, :description, :status, :reported_by, :assigned_to,
                                     :priority, :due_date, :project_id, :category, images: [])
      end

      def current_user_and_admin_task
        @task = current_user.admin? ? Task.find(params[:id]) : current_user.tasks.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Task not found' }, status: :not_found
      end

      def log_task_activity
        return unless @task && current_user

        action = case action_name
                 when 'create' then 'created_task'
                 when 'update' then 'updated_task'
                 when 'destroy' then 'deleted_task'
                 else 'unknown_action'
                 end

        ActivityLogger.log(user: current_user, trackable: @task, action: action)
      end
    end
  end
end
