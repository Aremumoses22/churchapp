'use client';

import { useState, useEffect } from 'react';

export function useTheme() {
  const [theme, setTheme] = useState<'dark' | 'light'>('dark');

  useEffect(() => {
    const stored = localStorage.getItem('admin_theme') as 'dark' | 'light' | null;
    const initial = stored || 'dark';
    setTheme(initial);
    document.documentElement.classList.toggle('dark', initial === 'dark');
  }, []);

  function toggle() {
    const next = theme === 'dark' ? 'light' : 'dark';
    setTheme(next);
    localStorage.setItem('admin_theme', next);
    document.documentElement.classList.toggle('dark', next === 'dark');
  }

  return { theme, toggle };
}
