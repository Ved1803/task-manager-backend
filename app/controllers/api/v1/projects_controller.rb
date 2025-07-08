# frozen_string_literal: true

module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_project, only: [:update, :destroy, :assign_users]

      def index
        @projects = Project.includes(:creator).all
        render json: @projects, include: :creator
      end

      def show
        project = Project.includes(:tasks, :creator).find(params[:id])

        render json: {
              project: ProjectSerializer.new(project).serializable_hash[:data][:attributes], 
              message: 'Project retrieved successfully',
          }, status: :ok 
      end

      def create
        @project = Project.new(project_params.merge(created_by: current_user.id))

        if @project.save
          render json: @project, include: :creator, status: :created
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        debugger
        if @project.update(project_params)
          render json: @project, include: :creator
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def assign_users
        user_ids = params[:user_ids] || []
        existing_user_ids = @project.user_ids
      
        new_user_ids = user_ids.map(&:to_i) - existing_user_ids
      
        new_user_ids.each do |uid|
          user = User.find_by(id: uid)
          @project.users << user if user
        end
      
        if @project.save
          render json: { message: "Users assigned successfully", users: @project.users }, status: :ok
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end
      

      def destroy
        @project.destroy
        head :no_content
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_params
        params.require(:project).permit(:name, :description, :status, :start_date, :end_date, :priority, :budget, :client_name)
      end
    end
  end
end
