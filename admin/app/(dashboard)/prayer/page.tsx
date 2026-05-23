'use client';

import { useState } from 'react';
import { Search, Trash2, Loader2, HeartHandshake, AlertTriangle, Filter } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { usePrayerRequests, useUpdatePrayerStatus, useDeletePrayerRequest, type PrayerRequest } from '@/hooks/usePrayer';
import { formatDate } from '@/lib/format';

const STATUS_COLORS: Record<string, string> = {
  ACTIVE: 'bg-emerald-500/20 text-emerald-400',
  ANSWERED: 'bg-indigo-500/20 text-indigo-400',
  CLOSED: 'bg-slate-700 text-slate-400',
};

export default function PrayerPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const [deleteTarget, setDeleteTarget] = useState<PrayerRequest | null>(null);

  const { data, isLoading } = usePrayerRequests({ page, limit: 20, search: search || undefined, status: status || undefined });
  const updateStatus = useUpdatePrayerStatus();
  const deletePrayer = useDeletePrayerRequest();

  const requests = data?.requests ?? [];

  return (
    <div className="space-y-6">
      <PageHeader title="Prayer Requests" description="Manage and respond to prayer requests from members" />

      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search prayer requests…" className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 pointer-events-none" />
          <select value={status} onChange={e => { setStatus(e.target.value); setPage(1); }} className="rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-8 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none appearance-none cursor-pointer">
            <option value="">All Status</option>
            {['ACTIVE', 'ANSWERED', 'CLOSED'].map(s => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : requests.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500"><HeartHandshake className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No prayer requests found</p></div>
      ) : (
        <div className="space-y-3">
          {requests.map(req => (
            <div key={req.id} className="rounded-xl border border-slate-700 bg-slate-800 p-5 space-y-3">
              <div className="flex items-start gap-3">
                {req.user.avatarUrl ? (
                  <img src={req.user.avatarUrl} alt="" className="h-9 w-9 rounded-full object-cover shrink-0 border border-slate-700" />
                ) : (
                  <span className="h-9 w-9 rounded-full bg-slate-700 flex items-center justify-center shrink-0 text-sm font-bold text-slate-300">{req.isAnonymous ? '?' : req.user.name[0]}</span>
                )}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <p className="font-semibold text-slate-100">{req.title}</p>
                    <div className="flex items-center gap-2 shrink-0">
                      {req.isUrgent && <span className="flex items-center gap-1 rounded-full bg-red-500/20 px-2 py-0.5 text-xs text-red-400"><AlertTriangle className="h-3 w-3" /> Urgent</span>}
                      <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_COLORS[req.status] ?? 'bg-slate-700 text-slate-400'}`}>{req.status}</span>
                    </div>
                  </div>
                  <p className="text-xs text-slate-400 mt-0.5">{req.isAnonymous ? 'Anonymous' : req.user.name} · {formatDate(req.createdAt)} · 🙏 {req.prayerCount}</p>
                </div>
              </div>
              <p className="text-sm text-slate-300 leading-relaxed line-clamp-3">{req.content}</p>
              <div className="flex items-center justify-between pt-1">
                <div className="flex gap-2">
                  {(['ACTIVE', 'ANSWERED', 'CLOSED'] as const).filter(s => s !== req.status).map(s => (
                    <button key={s} onClick={() => updateStatus.mutate({ id: req.id, status: s })} disabled={updateStatus.isPending} className="rounded-lg border border-slate-600 px-3 py-1 text-xs text-slate-300 hover:bg-slate-700 disabled:opacity-50">
                      Mark {s}
                    </button>
                  ))}
                </div>
                <button onClick={() => setDeleteTarget(req)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-4 w-4" /></button>
              </div>
            </div>
          ))}
        </div>
      )}

      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} requests</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5">{page} / {data?.totalPages}</span>
            <button onClick={() => setPage(p => Math.min(data?.totalPages ?? 1, p + 1))} disabled={page === data?.totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}

      <ConfirmDialog open={!!deleteTarget} title="Delete Prayer Request" description="Delete this prayer request? This cannot be undone." onConfirm={() => deletePrayer.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={deletePrayer.isPending} />
    </div>
  );
}
