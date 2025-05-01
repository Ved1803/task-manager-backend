# frozen_string_literal: true

module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_project, only: [:update, :destroy]

      def index
        @projects = Project.includes(:creator).all
        render json: @projects, include: :creator
      end

      def show
        project = Project.includes(:tasks, :creator).find(params[:id])

        render json: project.as_json(
          include: {
            tasks: {
              include: {
                assignee: { only: %i[id name] },
                reporter: { only: %i[id name] }
              }
            },
            creator: { only: %i[id name email] }
          }
        )
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

      def destroy
        @project.destroy
        head :no_content
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_params
        params.require(:project).permit(:name, :description)
      end
    end
  end
end
