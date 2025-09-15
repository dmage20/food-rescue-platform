import Link from 'next/link';
import { Button } from '@/components/ui/Button';

export default function Home() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-green-50 to-green-100">
      <div className="container mx-auto px-4 py-8">
        <header className="text-center mb-8">
          <h1 className="text-4xl font-bold text-green-800 mb-2">
            🥖 Food Rescue Platform
          </h1>
          <p className="text-lg text-green-600">
            Connecting bakeries and cafes with customers to reduce food waste
          </p>
        </header>

        <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-semibold text-gray-800 mb-4">
              For Customers
            </h2>
            <ul className="space-y-2 text-gray-600 mb-6">
              <li>🗺️ Discover nearby merchants</li>
              <li>🍞 Fresh goods at discounted prices</li>
              <li>📱 Mobile-first experience</li>
              <li>⏰ Flexible pickup windows</li>
            </ul>
            <div className="space-y-2">
              <Link href="/auth/customer/login" className="block">
                <Button className="w-full">Customer Login</Button>
              </Link>
              <Link href="/auth/customer/register" className="block">
                <Button variant="outline" className="w-full">Sign Up as Customer</Button>
              </Link>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-semibold text-gray-800 mb-4">
              For Merchants
            </h2>
            <ul className="space-y-2 text-gray-600 mb-6">
              <li>📊 Reduce food waste</li>
              <li>💰 Recover costs on surplus</li>
              <li>📸 Quick listing with photos</li>
              <li>📈 Track sales analytics</li>
            </ul>
            <div className="space-y-2">
              <Link href="/auth/merchant/login" className="block">
                <Button className="w-full">Merchant Login</Button>
              </Link>
              <Link href="/auth/merchant/register" className="block">
                <Button variant="outline" className="w-full">Sign Up as Merchant</Button>
              </Link>
            </div>
          </div>
        </div>

        <div className="text-center mt-8">
          <p className="text-green-700">
            Join the movement to reduce food waste while saving money! 🌱
          </p>
        </div>
      </div>
    </main>
  )
}