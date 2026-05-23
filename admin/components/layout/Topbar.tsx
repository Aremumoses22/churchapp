'use client';

import { Bell, Menu, Moon, Sun } from 'lucide-react';
import { useTheme } from '@/hooks/useTheme';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';

interface TopbarProps {
  onMenuClick?: () => void;
  title: string;
}

export function Topbar({ onMenuClick, title }: TopbarProps) {
  const { theme, toggle } = useTheme();

  return (
    <header className="h-14 border-b border-slate-800 bg-slate-900/80 backdrop-blur-sm flex items-center gap-3 px-4 shrink-0">
      {onMenuClick && (
        <>
          <Button variant="ghost" size="icon" onClick={onMenuClick} className="text-slate-400 hover:text-slate-100 -ml-1">
            <Menu className="w-5 h-5" />
          </Button>
          <Separator orientation="vertical" className="h-5 bg-slate-700" />
        </>
      )}

      <h1 className="text-sm font-semibold text-slate-100 flex-1">{title}</h1>

      <div className="flex items-center gap-1">
        <Button
          variant="ghost"
          size="icon"
          onClick={toggle}
          className="text-slate-400 hover:text-slate-100"
          title={theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'}
        >
          {theme === 'dark' ? <Sun className="w-4 h-4" /> : <Moon className="w-4 h-4" />}
        </Button>

        <Button variant="ghost" size="icon" className="text-slate-400 hover:text-slate-100" title="Notifications">
          <Bell className="w-4 h-4" />
        </Button>
      </div>
    </header>
  );
}
