// User Types
export interface Customer {
  id: number;
  name: string;
  email: string;
  phone?: string;
  preferred_radius?: number;
  dietary_preferences?: {
    allergies?: string[];
    preferences?: string[];
    avoid?: string[];
  };
  favorite_categories?: string[];
  created_at: string;
}

export interface Merchant {
  id: number;
  name: string;
  email: string;
  phone?: string;
  business_name: string;
  business_type: string;
  address: string;
  latitude?: number;
  longitude?: number;
  description?: string;
  operating_hours?: Record<string, string>;
  created_at: string;
}

// Product Types
export interface Product {
  id: number;
  merchant_id: number;
  name: string;
  description: string;
  category: string;
  original_price: number;
  discounted_price: number;
  discount_percentage: number;
  available_quantity: number;
  allergens: string[];
  dietary_tags: string[];
  expires_at: string;
  images: string[];
  created_at?: string;
  updated_at?: string;
}

export interface Bundle {
  id: number;
  merchant_id: number;
  name: string;
  description: string;
  original_price: number;
  discounted_price: number;
  discount_percentage: number;
  available_quantity: number;
  pickup_window_start: string;
  pickup_window_end: string;
  contents: string[];
  allergens: string[];
  dietary_tags: string[];
  images: string[];
  created_at?: string;
  updated_at?: string;
}

// Order Types
export interface OrderItem {
  id?: number;
  order_id?: number;
  product_id?: number;
  bundle_id?: number;
  quantity: number;
  unit_price: number;
  product?: Product;
  bundle?: Bundle;
}

export interface Order {
  id: number;
  customer_id: number;
  merchant_id: number;
  status: 'pending' | 'confirmed' | 'ready' | 'completed' | 'cancelled';
  total_amount: number;
  pickup_time: string;
  special_instructions?: string;
  items: OrderItem[];
  customer?: Customer;
  merchant?: Merchant;
  created_at: string;
  updated_at: string;
}

// Authentication Types
export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  name: string;
  email: string;
  password: string;
  password_confirmation: string;
  phone?: string;
  // Merchant-specific fields
  business_name?: string;
  business_type?: string;
  address?: string;
  description?: string;
}

export interface AuthResponse {
  user: Customer | Merchant;
  token: string;
}

// Cart Types
export interface CartItem {
  type: 'product' | 'bundle';
  id: number;
  quantity: number;
  item: Product | Bundle;
  merchant_id: number;
}

export interface Cart {
  items: CartItem[];
  total: number;
  merchant_id?: number; // Only one merchant per cart
}

// API Response Types
export interface ApiResponse<T> {
  data: T;
  message?: string;
  errors?: string[];
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    current_page: number;
    per_page: number;
    total_pages: number;
    total_count: number;
  };
}

// Filter Types
export interface ProductFilters {
  search?: string;
  category?: string;
  merchant_id?: number;
  latitude?: number;
  longitude?: number;
  radius?: number;
  min_price?: number;
  max_price?: number;
  dietary_tags?: string[];
  exclude_allergens?: string[];
  available_only?: boolean;
}

// User role type
export type UserRole = 'customer' | 'merchant';

// Form error type
export interface FormErrors {
  [key: string]: string | string[];
}

// Location type
export interface Location {
  latitude: number;
  longitude: number;
  address?: string;
}

// Notification type
export interface Notification {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  title: string;
  message: string;
  duration?: number;
}