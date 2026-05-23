import { LayoutDashboard } from 'lucide-react';

export default function OverviewPage() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] text-center gap-4">
      <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center">
        <LayoutDashboard className="w-8 h-8 text-primary" />
      </div>
      <div>
        <h2 className="text-xl font-semibold text-slate-100">Overview Dashboard</h2>
        <p className="text-slate-400 text-sm mt-1">Analytics and stats coming in Phase 1</p>
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-4 w-full max-w-2xl">
        {['Total Members', 'This Month Giving', 'Upcoming Events', 'Active Groups'].map((label) => (
          <div key={label} className="bg-slate-800 border border-slate-700 rounded-xl p-4 text-left">
            <p className="text-xs text-slate-500 font-medium">{label}</p>
            <div className="h-7 w-16 bg-slate-700 rounded animate-pulse mt-2" />
          </div>
        ))}
      </div>
    </div>
  );
}
