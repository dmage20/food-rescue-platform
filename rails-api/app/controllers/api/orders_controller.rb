class Api::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :update]

  def index
    @orders = if current_merchant
      current_merchant.orders.includes(:customer, :order_items)
    elsif current_customer
      current_customer.orders.includes(:merchant, :order_items)
    else
      []
    end

    render json: {
      status: 'success',
      data: {
        orders: @orders.map { |order| order_data(order) }
      }
    }
  end

  def show
    render json: {
      status: 'success',
      data: {
        order: order_data(@order)
      }
    }
  end

  def create
    unless current_customer
      render json: { status: 'error', message: 'Only customers can create orders.' }, status: :unauthorized
      return
    end

    @order = current_customer.orders.build(order_params)

    if @order.save
      create_order_items if params[:order_items].present?
      @order.calculate_total!

      render json: {
        status: 'success',
        message: 'Order created successfully.',
        data: {
          order: order_data(@order.reload)
        }
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'Order creation failed.',
        errors: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if current_merchant && @order.merchant == current_merchant
      update_order_status
    elsif current_customer && @order.customer == current_customer
      render json: { status: 'error', message: 'Customers cannot update orders.' }, status: :forbidden
    else
      render json: { status: 'error', message: 'Unauthorized.' }, status: :unauthorized
    end
  end

  private

  def authenticate_user!
    unless current_merchant || current_customer
      render json: { status: 'error', message: 'Authentication required.' }, status: :unauthorized
    end
  end

  def set_order
    @order = if current_merchant
      current_merchant.orders.find(params[:id])
    elsif current_customer
      current_customer.orders.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'Order not found.'
    }, status: :not_found
  end

  def order_params
    params.require(:order).permit(:merchant_id, :delivery_address, :delivery_time, :special_instructions)
  end

  def create_order_items
    params[:order_items].each do |item_params|
      if item_params[:product_id].present?
        @order.order_items.create!(
          product_id: item_params[:product_id],
          quantity: item_params[:quantity],
          price: Product.find(item_params[:product_id]).discounted_price
        )
      elsif item_params[:bundle_id].present?
        @order.order_items.create!(
          bundle_id: item_params[:bundle_id],
          quantity: item_params[:quantity],
          price: Bundle.find(item_params[:bundle_id]).total_price
        )
      end
    end
  end

  def update_order_status
    if @order.update(status: params[:status])
      render json: {
        status: 'success',
        message: 'Order status updated successfully.',
        data: {
          order: order_data(@order)
        }
      }
    else
      render json: {
        status: 'error',
        message: 'Order update failed.',
        errors: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def order_data(order)
    {
      id: order.id,
      status: order.status,
      total_amount: order.total_amount,
      delivery_address: order.delivery_address,
      delivery_time: order.delivery_time,
      special_instructions: order.special_instructions,
      merchant: {
        id: order.merchant.id,
        name: order.merchant.name
      },
      customer: {
        id: order.customer.id,
        name: order.customer.name
      },
      items: order.order_items.includes(:product, :bundle).map do |item|
        base_data = {
          id: item.id,
          quantity: item.quantity,
          price: item.price
        }

        if item.product
          base_data[:product] = {
            id: item.product.id,
            name: item.product.name,
            category: item.product.category
          }
        elsif item.bundle
          base_data[:bundle] = {
            id: item.bundle.id,
            name: item.bundle.name,
            description: item.bundle.description
          }
        end

        base_data
      end,
      created_at: order.created_at,
      updated_at: order.updated_at
    }
  end
end