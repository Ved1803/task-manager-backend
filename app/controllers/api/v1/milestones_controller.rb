module Api
    module V1
        class MilestonesController < ApplicationController
            before_action :set_project
            before_action :set_milestone, only: [:update, :destroy]
            after_action :log_project_activity, only: [:create, :update, :destroy]

            def index
                @milestones = @project.milestones.order(:due_date)
                render json: @milestones, status: :ok
            end

            def upcomming
                @milestones = @project.milestones.where('due_date > ?', Date.today).order(:due_date)
                render json: @milestones, status: :ok
            end

            def create
                @milestone = @project.milestones.new(milestone_params)

                if @milestone.save
                    render json: @milestone, status: :created
                else
                    render json: { errors: @milestone.errors.full_messages }, status: :unprocessable_entity
                end
            end

            def update
                if @milestone.update(milestone_params)
                    render json: @milestone, status: :ok
                else
                    render json: { errors: @milestone.errors.full_messages }, status: :unprocessable_entity
                end
            end

            def destroy
                if @milestone.destroy
                    render json: { message: 'Milestone deleted successfully' }, status: :ok
                else
                    render json: { errors: @milestone.errors.full_messages }, status: :unprocessable_entity
                end
            end

            private

            def set_project
                @project = Project.find(params[:project_id])
            end

            def set_milestone
                @milestone = @project.milestones.find(params[:id])
            end

            def milestone_params
                params.require(:milestone).permit(:title, :description, :due_date)
            end

            def log_milestone_activity
                return unless @milestone && current_user
              
                action = case action_name
                         when 'create' then 'created_milestone'
                         when 'update' then 'updated_milestone'
                         when 'destroy' then 'deleted_milestone'
                         else 'unknown_action'
                         end
              
                ActivityLogger.log(user: current_user, trackable: @milestone, action: action)
            end              
        end
    end
end
