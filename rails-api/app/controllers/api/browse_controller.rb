class Api::BrowseController < ApplicationController
  before_action :authenticate_customer!, except: [:merchants, :products, :bundles]

  def merchants
    @merchants = Merchant.includes(:products, :bundles)

    if params[:latitude] && params[:longitude]
      radius = params[:radius]&.to_f || 5.0
      @merchants = @merchants.nearby(params[:latitude], params[:longitude], radius)
    end

    render json: {
      status: 'success',
      data: {
        merchants: @merchants.map { |merchant| merchant_browse_data(merchant) }
      }
    }
  end

  def products
    @products = Product.includes(:merchant).where('available_quantity > 0').where('expires_at > ?', Time.current)

    # Filter by location if provided
    if params[:latitude] && params[:longitude]
      radius = params[:radius]&.to_f || 5.0
      merchant_ids = Merchant.nearby(params[:latitude], params[:longitude], radius).pluck(:id)
      @products = @products.where(merchant_id: merchant_ids)
    end

    # Filter by category
    @products = @products.where(category: params[:category]) if params[:category].present?

    # Filter by price range
    @products = @products.where('discounted_price >= ?', params[:min_price]) if params[:min_price].present?
    @products = @products.where('discounted_price <= ?', params[:max_price]) if params[:max_price].present?

    # Search by name
    @products = @products.where('name ILIKE ?', "%#{params[:search]}%") if params[:search].present?

    # Order by expiry date (most urgent first)
    @products = @products.order(:expires_at)

    render json: {
      status: 'success',
      data: {
        products: @products.map { |product| product_browse_data(product) }
      }
    }
  end

  def bundles
    @bundles = Bundle.includes(:merchant, :bundle_items).where('available_quantity > 0').where('expires_at > ?', Time.current)

    # Filter by location if provided
    if params[:latitude] && params[:longitude]
      radius = params[:radius]&.to_f || 5.0
      merchant_ids = Merchant.nearby(params[:latitude], params[:longitude], radius).pluck(:id)
      @bundles = @bundles.where(merchant_id: merchant_ids)
    end

    # Filter by price range
    @bundles = @bundles.where('total_price >= ?', params[:min_price]) if params[:min_price].present?
    @bundles = @bundles.where('total_price <= ?', params[:max_price]) if params[:max_price].present?

    # Search by name
    @bundles = @bundles.where('name ILIKE ?', "%#{params[:search]}%") if params[:search].present?

    # Order by expiry date (most urgent first)
    @bundles = @bundles.order(:expires_at)

    render json: {
      status: 'success',
      data: {
        bundles: @bundles.map { |bundle| bundle_browse_data(bundle) }
      }
    }
  end

  private

  def merchant_browse_data(merchant)
    {
      id: merchant.id,
      name: merchant.name,
      address: merchant.address,
      latitude: merchant.latitude,
      longitude: merchant.longitude,
      available_products_count: merchant.available_products.count,
      available_bundles_count: merchant.available_bundles.count
    }
  end

  def product_browse_data(product)
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
        name: product.merchant.name,
        address: product.merchant.address
      }
    }
  end

  def bundle_browse_data(bundle)
    {
      id: bundle.id,
      name: bundle.name,
      description: bundle.description,
      total_price: bundle.total_price,
      available_quantity: bundle.available_quantity,
      expires_at: bundle.expires_at,
      item_count: bundle.bundle_items.count,
      merchant: {
        id: bundle.merchant.id,
        name: bundle.merchant.name,
        address: bundle.merchant.address
      }
    }
  end
end