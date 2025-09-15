class Api::CustomersController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_customer, only: [:show, :update]

  def show
    render json: {
      status: 'success',
      data: {
        customer: customer_data(@customer)
      }
    }
  end

  def update
    if @customer.update(customer_params)
      render json: {
        status: 'success',
        message: 'Profile updated successfully.',
        data: {
          customer: customer_data(@customer)
        }
      }
    else
      render json: {
        status: 'error',
        message: 'Update failed.',
        errors: @customer.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = current_customer
  end

  def customer_params
    params.require(:customer).permit(:name, :phone, :preferred_radius, :dietary_preferences, :favorite_categories)
  end

  def customer_data(customer)
    {
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      preferred_radius: customer.preferred_radius,
      dietary_preferences: customer.dietary_preferences,
      favorite_categories: customer.favorite_categories,
      created_at: customer.created_at,
      updated_at: customer.updated_at
    }
  end
end