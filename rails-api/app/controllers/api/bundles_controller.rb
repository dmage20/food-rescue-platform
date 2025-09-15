class Api::BundlesController < ApplicationController
  before_action :authenticate_merchant!
  before_action :set_bundle, only: [:show, :update, :destroy]

  def index
    @bundles = current_merchant.bundles.includes(:merchant, :bundle_items)
    render json: {
      status: 'success',
      data: {
        bundles: @bundles.map { |bundle| bundle_data(bundle) }
      }
    }
  end

  def show
    render json: {
      status: 'success',
      data: {
        bundle: bundle_data(@bundle)
      }
    }
  end

  def create
    @bundle = current_merchant.bundles.build(bundle_params)

    if @bundle.save
      create_bundle_items if params[:bundle_items].present?

      render json: {
        status: 'success',
        message: 'Bundle created successfully.',
        data: {
          bundle: bundle_data(@bundle.reload)
        }
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'Bundle creation failed.',
        errors: @bundle.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @bundle.update(bundle_params)
      update_bundle_items if params[:bundle_items].present?

      render json: {
        status: 'success',
        message: 'Bundle updated successfully.',
        data: {
          bundle: bundle_data(@bundle.reload)
        }
      }
    else
      render json: {
        status: 'error',
        message: 'Bundle update failed.',
        errors: @bundle.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @bundle.destroy
    render json: {
      status: 'success',
      message: 'Bundle deleted successfully.'
    }
  end

  private

  def set_bundle
    @bundle = current_merchant.bundles.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'Bundle not found.'
    }, status: :not_found
  end

  def bundle_params
    params.require(:bundle).permit(:name, :description, :total_price, :available_quantity, :expires_at)
  end

  def create_bundle_items
    params[:bundle_items].each do |item_params|
      @bundle.bundle_items.create!(
        product_id: item_params[:product_id],
        quantity: item_params[:quantity]
      )
    end
  end

  def update_bundle_items
    @bundle.bundle_items.destroy_all
    create_bundle_items
  end

  def bundle_data(bundle)
    {
      id: bundle.id,
      name: bundle.name,
      description: bundle.description,
      total_price: bundle.total_price,
      available_quantity: bundle.available_quantity,
      expires_at: bundle.expires_at,
      merchant: {
        id: bundle.merchant.id,
        name: bundle.merchant.name
      },
      items: bundle.bundle_items.includes(:product).map do |item|
        {
          id: item.id,
          quantity: item.quantity,
          product: {
            id: item.product.id,
            name: item.product.name,
            category: item.product.category
          }
        }
      end,
      created_at: bundle.created_at,
      updated_at: bundle.updated_at
    }
  end
end