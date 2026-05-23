'use client';

import Link from 'next/link';
import { Building2, Users, MapPin, HelpCircle, Heart, Image } from 'lucide-react';
import { useChurchInfo } from '@/hooks/useChurch';
import { PageHeader } from '@/components/shared/PageHeader';

const sections = [
  { href: '/church/settings', icon: Building2, label: 'General Settings', desc: 'Name, mission, vision, contact info' },
  { href: '/church/staff', icon: Users, label: 'Staff & Leadership', desc: 'Manage staff profiles and titles' },
  { href: '/church/campuses', icon: MapPin, label: 'Campuses & Locations', desc: 'Campuses, addresses, service times' },
  { href: '/church/faqs', icon: HelpCircle, label: 'FAQs', desc: 'Frequently asked questions' },
  { href: '/church/core-values', icon: Heart, label: 'Core Values', desc: 'Beliefs and core values of your church' },
  { href: '/church/media-branding', icon: Image, label: 'Media & Branding', desc: 'Logo, cover image, and timeline' },
];

export default function ChurchPage() {
  const { data: church, isLoading } = useChurchInfo();

  return (
    <div className="space-y-6">
      <PageHeader
        title="Church Settings"
        description={isLoading ? 'Loading…' : church?.name ?? 'Manage your church profile and settings'}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {sections.map(({ href, icon: Icon, label, desc }) => (
          <Link
            key={href}
            href={href}
            className="flex items-start gap-4 rounded-xl border border-slate-700 bg-slate-800 p-5 hover:bg-slate-700 transition-colors group"
          >
            <span className="flex h-10 w-10 items-center justify-center rounded-lg bg-indigo-500/20 text-indigo-400 group-hover:bg-indigo-500/30 shrink-0">
              <Icon className="h-5 w-5" />
            </span>
            <div>
              <p className="font-medium text-slate-100">{label}</p>
              <p className="text-sm text-slate-400 mt-0.5">{desc}</p>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
