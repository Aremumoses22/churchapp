import { LucideIcon, TrendingUp, TrendingDown } from 'lucide-react';
import { cn } from '@/lib/utils';

interface StatCardProps {
  label: string;
  value: string | number;
  icon: LucideIcon;
  trend?: number;
  trendLabel?: string;
  loading?: boolean;
}

export function StatCard({ label, value, icon: Icon, trend, trendLabel, loading }: StatCardProps) {
  const isPositive = (trend ?? 0) >= 0;

  return (
    <div className="bg-slate-800 border border-slate-700 rounded-xl p-5">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-xs font-medium text-slate-400 uppercase tracking-wide">{label}</p>
          {loading ? (
            <div className="h-8 w-24 bg-slate-700 rounded animate-pulse mt-2" />
          ) : (
            <p className="text-2xl font-bold text-slate-100 mt-1">{value}</p>
          )}
        </div>
        <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center">
          <Icon className="w-5 h-5 text-primary" />
        </div>
      </div>

      {trend !== undefined && trendLabel && !loading && (
        <div className={cn('flex items-center gap-1 mt-3 text-xs font-medium', isPositive ? 'text-emerald-400' : 'text-red-400')}>
          {isPositive ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
          <span>{Math.abs(trend)}% {trendLabel}</span>
        </div>
      )}
    </div>
  );
}
