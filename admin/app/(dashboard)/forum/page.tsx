'use client';

import { useState } from 'react';
import { Plus, Search, Trash2, Pencil, Loader2, MessageSquare, Pin, Lock, Filter } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import {
  useForumCategories, useCreateForumCategory, useUpdateForumCategory, useDeleteForumCategory,
  useForumThreads, usePinThread, useLockThread, useDeleteThread,
  type ForumCategory, type ForumThread,
} from '@/hooks/useForum';
import { formatDate } from '@/lib/format';

type Tab = 'categories' | 'threads';
type CF = { name: string; description: string; iconUrl: string; sortOrder: string };
const emptyCF: CF = { name: '', description: '', iconUrl: '', sortOrder: '' };

export default function ForumPage() {
  const [tab, setTab] = useState<Tab>('categories');
  return (
    <div className="space-y-6">
      <PageHeader title="Forum" description="Manage forum categories and moderate threads" />
      <div className="flex gap-1 border-b border-slate-700">
        {(['categories', 'threads'] as Tab[]).map(t => (
          <button key={t} onClick={() => setTab(t)} className={`px-4 py-2 text-sm font-medium capitalize transition-colors ${tab === t ? 'border-b-2 border-indigo-500 text-indigo-400' : 'text-slate-400 hover:text-slate-200'}`}>{t}</button>
        ))}
      </div>
      {tab === 'categories' ? <CategoriesTab /> : <ThreadsTab />}
    </div>
  );
}

function CategoriesTab() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<ForumCategory | null>(null);
  const [form, setForm] = useState<CF>(emptyCF);
  const [deleteTarget, setDeleteTarget] = useState<ForumCategory | null>(null);

  const { data: categories, isLoading } = useForumCategories();
  const create = useCreateForumCategory();
  const update = useUpdateForumCategory();
  const del = useDeleteForumCategory();

  const openCreate = () => { setEditing(null); setForm(emptyCF); setOpen(true); };
  const openEdit = (c: ForumCategory) => {
    setEditing(c);
    setForm({ name: c.name, description: c.description ?? '', iconUrl: c.iconUrl ?? '', sortOrder: c.sortOrder ? String(c.sortOrder) : '' });
    setOpen(true);
  };
  const set = (k: keyof CF) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { name: form.name, description: form.description || undefined, iconUrl: form.iconUrl || undefined, sortOrder: form.sortOrder ? Number(form.sortOrder) : undefined };
    if (editing) {
      update.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      create.mutate(payload as any, { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <>
      <div className="flex justify-end">
        <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500"><Plus className="h-4 w-4" /> New Category</button>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : !categories?.length ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500"><MessageSquare className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No categories yet</p></div>
      ) : (
        <div className="space-y-3">
          {categories.map(c => (
            <div key={c.id} className="rounded-xl border border-slate-700 bg-slate-800 p-4 flex items-center gap-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-indigo-500/20 text-indigo-400 shrink-0">
                <MessageSquare className="h-5 w-5" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-slate-100">{c.name}</p>
                {c.description && <p className="text-sm text-slate-400 line-clamp-1">{c.description}</p>}
                <p className="text-xs text-slate-500 mt-0.5">{c._count?.threads ?? 0} threads</p>
              </div>
              <div className="flex gap-1 shrink-0">
                <button onClick={() => openEdit(c)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-4 w-4" /></button>
                <button onClick={() => setDeleteTarget(c)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-4 w-4" /></button>
              </div>
            </div>
          ))}
        </div>
      )}

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4">
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit Category' : 'New Category'}</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <FLD label="Name *" value={form.name} onChange={set('name')} required />
              <div className="space-y-1.5"><label className="text-sm font-medium text-slate-300">Description</label><textarea value={form.description} onChange={set('description')} rows={2} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none resize-none" /></div>
              <div className="grid grid-cols-2 gap-3">
                <FLD label="Icon URL" value={form.iconUrl} onChange={set('iconUrl')} placeholder="https://..." />
                <FLD label="Sort Order" value={form.sortOrder} onChange={set('sortOrder')} type="number" placeholder="0" />
              </div>
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={create.isPending || update.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                  {(create.isPending || update.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}{editing ? 'Save' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog open={!!deleteTarget} title="Delete Category" description={`Delete "${deleteTarget?.name}"? All threads inside will be removed.`} onConfirm={() => del.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={del.isPending} />
    </>
  );
}

function ThreadsTab() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [deleteTarget, setDeleteTarget] = useState<ForumThread | null>(null);

  const { data: categories } = useForumCategories();
  const { data, isLoading } = useForumThreads({ page, limit: 20, search: search || undefined, categoryId: categoryId || undefined });
  const pin = usePinThread();
  const lock = useLockThread();
  const del = useDeleteThread();

  const threads = data?.threads ?? [];

  return (
    <>
      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search threads…" className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 pointer-events-none" />
          <select value={categoryId} onChange={e => { setCategoryId(e.target.value); setPage(1); }} className="rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-8 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none appearance-none cursor-pointer">
            <option value="">All Categories</option>
            {categories?.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : threads.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500"><MessageSquare className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No threads found</p></div>
      ) : (
        <div className="space-y-3">
          {threads.map(t => (
            <div key={t.id} className="rounded-xl border border-slate-700 bg-slate-800 p-4">
              <div className="flex items-start gap-3">
                {t.author.avatarUrl ? (
                  <img src={t.author.avatarUrl} alt="" className="h-8 w-8 rounded-full object-cover border border-slate-700 shrink-0" />
                ) : (
                  <span className="h-8 w-8 rounded-full bg-slate-700 flex items-center justify-center shrink-0 text-xs font-bold text-slate-300">{t.author.name[0]}</span>
                )}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <p className="font-semibold text-slate-100 truncate">{t.title}</p>
                    {t.isPinned && <span className="flex items-center gap-1 rounded-full bg-amber-500/20 px-2 py-0.5 text-xs text-amber-400"><Pin className="h-3 w-3" /> Pinned</span>}
                    {t.isLocked && <span className="flex items-center gap-1 rounded-full bg-slate-600 px-2 py-0.5 text-xs text-slate-300"><Lock className="h-3 w-3" /> Locked</span>}
                    <span className="rounded-full bg-indigo-500/20 px-2 py-0.5 text-xs text-indigo-400">{t.category.name}</span>
                  </div>
                  <p className="text-xs text-slate-400 mt-0.5">{t.author.name} · {formatDate(t.createdAt)} · {t.replyCount} replies · {t.viewCount} views</p>
                </div>
                <div className="flex items-center gap-1 shrink-0">
                  <button onClick={() => pin.mutate(t.id)} disabled={pin.isPending} title={t.isPinned ? 'Unpin' : 'Pin'} className={`p-1.5 rounded-lg hover:bg-slate-700 disabled:opacity-50 ${t.isPinned ? 'text-amber-400' : 'text-slate-400 hover:text-amber-400'}`}><Pin className="h-4 w-4" /></button>
                  <button onClick={() => lock.mutate(t.id)} disabled={lock.isPending} title={t.isLocked ? 'Unlock' : 'Lock'} className={`p-1.5 rounded-lg hover:bg-slate-700 disabled:opacity-50 ${t.isLocked ? 'text-slate-200' : 'text-slate-400 hover:text-slate-200'}`}><Lock className="h-4 w-4" /></button>
                  <button onClick={() => setDeleteTarget(t)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-4 w-4" /></button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} threads</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5">{page} / {data?.totalPages}</span>
            <button onClick={() => setPage(p => Math.min(data?.totalPages ?? 1, p + 1))} disabled={page === data?.totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}

      <ConfirmDialog open={!!deleteTarget} title="Delete Thread" description={`Delete "${deleteTarget?.title}"? All replies will be removed.`} onConfirm={() => del.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={del.isPending} />
    </>
  );
}

function FLD({ label, required, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { label: string }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <input {...props} required={required} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
    </div>
  );
}
