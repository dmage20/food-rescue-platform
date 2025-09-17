import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import {
  Customer,
  Merchant,
  UserRole,
  LoginCredentials,
  RegisterData,
  AuthResponse
} from '@/types';
import {
  authApi,
  setToken,
  removeToken,
  setUserRole,
  getToken,
  getUserRole
} from '@/lib/api';

interface AuthState {
  user: Customer | Merchant | null;
  role: UserRole | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}

interface AuthActions {
  login: (credentials: LoginCredentials, role: UserRole) => Promise<void>;
  register: (data: RegisterData, role: UserRole) => Promise<void>;
  logout: () => Promise<void>;
  getCurrentUser: () => Promise<void>;
  clearError: () => void;
  initialize: () => void;
}

type AuthStore = AuthState & AuthActions;

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      // Initial state
      user: null,
      role: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      // Actions
      login: async (credentials: LoginCredentials, role: UserRole) => {
        set({ isLoading: true, error: null });

        try {
          const authFunction = role === 'customer' ? authApi.customerLogin : authApi.merchantLogin;
          const response: AuthResponse = await authFunction(credentials);

          // Store token and role
          setToken(response.token);
          setUserRole(role);

          set({
            user: response.user,
            role: role,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error: any) {
          const errorMessage = error.response?.data?.message || 'Login failed';
          set({
            error: errorMessage,
            isLoading: false,
            isAuthenticated: false,
          });
          throw error;
        }
      },

      register: async (data: RegisterData, role: UserRole) => {
        set({ isLoading: true, error: null });

        try {
          const authFunction = role === 'customer' ? authApi.customerRegister : authApi.merchantRegister;
          const response: AuthResponse = await authFunction(data);

          // Store token and role
          setToken(response.token);
          setUserRole(role);

          set({
            user: response.user,
            role: role,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error: any) {
          // Extract error message from response
          let errorMessage = 'Registration failed';
          
          if (error.response?.data?.message) {
            errorMessage = error.response.data.message;
          } else if (error.response?.data?.errors && Array.isArray(error.response.data.errors)) {
            errorMessage = error.response.data.errors.join(', ');
          } else if (error.message) {
            errorMessage = error.message;
          }
          
          set({
            error: errorMessage,
            isLoading: false,
            isAuthenticated: false,
          });
          throw error;
        }
      },

      logout: async () => {
        set({ isLoading: true });

        try {
          const { role } = get();
          if (role) {
            const logoutFunction = role === 'customer' ? authApi.customerLogout : authApi.merchantLogout;
            await logoutFunction();
          }
        } catch (error) {
          // Continue with logout even if API call fails
          console.error('Logout API call failed:', error);
        } finally {
          // Clear all auth data
          removeToken();
          set({
            user: null,
            role: null,
            isAuthenticated: false,
            isLoading: false,
            error: null,
          });
        }
      },

      getCurrentUser: async () => {
        const token = getToken();
        const role = getUserRole();

        if (!token || !role) {
          set({
            user: null,
            role: null,
            isAuthenticated: false,
            isLoading: false,
          });
          return;
        }

        set({ isLoading: true });

        try {
          const user = await authApi.getCurrentUser(role);
          set({
            user: user,
            role: role,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error: any) {
          // Token might be invalid, clear auth data
          removeToken();
          set({
            user: null,
            role: null,
            isAuthenticated: false,
            isLoading: false,
            error: null,
          });
        }
      },

      clearError: () => {
        set({ error: null });
      },

      initialize: () => {
        const token = getToken();
        const role = getUserRole();

        if (token && role) {
          // Set initial authenticated state and fetch current user
          set({
            role: role,
            isAuthenticated: true,
          });

          // Fetch current user data
          get().getCurrentUser();
        } else {
          set({
            user: null,
            role: null,
            isAuthenticated: false,
            isLoading: false,
          });
        }
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        // Only persist user data and role, not loading/error states
        user: state.user,
        role: state.role,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

// Utility hooks for specific user types
export const useCustomer = () => {
  const { user, role, isAuthenticated } = useAuthStore();
  return {
    customer: role === 'customer' ? (user as Customer) : null,
    isCustomer: role === 'customer' && isAuthenticated,
  };
};

export const useMerchant = () => {
  const { user, role, isAuthenticated } = useAuthStore();
  return {
    merchant: role === 'merchant' ? (user as Merchant) : null,
    isMerchant: role === 'merchant' && isAuthenticated,
  };
};