interface ChartCardProps {
  title: string;
  description?: string;
  loading?: boolean;
  children: React.ReactNode;
}

export function ChartCard({ title, description, loading, children }: ChartCardProps) {
  return (
    <div className="bg-slate-800 border border-slate-700 rounded-xl p-5">
      <div className="mb-4">
        <h3 className="text-sm font-semibold text-slate-100">{title}</h3>
        {description && <p className="text-xs text-slate-400 mt-0.5">{description}</p>}
      </div>
      {loading ? (
        <div className="h-48 rounded-lg bg-slate-700 animate-pulse" />
      ) : children}
    </div>
  );
}
