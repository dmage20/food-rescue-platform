import type { Metadata } from 'next'
import './globals.css'
import { Providers } from '@/providers/Providers'
import { Navigation } from '@/components/layout/Navigation'

export const metadata: Metadata = {
  title: 'Food Rescue Platform',
  description: 'Connecting bakeries and cafes with customers to reduce food waste',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <Providers>
          <Navigation />
          {children}
        </Providers>
      </body>
    </html>
  )
}