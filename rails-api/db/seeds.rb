# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load demo data from JSON files
require 'json'

# Clear existing data (for development)
if Rails.env.development?
  OrderItem.destroy_all
  Order.destroy_all
  BundleItem.destroy_all
  Bundle.destroy_all
  Product.destroy_all
  Customer.destroy_all
  Merchant.destroy_all
end

puts "Loading demo merchants..."
merchants_file = File.read(Rails.root.join('..', 'demo', 'merchants', 'merchants.json'))
merchants_data = JSON.parse(merchants_file)

merchants_data.each do |merchant_data|
  merchant = Merchant.find_or_create_by!(email: merchant_data['email']) do |m|
    m.name = merchant_data['name']
    m.phone = merchant_data['phone']
    m.address = merchant_data['address']
    m.latitude = merchant_data['latitude']
    m.longitude = merchant_data['longitude']
    m.business_hours = merchant_data['business_hours']
    m.pickup_instructions = merchant_data['pickup_instructions']
    m.specialty = merchant_data['specialty']
    m.image = merchant_data['image']
    m.password = 'password123'
  end
  puts "  Created merchant: #{merchant.name}"
end

puts "Loading demo customers..."
customers_file = File.read(Rails.root.join('..', 'demo', 'customers', 'customers.json'))
customers_data = JSON.parse(customers_file)

customers_data.each do |customer_data|
  customer = Customer.find_or_create_by!(email: customer_data['email']) do |c|
    c.name = customer_data['name']
    c.phone = customer_data['phone']
    c.preferred_radius = customer_data['preferred_radius']
    c.dietary_preferences = customer_data['dietary_preferences']
    c.favorite_categories = customer_data['favorite_categories']
    c.password = 'password123'
  end
  puts "  Created customer: #{customer.name}"
end

puts "Loading demo products..."
products_file = File.read(Rails.root.join('..', 'demo', 'products', 'products.json'))
products_data = JSON.parse(products_file)

products_data.each do |product_data|
  merchant = Merchant.find_by(id: product_data['merchant_id'])
  next unless merchant

  product = Product.find_or_create_by!(
    merchant: merchant,
    name: product_data['name']
  ) do |p|
    p.description = product_data['description']
    p.category = product_data['category']
    p.original_price = product_data['original_price']
    p.discounted_price = product_data['discounted_price']
    p.discount_percentage = product_data['discount_percentage']
    p.available_quantity = product_data['available_quantity']
    p.allergens = product_data['allergens']
    p.dietary_tags = product_data['dietary_tags']
    p.expires_at = DateTime.parse(product_data['expires_at'])
    p.images = product_data['images']
  end
  puts "  Created product: #{product.name} at #{merchant.name}"
end

puts "Loading demo bundles..."
bundles_file = File.read(Rails.root.join('..', 'demo', 'products', 'bundles.json'))
bundles_data = JSON.parse(bundles_file)

bundles_data.each do |bundle_data|
  merchant = Merchant.find_by(id: bundle_data['merchant_id'])
  next unless merchant

  bundle = Bundle.find_or_create_by!(
    merchant: merchant,
    name: bundle_data['name']
  ) do |b|
    b.description = bundle_data['description']
    b.total_original_price = bundle_data['original_price']
    b.bundle_price = bundle_data['discounted_price']
    b.discount_percentage = bundle_data['discount_percentage']
    b.available_quantity = bundle_data['available_quantity']
    b.expires_at = DateTime.parse(bundle_data['expires_at'])
    b.image = bundle_data['images']&.first
  end

  # Add bundle items
  bundle_data['items']&.each do |item_data|
    product = Product.find_by(id: item_data['product_id'])
    next unless product

    BundleItem.find_or_create_by!(
      bundle: bundle,
      product: product
    ) do |bi|
      bi.quantity = item_data['quantity']
    end
  end

  puts "  Created bundle: #{bundle.name} at #{merchant.name}"
end

puts "\nDemo data loaded successfully!"
puts "- #{Merchant.count} merchants"
puts "- #{Customer.count} customers"
puts "- #{Product.count} products"
puts "- #{Bundle.count} bundles"
puts "- #{BundleItem.count} bundle items"
