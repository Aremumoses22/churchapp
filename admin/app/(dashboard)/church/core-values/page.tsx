'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Plus, Pencil, Trash2, Loader2, Heart } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useChurchInfo, useCreateCoreValue, useUpdateCoreValue, useDeleteCoreValue, type CoreValue } from '@/hooks/useChurch';

type CVForm = Omit<CoreValue, 'id'>;
const empty: CVForm = { title: '', description: '', icon: '', order: 0 };

export default function CoreValuesPage() {
  const router = useRouter();
  const { data: church, isLoading } = useChurchInfo();
  const createCV = useCreateCoreValue();
  const updateCV = useUpdateCoreValue();
  const deleteCV = useDeleteCoreValue();

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<CoreValue | null>(null);
  const [form, setForm] = useState<CVForm>(empty);
  const [deleteTarget, setDeleteTarget] = useState<CoreValue | null>(null);

  const values = [...(church?.coreValues ?? [])].sort((a, b) => a.order - b.order);

  const openCreate = () => { setEditing(null); setForm({ ...empty, order: values.length }); setOpen(true); };
  const openEdit = (v: CoreValue) => { setEditing(v); setForm({ title: v.title, description: v.description, icon: v.icon ?? '', order: v.order }); setOpen(true); };

  const set = (k: keyof CVForm) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(f => ({ ...f, [k]: k === 'order' ? Number(e.target.value) : e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editing) {
      updateCV.mutate({ id: editing.id, ...form }, { onSuccess: () => setOpen(false) });
    } else {
      createCV.mutate(form, { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Core Values"
        description="Define what your church stands for"
        actions={
          <div className="flex items-center gap-3">
            <button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100">
              <ArrowLeft className="h-4 w-4" /> Back
            </button>
            <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500">
              <Plus className="h-4 w-4" /> Add Value
            </button>
          </div>
        }
      />

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : values.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500">
          <Heart className="h-10 w-10 mb-3" />
          <p className="font-medium text-slate-300">No core values yet</p>
          <p className="text-sm mt-1">Add your first core value to get started</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {values.map(v => (
            <div key={v.id} className="rounded-xl border border-slate-700 bg-slate-800 p-5 space-y-3">
              <div className="flex items-start justify-between gap-2">
                <div className="flex items-center gap-3">
                  {v.icon ? (
                    <span className="text-2xl">{v.icon}</span>
                  ) : (
                    <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-indigo-500/20 text-indigo-400">
                      <Heart className="h-4 w-4" />
                    </span>
                  )}
                  <p className="font-semibold text-slate-100">{v.title}</p>
                </div>
                <div className="flex gap-1 shrink-0">
                  <button onClick={() => openEdit(v)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                  <button onClick={() => setDeleteTarget(v)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
                </div>
              </div>
              <p className="text-sm text-slate-400 leading-relaxed">{v.description}</p>
            </div>
          ))}
        </div>
      )}

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4">
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit Core Value' : 'Add Core Value'}</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Title *</label>
                <input value={form.title} onChange={set('title')} required className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Description *</label>
                <textarea value={form.description} onChange={set('description')} required rows={3} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 resize-none" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <label className="text-sm font-medium text-slate-300">Icon (emoji)</label>
                  <input value={form.icon ?? ''} onChange={set('icon')} placeholder="e.g. 🙏" className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
                </div>
                <div className="space-y-1.5">
                  <label className="text-sm font-medium text-slate-300">Display Order</label>
                  <input type="number" value={form.order} onChange={set('order')} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
                </div>
              </div>
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={createCV.isPending || updateCV.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                  {(createCV.isPending || updateCV.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}
                  {editing ? 'Save Changes' : 'Add Value'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete Core Value"
        description={`Delete "${deleteTarget?.title}"? This cannot be undone.`}
        onConfirm={() => deleteCV.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })}
        onClose={() => setDeleteTarget(null)}
        loading={deleteCV.isPending}
      />
    </div>
  );
}
