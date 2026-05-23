'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard, Users, BookOpen, Calendar, HandCoins,
  Users2, Heart, MessageSquare, Image, Radio, Bell,
  UserCheck, Baby, Building2, Church, ChevronRight, LogOut,
} from 'lucide-react';
import { useAdminUser, useAdminLogout } from '@/hooks/useAdmin';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip';

const NAV_ITEMS = [
  { label: 'Overview', href: '/', icon: LayoutDashboard },
  { label: 'Members', href: '/members', icon: Users },
  { label: 'Sermons', href: '/sermons', icon: BookOpen },
  { label: 'Events', href: '/events', icon: Calendar },
  { label: 'Giving', href: '/giving', icon: HandCoins },
  { label: 'Groups', href: '/groups', icon: Users2 },
  { label: 'Prayer', href: '/prayer', icon: Heart },
  { label: 'Forum', href: '/forum', icon: MessageSquare },
  { label: 'Media', href: '/media', icon: Image },
  { label: 'Live', href: '/live', icon: Radio },
  { label: 'Notifications', href: '/notifications', icon: Bell },
  { label: 'Volunteer', href: '/volunteer', icon: UserCheck },
  { label: "Kid's Check-In", href: '/kids', icon: Baby },
  { label: 'Church Settings', href: '/church', icon: Building2 },
];

interface SidebarProps {
  collapsed?: boolean;
}

export function Sidebar({ collapsed = false }: SidebarProps) {
  const pathname = usePathname();
  const { data: user } = useAdminUser();
  const logout = useAdminLogout();

  function isActive(href: string) {
    if (href === '/') return pathname === '/';
    return pathname.startsWith(href);
  }

  function renderNavItem(label: string, href: string, icon: React.ElementType) {
    const Icon = icon as React.FC<{ className?: string }>;
    const active = isActive(href);

    const linkEl = (
      <Link
        href={href}
        className={cn(
          'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors',
          active
            ? 'bg-primary/10 text-primary'
            : 'text-slate-400 hover:text-slate-100 hover:bg-slate-800',
        )}
      >
        <Icon className={cn('w-5 h-5 shrink-0', active ? 'text-primary' : '')} />
        {!collapsed && <span className="truncate">{label}</span>}
        {!collapsed && active && <ChevronRight className="w-4 h-4 ml-auto text-primary" />}
      </Link>
    );

    if (collapsed) {
      return (
        <Tooltip key={href}>
          <TooltipTrigger render={<span />}>
            {linkEl}
          </TooltipTrigger>
          <TooltipContent side="right">{label}</TooltipContent>
        </Tooltip>
      );
    }

    return <span key={href}>{linkEl}</span>;
  }

  return (
    <aside
      className={cn(
        'flex flex-col h-full bg-slate-900 border-r border-slate-800 transition-all duration-200',
        collapsed ? 'w-16' : 'w-64',
      )}
    >
      {/* Brand */}
      <div className="flex items-center gap-3 px-4 py-5 border-b border-slate-800">
        <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center shrink-0">
          <Church className="w-5 h-5 text-primary-foreground" />
        </div>
        {!collapsed && (
          <div className="min-w-0">
            <p className="font-semibold text-white text-sm truncate">Church Admin</p>
            <p className="text-slate-400 text-xs truncate">{user?.church?.name ?? 'Dashboard'}</p>
          </div>
        )}
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto py-3 px-2 space-y-0.5">
        {NAV_ITEMS.map(({ label, href, icon }) => renderNavItem(label, href, icon))}
      </nav>

      <Separator className="bg-slate-800" />

      {/* User footer */}
      <div className="p-3">
        <div className={cn('flex items-center gap-3', collapsed ? 'justify-center' : '')}>
          <Avatar className="w-8 h-8 shrink-0">
            <AvatarImage src={user?.avatarUrl ?? ''} />
            <AvatarFallback className="bg-slate-700 text-slate-200 text-xs">
              {user?.name?.slice(0, 2).toUpperCase() ?? 'AD'}
            </AvatarFallback>
          </Avatar>
          {!collapsed && (
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-white truncate">{user?.name}</p>
              <Badge
                variant="outline"
                className="text-[10px] px-1.5 py-0 border-primary/40 text-primary"
              >
                {user?.role?.replace('_', ' ')}
              </Badge>
            </div>
          )}
          <button
            onClick={() => logout.mutate()}
            className="p-1.5 text-slate-400 hover:text-red-400 hover:bg-red-400/10 rounded-md transition-colors"
            title="Sign out"
          >
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </aside>
  );
}
