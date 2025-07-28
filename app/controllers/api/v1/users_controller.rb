# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      after_action :log_user_activity, only: %i[update]

      def index
        users = User.includes(avatar_attachment: :blob).all
        render json: users.map { |user|
          user_data(user)
        }
      end

      def user_current
        user = current_user
        if user
          render json: user_data(user)
        else
          render json: { errors: "User not found" }, status: :not_found
        end
      end

      def show
        user = User.find(params[:id])
        if user
          render json: user_data(user)
        else
          render json: { errors: "User not found" }, status: :not_found
        end
      end

      def update
        user = User.find(params[:id])
        if user.update(user_params)
          render json: user_data(user)
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :avatar)
      end

      def user_data(user)
        user.as_json.merge(
          avatar_url: (user.avatar.attached? ? url_for(user.avatar) : nil)
        )
      end

      def log_user_activity
        return unless current_user

        action = case action_name
                 when 'update' then 'updated_profile'
                 else 'unknown_action'
                 end

        ActivityLogger.log(user: current_user, trackable: user, action: action) if user
      end
    end
  end
end
