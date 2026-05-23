'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Plus, Pencil, Trash2, Loader2, Layers } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useSermonSeries, useCreateSeries, useUpdateSeries, useDeleteSeries, type SermonSeries } from '@/hooks/useSermons';
import { formatDate } from '@/lib/format';

type SeriesForm = { title: string; description: string; artworkUrl: string; startDate: string; endDate: string };
const empty: SeriesForm = { title: '', description: '', artworkUrl: '', startDate: '', endDate: '' };

export default function SeriesPage() {
  const router = useRouter();
  const { data: series, isLoading } = useSermonSeries();
  const createSeries = useCreateSeries();
  const updateSeries = useUpdateSeries();
  const deleteSeries = useDeleteSeries();

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<SermonSeries | null>(null);
  const [form, setForm] = useState<SeriesForm>(empty);
  const [deleteTarget, setDeleteTarget] = useState<SermonSeries | null>(null);

  const openCreate = () => { setEditing(null); setForm(empty); setOpen(true); };
  const openEdit = (s: SermonSeries) => {
    setEditing(s);
    setForm({
      title: s.title,
      description: s.description ?? '',
      artworkUrl: s.artworkUrl ?? '',
      startDate: s.startDate ? s.startDate.split('T')[0] : '',
      endDate: s.endDate ? s.endDate.split('T')[0] : '',
    });
    setOpen(true);
  };

  const set = (k: keyof SeriesForm) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { ...form, description: form.description || undefined, artworkUrl: form.artworkUrl || undefined, startDate: form.startDate || undefined, endDate: form.endDate || undefined };
    if (editing) {
      updateSeries.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      createSeries.mutate(payload as Parameters<typeof createSeries.mutate>[0], { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Sermon Series"
        description="Organize sermons into series"
        actions={
          <div className="flex items-center gap-3">
            <button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100">
              <ArrowLeft className="h-4 w-4" /> Back
            </button>
            <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500">
              <Plus className="h-4 w-4" /> New Series
            </button>
          </div>
        }
      />

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : !series || series.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500">
          <Layers className="h-10 w-10 mb-3" />
          <p className="font-medium text-slate-300">No series yet</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {series.map(s => (
            <div key={s.id} className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
              {s.artworkUrl ? (
                <img src={s.artworkUrl} alt={s.title} className="w-full h-36 object-cover" />
              ) : (
                <div className="w-full h-36 bg-slate-700 flex items-center justify-center">
                  <Layers className="h-8 w-8 text-slate-500" />
                </div>
              )}
              <div className="p-4">
                <p className="font-semibold text-slate-100">{s.title}</p>
                {s.description && <p className="text-sm text-slate-400 mt-1 line-clamp-2">{s.description}</p>}
                <div className="flex items-center justify-between mt-3">
                  <span className="text-xs text-slate-500">{s._count?.sermons ?? 0} sermons{s.startDate ? ` · ${formatDate(s.startDate)}` : ''}</span>
                  <div className="flex gap-1">
                    <button onClick={() => openEdit(s)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                    <button onClick={() => setDeleteTarget(s)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4">
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit Series' : 'New Series'}</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Title *</label>
                <input value={form.title} onChange={set('title')} required className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Description</label>
                <textarea value={form.description} onChange={set('description')} rows={3} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 resize-none" />
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Artwork URL</label>
                <input value={form.artworkUrl} onChange={set('artworkUrl')} placeholder="https://..." className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <label className="text-sm font-medium text-slate-300">Start Date</label>
                  <input type="date" value={form.startDate} onChange={set('startDate')} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
                </div>
                <div className="space-y-1.5">
                  <label className="text-sm font-medium text-slate-300">End Date</label>
                  <input type="date" value={form.endDate} onChange={set('endDate')} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
                </div>
              </div>
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={createSeries.isPending || updateSeries.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                  {(createSeries.isPending || updateSeries.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}
                  {editing ? 'Save Changes' : 'Create Series'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete Series"
        description={`Delete "${deleteTarget?.title}"? Sermons in this series won't be deleted.`}
        onConfirm={() => deleteSeries.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })}
        onClose={() => setDeleteTarget(null)}
        loading={deleteSeries.isPending}
      />
    </div>
  );
}
