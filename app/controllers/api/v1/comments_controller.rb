# frozen_string_literal: true

module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user!

      before_action :set_commentable, only: %i[create index]
      after_action :log_comment_activity, only: %i[create]

      def index
        comments = @commentable.comments.includes(:user)
        render json: comments.as_json(include: :user)
      end

      def create
        @comment = @commentable.comments.build(comment_params.merge(user: current_user))
        if @comment.save
          render json: @comment.as_json(include: :user), status: :created
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def comment_params
        params.require(:comment).permit(:body)
      end

      def set_commentable
        @commentable =
          (Task.find(params[:task_id]) if params[:task_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Resource not found' }, status: :not_found
      end

      def log_comment_activity
        return unless @comment && current_user
      
        action = case action_name
                 when 'create' then 'created_comment'
                 else 'unknown_action'
                 end
      
        ActivityLogger.log(user: current_user, trackable: @comment, action: action)
    end   
    end
  end
end
