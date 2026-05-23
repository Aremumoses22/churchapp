'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Plus, Pencil, Trash2, Loader2, HelpCircle, ChevronDown, ChevronUp } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useChurchInfo, useCreateFaq, useUpdateFaq, useDeleteFaq, type FAQ } from '@/hooks/useChurch';

type FaqForm = Omit<FAQ, 'id'>;
const empty: FaqForm = { question: '', answer: '', order: 0 };

export default function FaqsPage() {
  const router = useRouter();
  const { data: church, isLoading } = useChurchInfo();
  const createFaq = useCreateFaq();
  const updateFaq = useUpdateFaq();
  const deleteFaq = useDeleteFaq();

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<FAQ | null>(null);
  const [form, setForm] = useState<FaqForm>(empty);
  const [deleteTarget, setDeleteTarget] = useState<FAQ | null>(null);
  const [expanded, setExpanded] = useState<string | null>(null);

  const faqs = [...(church?.faqs ?? [])].sort((a, b) => a.order - b.order);

  const openCreate = () => { setEditing(null); setForm({ ...empty, order: faqs.length }); setOpen(true); };
  const openEdit = (f: FAQ) => { setEditing(f); setForm({ question: f.question, answer: f.answer, order: f.order }); setOpen(true); };

  const set = (k: keyof FaqForm) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(f => ({ ...f, [k]: k === 'order' ? Number(e.target.value) : e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editing) {
      updateFaq.mutate({ id: editing.id, ...form }, { onSuccess: () => setOpen(false) });
    } else {
      createFaq.mutate(form, { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-6 max-w-3xl">
      <PageHeader
        title="FAQs"
        description="Manage frequently asked questions"
        actions={
          <div className="flex items-center gap-3">
            <button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100">
              <ArrowLeft className="h-4 w-4" /> Back
            </button>
            <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500">
              <Plus className="h-4 w-4" /> Add FAQ
            </button>
          </div>
        }
      />

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : faqs.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500">
          <HelpCircle className="h-10 w-10 mb-3" />
          <p className="font-medium text-slate-300">No FAQs yet</p>
          <p className="text-sm mt-1">Add your first frequently asked question</p>
        </div>
      ) : (
        <div className="space-y-2">
          {faqs.map(faq => {
            const isExpanded = expanded === faq.id;
            return (
              <div key={faq.id} className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
                <button
                  className="flex w-full items-center gap-4 p-4 text-left"
                  onClick={() => setExpanded(isExpanded ? null : faq.id)}
                >
                  <HelpCircle className="h-4 w-4 text-indigo-400 shrink-0" />
                  <span className="flex-1 font-medium text-slate-100">{faq.question}</span>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={e => { e.stopPropagation(); openEdit(faq); }}
                      className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"
                    >
                      <Pencil className="h-3.5 w-3.5" />
                    </button>
                    <button
                      onClick={e => { e.stopPropagation(); setDeleteTarget(faq); }}
                      className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                    </button>
                    {isExpanded ? <ChevronUp className="h-4 w-4 text-slate-400" /> : <ChevronDown className="h-4 w-4 text-slate-400" />}
                  </div>
                </button>
                {isExpanded && (
                  <div className="border-t border-slate-700 px-4 pb-4 pt-3">
                    <p className="text-sm text-slate-300 leading-relaxed">{faq.answer}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-lg rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4">
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit FAQ' : 'Add FAQ'}</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Question *</label>
                <input value={form.question} onChange={set('question')} required className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Answer *</label>
                <textarea value={form.answer} onChange={set('answer')} required rows={4} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 resize-none" />
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Display Order</label>
                <input type="number" value={form.order} onChange={set('order')} className="w-24 rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
              </div>
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={createFaq.isPending || updateFaq.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                  {(createFaq.isPending || updateFaq.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}
                  {editing ? 'Save Changes' : 'Add FAQ'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete FAQ"
        description={`Delete this FAQ? This cannot be undone.`}
        onConfirm={() => deleteFaq.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })}
        onClose={() => setDeleteTarget(null)}
        loading={deleteFaq.isPending}
      />
    </div>
  );
}
