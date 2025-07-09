# frozen_string_literal: true

module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_project, only: [:update, :destroy, :assign_users]

      def index
        @projects = Project.includes(:creator).search(params[:q])
        render json: @projects, include: :creator, status: :ok
      end      

      def grouped_by_status
        projects = Project.includes(:creator).group_by(&:status)
        grouped_projects = projects.transform_values do |projects|
          projects.map { |project| ProjectSerializer.new(project).serializable_hash[:data][:attributes] }
        end

        render json: grouped_projects, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error 
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
        if current_user.admin? || @project.created_by == current_user.id
          if @project.destroy
            render json: { message: "Project was soft-deleted successfully." }, status: :ok
          else
            render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "You are not authorized to delete this project." }, status: :forbidden
        end
      end

      def restore
        # if !current_user.admin?
        #   render json: { message: "You are not authorized to restore projects." }
        #   return
        # end 
        @project = Project.only_deleted.find(params[:id])

        if @project.restore
          render json: { message: "Project was restored successfully." }, status: :ok
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def deleted_projects
        # if !current_user.admin?
        #   render json: { message: "You are not authorized to view deleted projects." }
        #   return
        # end
        @deleted_projects = Project.only_deleted.includes(:creator).all
        render json: @deleted_projects, include: :creator, status: :ok
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
