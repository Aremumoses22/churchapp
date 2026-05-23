'use client';

import { useState } from 'react';
import { usePathname } from 'next/navigation';
import { AuthGuard } from '@/components/shared/AuthGuard';
import { Sidebar } from '@/components/layout/Sidebar';
import { Topbar } from '@/components/layout/Topbar';

const PAGE_TITLES: Record<string, string> = {
  '/': 'Overview',
  '/members': 'Members',
  '/sermons': 'Sermons',
  '/events': 'Events',
  '/giving': 'Giving',
  '/groups': 'Groups',
  '/prayer': 'Prayer Requests',
  '/forum': 'Forum',
  '/media': 'Media',
  '/live': 'Live Service',
  '/notifications': 'Notifications',
  '/volunteer': 'Volunteer',
  '/kids': "Kid's Check-In",
  '/church': 'Church Settings',
};

function getTitle(pathname: string): string {
  if (pathname === '/') return 'Overview';
  const key = Object.keys(PAGE_TITLES).find((k) => k !== '/' && pathname.startsWith(k));
  return key ? PAGE_TITLES[key] : 'Admin Dashboard';
}

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const pathname = usePathname();

  return (
    <AuthGuard>
      <div className="flex h-screen overflow-hidden bg-slate-950">
        <Sidebar collapsed={collapsed} />
        <div className="flex flex-col flex-1 min-w-0 overflow-hidden">
          <Topbar
            title={getTitle(pathname)}
            onMenuClick={() => setCollapsed((c) => !c)}
          />
          <main className="flex-1 overflow-y-auto p-6">{children}</main>
        </div>
      </div>
    </AuthGuard>
  );
}
