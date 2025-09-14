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
            <ul className="space-y-2 text-gray-600">
              <li>🗺️ Discover nearby merchants</li>
              <li>🍞 Fresh goods at discounted prices</li>
              <li>📱 Mobile-first experience</li>
              <li>⏰ Flexible pickup windows</li>
            </ul>
          </div>

          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-semibold text-gray-800 mb-4">
              For Merchants
            </h2>
            <ul className="space-y-2 text-gray-600">
              <li>📊 Reduce food waste</li>
              <li>💰 Recover costs on surplus</li>
              <li>📸 Quick listing with photos</li>
              <li>📈 Track sales analytics</li>
            </ul>
          </div>
        </div>

        <div className="text-center mt-8">
          <p className="text-green-700">
            Platform is in development. Check back soon! 🌱
          </p>
        </div>
      </div>
    </main>
  )
}