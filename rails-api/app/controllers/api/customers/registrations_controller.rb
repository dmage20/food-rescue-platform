# frozen_string_literal: true

class Api::Customers::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :configure_sign_up_params, only: [:create]

  private

  def respond_with(resource, _opts = {})
    if request.method == "POST" && resource.persisted?
      token = Warden::JWTAuth::UserEncoder.new.call(resource, :customer, nil)[0]
      
      render json: {
        status: 'success',
        message: 'Customer registered successfully.',
        token: token,
        user: {
          id: resource.id,
          name: resource.name,
          email: resource.email,
          phone: resource.phone
        }
      }
    elsif request.method == "POST"
      render json: {
        status: 'error',
        message: resource.errors.full_messages.join(', '),
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    else
      super
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone, :preferred_radius, :dietary_preferences, :favorite_categories])
  end
end
