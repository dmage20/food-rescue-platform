import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { CartItem, Cart, Product, Bundle } from '@/types';

interface CartState {
  items: CartItem[];
  merchantId: number | null;
  isOpen: boolean;
}

interface CartActions {
  addItem: (item: Product | Bundle, type: 'product' | 'bundle', quantity?: number) => void;
  removeItem: (type: 'product' | 'bundle', id: number) => void;
  updateQuantity: (type: 'product' | 'bundle', id: number, quantity: number) => void;
  clearCart: () => void;
  openCart: () => void;
  closeCart: () => void;
  toggleCart: () => void;
  getTotal: () => number;
  getItemCount: () => number;
  canAddItem: (merchantId: number) => boolean;
}

type CartStore = CartState & CartActions;

export const useCartStore = create<CartStore>()(
  persist(
    (set, get) => ({
      // Initial state
      items: [],
      merchantId: null,
      isOpen: false,

      // Actions
      addItem: (item: Product | Bundle, type: 'product' | 'bundle', quantity = 1) => {
        const { items, merchantId, canAddItem } = get();

        // Check if we can add items from this merchant
        if (!canAddItem(item.merchant_id)) {
          throw new Error('Cannot add items from different merchants to the same cart. Please checkout first or clear your cart.');
        }

        // Check if item already exists in cart
        const existingItemIndex = items.findIndex(
          cartItem => cartItem.type === type && cartItem.id === item.id
        );

        let newItems: CartItem[];

        if (existingItemIndex >= 0) {
          // Update quantity of existing item
          newItems = [...items];
          newItems[existingItemIndex].quantity += quantity;
        } else {
          // Add new item
          const newItem: CartItem = {
            type,
            id: item.id,
            quantity,
            item,
            merchant_id: item.merchant_id,
          };
          newItems = [...items, newItem];
        }

        set({
          items: newItems,
          merchantId: merchantId || item.merchant_id,
        });
      },

      removeItem: (type: 'product' | 'bundle', id: number) => {
        const { items } = get();
        const newItems = items.filter(item => !(item.type === type && item.id === id));

        set({
          items: newItems,
          merchantId: newItems.length > 0 ? newItems[0].merchant_id : null,
        });
      },

      updateQuantity: (type: 'product' | 'bundle', id: number, quantity: number) => {
        if (quantity <= 0) {
          get().removeItem(type, id);
          return;
        }

        const { items } = get();
        const newItems = items.map(item => {
          if (item.type === type && item.id === id) {
            return { ...item, quantity };
          }
          return item;
        });

        set({ items: newItems });
      },

      clearCart: () => {
        set({
          items: [],
          merchantId: null,
          isOpen: false,
        });
      },

      openCart: () => {
        set({ isOpen: true });
      },

      closeCart: () => {
        set({ isOpen: false });
      },

      toggleCart: () => {
        set(state => ({ isOpen: !state.isOpen }));
      },

      getTotal: () => {
        const { items } = get();
        return items.reduce((total, cartItem) => {
          return total + (cartItem.item.discounted_price * cartItem.quantity);
        }, 0);
      },

      getItemCount: () => {
        const { items } = get();
        return items.reduce((count, item) => count + item.quantity, 0);
      },

      canAddItem: (merchantId: number) => {
        const { merchantId: currentMerchantId, items } = get();
        // Allow if cart is empty or same merchant
        return items.length === 0 || currentMerchantId === merchantId;
      },
    }),
    {
      name: 'cart-storage',
      partialize: (state) => ({
        items: state.items,
        merchantId: state.merchantId,
        // Don't persist isOpen state
      }),
    }
  )
);

// Utility hook for cart summary
export const useCartSummary = () => {
  const { items, getTotal, getItemCount } = useCartStore();

  return {
    items,
    total: getTotal(),
    itemCount: getItemCount(),
    isEmpty: items.length === 0,
  };
};