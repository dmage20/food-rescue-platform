import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import Cookies from 'js-cookie';
import { AuthResponse, LoginCredentials, RegisterData, UserRole } from '@/types';

// API configuration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';

// Create axios instance
const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// Token management
export const TOKEN_KEY = 'auth_token';
export const USER_ROLE_KEY = 'user_role';

export const getToken = (): string | null => {
  if (typeof window === 'undefined') return null;
  return Cookies.get(TOKEN_KEY) || null;
};

export const setToken = (token: string): void => {
  Cookies.set(TOKEN_KEY, token, { expires: 7, secure: true, sameSite: 'strict' });
};

export const removeToken = (): void => {
  Cookies.remove(TOKEN_KEY);
  Cookies.remove(USER_ROLE_KEY);
};

export const getUserRole = (): UserRole | null => {
  if (typeof window === 'undefined') return null;
  return (Cookies.get(USER_ROLE_KEY) as UserRole) || null;
};

export const setUserRole = (role: UserRole): void => {
  Cookies.set(USER_ROLE_KEY, role, { expires: 7, secure: true, sameSite: 'strict' });
};

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle auth errors
api.interceptors.response.use(
  (response: AxiosResponse) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid, clear auth data
      removeToken();
      // Redirect to login if on protected route
      if (typeof window !== 'undefined' && !window.location.pathname.includes('/auth')) {
        window.location.href = '/auth/login';
      }
    }
    return Promise.reject(error);
  }
);

// Authentication API
export const authApi = {
  // Customer authentication
  customerLogin: async (credentials: LoginCredentials): Promise<AuthResponse> => {
    const response = await api.post('/customers/sign_in', credentials);
    return response.data;
  },

  customerRegister: async (data: RegisterData): Promise<AuthResponse> => {
    const response = await api.post('/customers', data);
    return response.data;
  },

  customerLogout: async (): Promise<void> => {
    await api.delete('/customers/sign_out');
  },

  // Merchant authentication
  merchantLogin: async (credentials: LoginCredentials): Promise<AuthResponse> => {
    const response = await api.post('/merchants/sign_in', credentials);
    return response.data;
  },

  merchantRegister: async (data: RegisterData): Promise<AuthResponse> => {
    const response = await api.post('/merchants', data);
    return response.data;
  },

  merchantLogout: async (): Promise<void> => {
    await api.delete('/merchants/sign_out');
  },

  // Get current user
  getCurrentUser: async (role: UserRole) => {
    const endpoint = role === 'customer' ? '/customer' : '/merchant';
    const response = await api.get(endpoint);
    return response.data;
  },
};

// Customer API
export const customerApi = {
  getProfile: async () => {
    const response = await api.get('/customer');
    return response.data;
  },

  updateProfile: async (data: Partial<any>) => {
    const response = await api.put('/customer', data);
    return response.data;
  },

  // Browse products
  browseProducts: async (filters?: any) => {
    const response = await api.get('/browse/products', { params: filters });
    return response.data;
  },

  browseBundles: async (filters?: any) => {
    const response = await api.get('/browse/bundles', { params: filters });
    return response.data;
  },

  browseMerchants: async (filters?: any) => {
    const response = await api.get('/browse/merchants', { params: filters });
    return response.data;
  },

  // Orders
  getOrders: async () => {
    const response = await api.get('/orders');
    return response.data;
  },

  createOrder: async (orderData: any) => {
    const response = await api.post('/orders', orderData);
    return response.data;
  },

  getOrder: async (id: number) => {
    const response = await api.get(`/orders/${id}`);
    return response.data;
  },
};

// Merchant API
export const merchantApi = {
  getProfile: async () => {
    const response = await api.get('/merchant');
    return response.data;
  },

  updateProfile: async (data: Partial<any>) => {
    const response = await api.put('/merchant', data);
    return response.data;
  },

  // Products
  getProducts: async () => {
    const response = await api.get('/products');
    return response.data;
  },

  createProduct: async (productData: any) => {
    const response = await api.post('/products', productData);
    return response.data;
  },

  updateProduct: async (id: number, productData: any) => {
    const response = await api.put(`/products/${id}`, productData);
    return response.data;
  },

  deleteProduct: async (id: number) => {
    await api.delete(`/products/${id}`);
  },

  // Bundles
  getBundles: async () => {
    const response = await api.get('/bundles');
    return response.data;
  },

  createBundle: async (bundleData: any) => {
    const response = await api.post('/bundles', bundleData);
    return response.data;
  },

  updateBundle: async (id: number, bundleData: any) => {
    const response = await api.put(`/bundles/${id}`, bundleData);
    return response.data;
  },

  deleteBundle: async (id: number) => {
    await api.delete(`/bundles/${id}`);
  },

  // Orders
  getOrders: async () => {
    const response = await api.get('/orders');
    return response.data;
  },

  updateOrder: async (id: number, status: string) => {
    const response = await api.put(`/orders/${id}`, { status });
    return response.data;
  },

  getOrder: async (id: number) => {
    const response = await api.get(`/orders/${id}`);
    return response.data;
  },
};

export default api;