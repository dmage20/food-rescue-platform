# frozen_string_literal: true

class Api::Customers::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :configure_sign_up_params, only: [:create]

  private

  def respond_with(resource, _opts = {})
    if request.method == "POST" && resource.persisted?
      render json: {
        status: 'success',
        message: 'Customer registered successfully.',
        data: {
          customer: {
            id: resource.id,
            name: resource.name,
            email: resource.email
          }
        }
      }
    elsif request.method == "POST"
      render json: {
        status: 'error',
        message: 'Registration failed.',
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    else
      super
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :preferred_radius, :dietary_preferences, :favorite_categories])
  end
end
