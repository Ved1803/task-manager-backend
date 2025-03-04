class Api::V1::TasksController < ApplicationController
    before_action :authenticate_user!

    def index
      tasks = if current_user.admin?
                Task.includes(:user).order(created_at: :desc)
              else
                current_user.tasks.order(created_at: :desc)
              end
    
      render json: tasks
    end
    
    def create
      task = current_user.tasks.build(task_params)
      if task.save
        render json: { message: 'Task added', task: task}, status: :created
      else
        render json: { error: task.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      task = Task.find(params[:id])
      if task.update(status: params[:status])
        render json: { message: "Task status updated successfully", task: task }, status: :ok
      else
        render json: { error: "Failed to update task status", errors: task.errors.full_messages }, status: :unprocessable_entity
      end

    end
  
    def destroy
      task = current_user.tasks.find(params[:id])
      task.destroy
      render json: { message: "Task deleted" }
    end
  
    private
  
    def task_params
      params.require(:task).permit(:title, :description, :status)
    end
  end
  