import { RegisterForm } from '@/components/auth/RegisterForm';

export default function CustomerRegisterPage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-green-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <RegisterForm role="customer" />
      </div>
    </div>
  );
}