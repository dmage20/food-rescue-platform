class Api::ProductsController < ApplicationController
  before_action :authenticate_merchant!
  before_action :set_product, only: [:show, :update, :destroy]

  def index
    @products = current_merchant.products.includes(:merchant)
    render json: {
      status: 'success',
      data: {
        products: @products.map { |product| product_data(product) }
      }
    }
  end

  def show
    render json: {
      status: 'success',
      data: {
        product: product_data(@product)
      }
    }
  end

  def create
    @product = current_merchant.products.build(product_params)

    if @product.save
      render json: {
        status: 'success',
        message: 'Product created successfully.',
        data: {
          product: product_data(@product)
        }
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'Product creation failed.',
        errors: @product.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: {
        status: 'success',
        message: 'Product updated successfully.',
        data: {
          product: product_data(@product)
        }
      }
    else
      render json: {
        status: 'error',
        message: 'Product update failed.',
        errors: @product.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    render json: {
      status: 'success',
      message: 'Product deleted successfully.'
    }
  end

  private

  def set_product
    @product = current_merchant.products.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'Product not found.'
    }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:name, :description, :category, :original_price, :discounted_price, :available_quantity, :expires_at)
  end

  def product_data(product)
    {
      id: product.id,
      name: product.name,
      description: product.description,
      category: product.category,
      original_price: product.original_price,
      discounted_price: product.discounted_price,
      available_quantity: product.available_quantity,
      expires_at: product.expires_at,
      merchant: {
        id: product.merchant.id,
        name: product.merchant.name
      },
      created_at: product.created_at,
      updated_at: product.updated_at
    }
  end
end