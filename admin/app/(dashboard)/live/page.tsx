'use client';

import { useState } from 'react';
import { Plus, Trash2, Pencil, Loader2, Radio, Play, Square } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useLiveServices, useCreateLiveService, useUpdateLiveService, useDeleteLiveService, useGoLive, useEndLiveService, type LiveService } from '@/hooks/useLive';
import { formatDate } from '@/lib/format';

const STATUS_COLORS: Record<string, string> = {
  SCHEDULED: 'bg-amber-500/20 text-amber-400',
  LIVE: 'bg-red-500/20 text-red-400',
  ENDED: 'bg-slate-700 text-slate-400',
};

type SF = { title: string; description: string; streamUrl: string; scheduledAt: string };
const empty: SF = { title: '', description: '', streamUrl: '', scheduledAt: '' };

export default function LivePage() {
  const [page, setPage] = useState(1);
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<LiveService | null>(null);
  const [form, setForm] = useState<SF>(empty);
  const [deleteTarget, setDeleteTarget] = useState<LiveService | null>(null);

  const { data, isLoading } = useLiveServices({ page, limit: 20 });
  const create = useCreateLiveService();
  const update = useUpdateLiveService();
  const del = useDeleteLiveService();
  const goLive = useGoLive();
  const end = useEndLiveService();

  const services = data?.services ?? [];

  const openCreate = () => { setEditing(null); setForm(empty); setOpen(true); };
  const openEdit = (s: LiveService) => { setEditing(s); setForm({ title: s.title, description: s.description ?? '', streamUrl: s.streamUrl ?? '', scheduledAt: s.scheduledAt.slice(0, 16) }); setOpen(true); };
  const set = (k: keyof SF) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { title: form.title, description: form.description || undefined, streamUrl: form.streamUrl || undefined, scheduledAt: form.scheduledAt };
    if (editing) {
      update.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      create.mutate(payload, { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Live Services" description="Schedule and manage live streaming services"
        actions={<button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500"><Plus className="h-4 w-4" /> Schedule Service</button>}
      />

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : services.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500"><Radio className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No live services yet</p></div>
      ) : (
        <div className="space-y-4">
          {services.map(s => (
            <div key={s.id} className={`rounded-xl border bg-slate-800 p-5 space-y-3 ${s.status === 'LIVE' ? 'border-red-500/50 shadow-lg shadow-red-500/10' : 'border-slate-700'}`}>
              <div className="flex items-start gap-4">
                <span className={`flex h-10 w-10 items-center justify-center rounded-lg shrink-0 ${s.status === 'LIVE' ? 'bg-red-500/20 text-red-400' : 'bg-slate-700 text-slate-400'}`}>
                  <Radio className={`h-5 w-5 ${s.status === 'LIVE' ? 'animate-pulse' : ''}`} />
                </span>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="font-semibold text-slate-100">{s.title}</p>
                    <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_COLORS[s.status]}`}>{s.status}</span>
                  </div>
                  {s.description && <p className="text-sm text-slate-400 mt-0.5 line-clamp-1">{s.description}</p>}
                  <p className="text-xs text-slate-500 mt-1">Scheduled: {formatDate(s.scheduledAt)}</p>
                  {s.streamUrl && <a href={s.streamUrl} target="_blank" rel="noopener noreferrer" className="text-xs text-indigo-400 hover:text-indigo-300 truncate block mt-0.5">{s.streamUrl}</a>}
                  {s.status === 'LIVE' && <p className="text-xs text-red-400 mt-0.5">👁 {s.viewerCount} viewers</p>}
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  {s.status === 'SCHEDULED' && (
                    <button onClick={() => goLive.mutate(s.id)} disabled={goLive.isPending} className="flex items-center gap-1.5 rounded-lg bg-red-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-red-500 disabled:opacity-60">
                      <Play className="h-3.5 w-3.5" /> Go Live
                    </button>
                  )}
                  {s.status === 'LIVE' && (
                    <button onClick={() => end.mutate(s.id)} disabled={end.isPending} className="flex items-center gap-1.5 rounded-lg bg-slate-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-slate-500 disabled:opacity-60">
                      <Square className="h-3.5 w-3.5" /> End
                    </button>
                  )}
                  {s.status !== 'LIVE' && (
                    <button onClick={() => openEdit(s)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-4 w-4" /></button>
                  )}
                  <button onClick={() => setDeleteTarget(s)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-4 w-4" /></button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} services</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5">{page} / {data?.totalPages}</span>
            <button onClick={() => setPage(p => Math.min(data?.totalPages ?? 1, p + 1))} disabled={page === data?.totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4">
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit Service' : 'Schedule Service'}</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <FLD label="Title *" value={form.title} onChange={set('title')} required />
              <div className="space-y-1.5"><label className="text-sm font-medium text-slate-300">Description</label><textarea value={form.description} onChange={set('description')} rows={2} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none resize-none" /></div>
              <FLD label="Scheduled At *" value={form.scheduledAt} onChange={set('scheduledAt')} type="datetime-local" required />
              <FLD label="Stream URL" value={form.streamUrl} onChange={set('streamUrl')} placeholder="https://youtube.com/live/..." />
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={create.isPending || update.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                  {(create.isPending || update.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}{editing ? 'Save' : 'Schedule'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog open={!!deleteTarget} title="Delete Service" description={`Delete "${deleteTarget?.title}"?`} onConfirm={() => del.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={del.isPending} />
    </div>
  );
}

function FLD({ label, required, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { label: string }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <input {...props} required={required} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
    </div>
  );
}
