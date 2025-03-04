# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  #<ActionController::Parameters {"user"=>#<ActionController::Parameters {"email"=>"ved1@webkorps.com", "password"=>"123456", "name"=>"ved"} permitted: false>, "controller"=>"users/registrations", "action"=>"create", "registration"=>{"user"=>{"email"=>"ved1@webkorps.com", "password"=>"123456", "name"=>"ved"}}} permitted: false>
#<ActionController::Parameters {"email"=>"chirag@gmail.com", "password"=>"123456", "password_confirmation"=>"123456", "controller"=>"users/registrations", "action"=>"create", "registration"=>{"email"=>"chirag@gmail.com", "password"=>"123456", "password_confirmation"=>"123456"}} permitted: false>


  def respond_with(resource, _opts = {})
  
    if resource.persisted?
      @token = request.env['warden-jwt_auth.token']
      headers['Authorization'] = @token

      render json: {
        status: { code: 200, message: 'Signed up successfully.',
                  token: @token,
                  data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
                }
      }
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end

end