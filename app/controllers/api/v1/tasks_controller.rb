# frozen_string_literal: true

module Api
  module V1
    class TasksController < ApplicationController
      before_action :authenticate_user!
      before_action :current_user_and_admin_task, only: %i[update destroy]

      def index
        tasks = current_user.admin? ? Task.includes(:user).order(created_at: :desc) : current_user.tasks.order(created_at: :desc)
        render json: tasks, status: :ok 
      end

      def show
        task = Task.find_by(id: params[:id])
      
        if task
          render json: { task: task }, status: :ok
        else
          render json: { error: "Task Not Found" }, status: :not_found
        end
      end

      def create
        task = current_user.tasks.build(task_params)
        if task.save
          render json: { message: 'Task added', task: task }, status: :created
        else
          render json: { error: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @task.update(status: params[:status])
          render json: { message: 'Task status updated successfully', task: @task }, status: :ok
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

      private

      def task_params
        params.require(:task).permit(:title, :description, :status)
      end

      def current_user_and_admin_task
        @task = current_user.admin? ? Task.find(params[:id]) : current_user.tasks.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {error: 'Task not found'}, status: :not_found
      end
    end
  end
end
  