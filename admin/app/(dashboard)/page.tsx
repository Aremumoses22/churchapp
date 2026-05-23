'use client';

import { useOverviewStats, useGivingTrend, useAttendanceTrend, useMembershipGrowth, useEngagement } from '@/hooks/useAnalytics';
import { StatCard } from '@/components/shared/StatCard';
import { PageHeader } from '@/components/shared/PageHeader';
import { ChartCard } from '@/components/shared/ChartCard';
import { formatCurrency, formatNumber } from '@/lib/format';
import {
  Users, HandCoins, Calendar, Heart, Users2,
  PlayCircle, UserCheck, MessageSquare,
} from 'lucide-react';
import {
  BarChart, Bar, LineChart, Line, AreaChart, Area,
  XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid,
} from 'recharts';

export default function OverviewPage() {
  const stats = useOverviewStats();
  const givingTrend = useGivingTrend();
  const attendanceTrend = useAttendanceTrend();
  const memberGrowth = useMembershipGrowth();
  const engagement = useEngagement();

  const s = stats.data;
  const isLoading = stats.isLoading;

  return (
    <div className="space-y-6">
      <PageHeader title="Overview" description="Church health at a glance" />

      {/* Stat cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard label="Total Members" value={isLoading ? '—' : formatNumber(s?.totalMembers ?? 0)} icon={Users} trend={s?.newMembersThisMonth} trendLabel="new this month" loading={isLoading} />
        <StatCard label="Giving YTD" value={isLoading ? '—' : formatCurrency(s?.totalDonationsYTD ?? 0)} icon={HandCoins} trendLabel="month to date" trend={s?.totalDonationsMTD} loading={isLoading} />
        <StatCard label="Upcoming Events" value={isLoading ? '—' : formatNumber(s?.upcomingEvents ?? 0)} icon={Calendar} loading={isLoading} />
        <StatCard label="Prayer Requests" value={isLoading ? '—' : formatNumber(s?.activePrayerRequests ?? 0)} icon={Heart} loading={isLoading} />
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard label="Active Groups" value={isLoading ? '—' : formatNumber(s?.activeGroups ?? 0)} icon={Users2} loading={isLoading} />
        <StatCard label="Giving MTD" value={isLoading ? '—' : formatCurrency(s?.totalDonationsMTD ?? 0)} icon={HandCoins} loading={isLoading} />
        <StatCard label="New Members" value={isLoading ? '—' : formatNumber(s?.newMembersThisMonth ?? 0)} icon={UserCheck} trendLabel="this month" loading={isLoading} />
        <StatCard label="Live Viewers" value={isLoading ? '—' : formatNumber(s?.liveServiceViewers ?? 0)} icon={PlayCircle} loading={isLoading} />
      </div>

      {/* Charts row 1 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <ChartCard title="Giving Trend" description="Monthly total (last 12 months)" loading={givingTrend.isLoading}>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={givingTrend.data ?? []} margin={{ top: 4, right: 4, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#334155" vertical={false} />
              <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} tickFormatter={(v) => `₦${(v / 1000).toFixed(0)}k`} />
              <Tooltip formatter={(v) => formatCurrency(Number(v ?? 0))} contentStyle={{ background: '#1e293b', border: '1px solid #334155', borderRadius: 8 }} labelStyle={{ color: '#cbd5e1' }} itemStyle={{ color: '#38bdf8' }} />
              <Bar dataKey="total" fill="#38bdf8" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Attendance Trend" description="Weekly attendance (last 12 weeks)" loading={attendanceTrend.isLoading}>
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={attendanceTrend.data ?? []} margin={{ top: 4, right: 4, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#334155" vertical={false} />
              <XAxis dataKey="week" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ background: '#1e293b', border: '1px solid #334155', borderRadius: 8 }} labelStyle={{ color: '#cbd5e1' }} itemStyle={{ color: '#34d399' }} />
              <Line type="monotone" dataKey="count" stroke="#34d399" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      {/* Charts row 2 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <ChartCard title="Membership Growth" description="New members per month (last 12 months)" loading={memberGrowth.isLoading}>
          <ResponsiveContainer width="100%" height={200}>
            <AreaChart data={memberGrowth.data ?? []} margin={{ top: 4, right: 4, left: 0, bottom: 0 }}>
              <defs>
                <linearGradient id="growthGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#818cf8" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="#818cf8" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#334155" vertical={false} />
              <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ background: '#1e293b', border: '1px solid #334155', borderRadius: 8 }} labelStyle={{ color: '#cbd5e1' }} itemStyle={{ color: '#818cf8' }} />
              <Area type="monotone" dataKey="newMembers" stroke="#818cf8" strokeWidth={2} fill="url(#growthGrad)" />
            </AreaChart>
          </ResponsiveContainer>
        </ChartCard>

        {/* Engagement stats */}
        <ChartCard title="Engagement (Last 30 Days)" description="Activity across all features" loading={engagement.isLoading}>
          <div className="grid grid-cols-2 gap-4 py-4">
            {[
              { label: 'Sermon Plays', value: engagement.data?.sermonPlays ?? 0, icon: PlayCircle, color: 'text-sky-400' },
              { label: 'Event Registrations', value: engagement.data?.eventRegistrations ?? 0, icon: Calendar, color: 'text-emerald-400' },
              { label: 'Forum Posts', value: engagement.data?.forumPosts ?? 0, icon: MessageSquare, color: 'text-violet-400' },
              { label: 'Prayer Interactions', value: engagement.data?.prayerInteractions ?? 0, icon: Heart, color: 'text-rose-400' },
            ].map(({ label, value, icon: Icon, color }) => (
              <div key={label} className="flex items-center gap-3 bg-slate-700/40 rounded-xl p-4">
                <Icon className={`w-8 h-8 ${color} shrink-0`} />
                <div>
                  <p className="text-2xl font-bold text-slate-100">{formatNumber(value)}</p>
                  <p className="text-xs text-slate-400">{label}</p>
                </div>
              </div>
            ))}
          </div>
        </ChartCard>
      </div>
    </div>
  );
}
