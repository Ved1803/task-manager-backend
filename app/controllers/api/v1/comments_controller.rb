# frozen_string_literal: true

module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user!

      before_action :set_commentable, only: %i[create index]

      def index
        comments = @commentable.comments.includes(:user)
        render json: comments.as_json(include: :user)
      end

      def create
        comment = @commentable.comments.build(comment_params.merge(user: current_user))
        if comment.save
          render json: comment.as_json(include: :user), status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
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
    end
  end
end
