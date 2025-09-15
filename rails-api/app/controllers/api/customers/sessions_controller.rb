# frozen_string_literal: true

class Api::Customers::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: 'success',
      message: 'Signed in successfully.',
      data: {
        customer: {
          id: resource.id,
          name: resource.name,
          email: resource.email
        }
      }
    }
  end

  def respond_to_on_destroy
    if current_customer
      render json: {
        status: 'success',
        message: 'Signed out successfully.'
      }
    else
      render json: {
        status: 'error',
        message: 'Could not sign out.'
      }, status: :unauthorized
    end
  end
end
