'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { formatPrice } from '@/lib/utils';
import {
  DollarSignIcon,
  ShoppingBagIcon,
  PackageIcon,
  TrendingUpIcon,
  CalendarIcon,
  ClockIcon
} from 'lucide-react';

interface DashboardStatsProps {
  stats: {
    todayOrders: number;
    todayRevenue: number;
    activeProducts: number;
    activeBundles: number;
    weeklyOrders: number;
    weeklyRevenue: number;
    averageOrderValue: number;
    wasteReduced: number; // in pounds
  };
}

export function DashboardStats({ stats }: DashboardStatsProps) {
  const statCards = [
    {
      title: "Today's Revenue",
      value: formatPrice(stats.todayRevenue),
      change: "+12%",
      changeType: "positive" as const,
      icon: DollarSignIcon,
      description: "vs yesterday"
    },
    {
      title: "Today's Orders",
      value: stats.todayOrders.toString(),
      change: "+5",
      changeType: "positive" as const,
      icon: ShoppingBagIcon,
      description: "new orders"
    },
    {
      title: "Active Products",
      value: stats.activeProducts.toString(),
      change: `${stats.activeBundles} bundles`,
      changeType: "positive" as const,
      icon: PackageIcon,
      description: "currently available"
    },
    {
      title: "Weekly Revenue",
      value: formatPrice(stats.weeklyRevenue),
      change: "+18%",
      changeType: "positive" as const,
      icon: TrendingUpIcon,
      description: "vs last week"
    },
    {
      title: "Avg Order Value",
      value: formatPrice(stats.averageOrderValue),
      change: "+8%",
      changeType: "positive" as const,
      icon: CalendarIcon,
      description: "this week"
    },
    {
      title: "Food Waste Reduced",
      value: `${stats.wasteReduced}lbs`,
      change: "This month",
      changeType: "positive" as const,
      icon: ClockIcon,
      description: "environmental impact"
    }
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {statCards.map((stat, index) => {
        const Icon = stat.icon;
        return (
          <Card key={index}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                {stat.title}
              </CardTitle>
              <Icon className="h-4 w-4 text-gray-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-gray-900 mb-1">
                {stat.value}
              </div>
              <div className="flex items-center space-x-1 text-sm">
                <span className={`font-medium ${
                  stat.changeType === 'positive' ? 'text-green-600' :
                  stat.changeType === 'negative' ? 'text-red-600' :
                  'text-gray-600'
                }`}>
                  {stat.change}
                </span>
                <span className="text-gray-500">{stat.description}</span>
              </div>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}