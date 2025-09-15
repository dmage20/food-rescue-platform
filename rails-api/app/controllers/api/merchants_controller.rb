class Api::MerchantsController < ApplicationController
  before_action :authenticate_merchant!
  before_action :set_merchant, only: [:show, :update]

  def show
    render json: {
      status: 'success',
      data: {
        merchant: merchant_data(@merchant)
      }
    }
  end

  def update
    if @merchant.update(merchant_params)
      render json: {
        status: 'success',
        message: 'Profile updated successfully.',
        data: {
          merchant: merchant_data(@merchant)
        }
      }
    else
      render json: {
        status: 'error',
        message: 'Update failed.',
        errors: @merchant.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_merchant
    @merchant = current_merchant
  end

  def merchant_params
    params.require(:merchant).permit(:name, :address, :latitude, :longitude)
  end

  def merchant_data(merchant)
    {
      id: merchant.id,
      name: merchant.name,
      email: merchant.email,
      address: merchant.address,
      latitude: merchant.latitude,
      longitude: merchant.longitude,
      created_at: merchant.created_at,
      updated_at: merchant.updated_at
    }
  end
end