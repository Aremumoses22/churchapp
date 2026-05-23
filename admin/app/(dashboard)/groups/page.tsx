'use client';

import { useState } from 'react';
import { Plus, Search, Pencil, Trash2, Loader2, Users, Filter } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useGroups, useCreateGroup, useUpdateGroup, useDeleteGroup, GROUP_CATEGORIES, type Group } from '@/hooks/useGroups';

type GF = { name: string; description: string; category: string; meetingDay: string; meetingTime: string; location: string; maxMembers: string; imageUrl: string };
const emptyGF: GF = { name: '', description: '', category: 'BIBLE_STUDY', meetingDay: '', meetingTime: '', location: '', maxMembers: '', imageUrl: '' };

export default function GroupsPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('');
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Group | null>(null);
  const [form, setForm] = useState<GF>(emptyGF);
  const [deleteTarget, setDeleteTarget] = useState<Group | null>(null);

  const { data, isLoading } = useGroups({ page, limit: 20, search: search || undefined, category: category || undefined });
  const createGroup = useCreateGroup();
  const updateGroup = useUpdateGroup();
  const deleteGroup = useDeleteGroup();

  const groups = data?.groups ?? [];

  const openCreate = () => { setEditing(null); setForm(emptyGF); setOpen(true); };
  const openEdit = (g: Group) => { setEditing(g); setForm({ name: g.name, description: g.description ?? '', category: g.category, meetingDay: g.meetingDay ?? '', meetingTime: g.meetingTime ?? '', location: g.location ?? '', maxMembers: g.maxMembers ? String(g.maxMembers) : '', imageUrl: g.imageUrl ?? '' }); setOpen(true); };
  const set = (k: keyof GF) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { name: form.name, description: form.description || undefined, category: form.category, meetingDay: form.meetingDay || undefined, meetingTime: form.meetingTime || undefined, location: form.location || undefined, maxMembers: form.maxMembers ? Number(form.maxMembers) : undefined, imageUrl: form.imageUrl || undefined, isActive: true };
    if (editing) {
      updateGroup.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      createGroup.mutate(payload as Parameters<typeof createGroup.mutate>[0], { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Connect Groups" description="Manage church groups and memberships"
        actions={<button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500"><Plus className="h-4 w-4" /> New Group</button>}
      />

      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search groups…" className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 pointer-events-none" />
          <select value={category} onChange={e => { setCategory(e.target.value); setPage(1); }} className="rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-8 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none appearance-none cursor-pointer">
            <option value="">All Categories</option>
            {GROUP_CATEGORIES.map(c => <option key={c} value={c}>{c.replace('_', ' ')}</option>)}
          </select>
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : groups.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500"><Users className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No groups found</p></div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {groups.map(g => (
            <div key={g.id} className="rounded-xl border border-slate-700 bg-slate-800 p-5 space-y-3">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <p className="font-semibold text-slate-100">{g.name}</p>
                  <span className="rounded-full bg-indigo-500/20 px-2 py-0.5 text-xs text-indigo-400">{g.category.replace('_', ' ')}</span>
                </div>
                <div className="flex gap-1">
                  <button onClick={() => openEdit(g)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                  <button onClick={() => setDeleteTarget(g)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
                </div>
              </div>
              {g.description && <p className="text-sm text-slate-400 line-clamp-2">{g.description}</p>}
              <div className="text-xs text-slate-500 space-y-1">
                {g.meetingDay && <p>📅 {g.meetingDay} {g.meetingTime}</p>}
                {g.location && <p>📍 {g.location}</p>}
                <p className="flex items-center gap-1"><Users className="h-3 w-3" />{g.memberCount} members{g.maxMembers ? ` / ${g.maxMembers}` : ''}</p>
              </div>
              {g.leader && <p className="text-xs text-slate-400">Led by <span className="text-slate-200">{g.leader.name}</span></p>}
            </div>
          ))}
        </div>
      )}

      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} groups</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5">{page} / {data?.totalPages}</span>
            <button onClick={() => setPage(p => Math.min(data?.totalPages ?? 1, p + 1))} disabled={page === data?.totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4 max-h-[90vh] overflow-y-auto">
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit Group' : 'New Group'}</h3>
            <form onSubmit={handleSubmit} className="space-y-3">
              <SF label="Group Name *" value={form.name} onChange={set('name')} required />
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Category *</label>
                <select value={form.category} onChange={set('category')} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none">
                  {GROUP_CATEGORIES.map(c => <option key={c} value={c}>{c.replace('_', ' ')}</option>)}
                </select>
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Description</label>
                <textarea value={form.description} onChange={set('description')} rows={2} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none resize-none" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <SF label="Meeting Day" value={form.meetingDay} onChange={set('meetingDay')} placeholder="e.g. Sunday" />
                <SF label="Meeting Time" value={form.meetingTime} onChange={set('meetingTime')} placeholder="e.g. 6:00 PM" />
              </div>
              <SF label="Location" value={form.location} onChange={set('location')} />
              <SF label="Max Members" value={form.maxMembers} onChange={set('maxMembers')} type="number" />
              <SF label="Image URL" value={form.imageUrl} onChange={set('imageUrl')} placeholder="https://..." />
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={createGroup.isPending || updateGroup.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                  {(createGroup.isPending || updateGroup.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}{editing ? 'Save' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog open={!!deleteTarget} title="Delete Group" description={`Delete "${deleteTarget?.name}"? All memberships will be removed.`} onConfirm={() => deleteGroup.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={deleteGroup.isPending} />
    </div>
  );
}

function SF({ label, required, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { label: string }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <input {...props} required={required} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
    </div>
  );
}
