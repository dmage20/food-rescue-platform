# frozen_string_literal: true

class Api::Merchants::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :configure_sign_up_params, only: [:create]

  private

  def respond_with(resource, _opts = {})
    if request.method == "POST" && resource.persisted?
      token = Warden::JWTAuth::UserEncoder.new.call(resource, :merchant, nil)[0]
      
      render json: {
        status: 'success',
        message: 'Merchant registered successfully.',
        token: token,
        user: {
          id: resource.id,
          name: resource.name,
          email: resource.email,
          business_name: resource.name,
          business_type: resource.business_type,
          address: resource.address,
          description: resource.description
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
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :business_name, :business_type, :address, :description, :latitude, :longitude, :phone])
  end
  
  def build_resource(hash = {})
    # Map frontend field names to backend field names
    if hash[:business_name].present?
      hash[:name] = hash[:business_name]
    end
    
    # Set default coordinates if not provided (will be updated with geocoding later)
    hash[:latitude] ||= 37.7749  # Default to San Francisco
    hash[:longitude] ||= -122.4194
    
    super(hash)
  end
end
