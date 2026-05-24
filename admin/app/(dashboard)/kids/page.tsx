'use client';

import { useState } from 'react';
import { Plus, Search, Pencil, Trash2, Loader2, Baby, Users, Filter } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import {
  useKidsRooms, useCreateRoom, useUpdateRoom, useDeleteRoom,
  useKidsChildren, useTodayCheckins, useCheckinHistory,
  type Room, type Child,
} from '@/hooks/useKids';
import { formatDate } from '@/lib/format';

type Tab = 'rooms' | 'children' | 'checkins';
type RF = { name: string; ageGroup: string; capacity: string };
const emptyRF: RF = { name: '', ageGroup: '', capacity: '' };

const AGE_GROUPS = ['0-2', '3-5', '6-8', '9-12'];

export default function KidsPage() {
  const [tab, setTab] = useState<Tab>('rooms');
  return (
    <div className="space-y-6">
      <PageHeader title="Kids Ministry" description="Manage rooms, children registry, and check-in records" />
      <div className="flex gap-1 border-b border-slate-700">
        {(['rooms', 'children', 'checkins'] as Tab[]).map(t => (
          <button key={t} onClick={() => setTab(t)} className={`px-4 py-2 text-sm font-medium capitalize transition-colors ${tab === t ? 'border-b-2 border-indigo-500 text-indigo-400' : 'text-slate-400 hover:text-slate-200'}`}>{t === 'checkins' ? "Today's Check-ins" : t.charAt(0).toUpperCase() + t.slice(1)}</button>
        ))}
      </div>
      {tab === 'rooms' && <RoomsTab />}
      {tab === 'children' && <ChildrenTab />}
      {tab === 'checkins' && <CheckinsTab />}
    </div>
  );
}

function RoomsTab() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Room | null>(null);
  const [form, setForm] = useState<RF>(emptyRF);
  const [deleteTarget, setDeleteTarget] = useState<Room | null>(null);

  const { data: rooms, isLoading } = useKidsRooms();
  const create = useCreateRoom();
  const update = useUpdateRoom();
  const del = useDeleteRoom();

  const openCreate = () => { setEditing(null); setForm(emptyRF); setOpen(true); };
  const openEdit = (r: Room) => { setEditing(r); setForm({ name: r.name, ageGroup: r.ageGroup, capacity: String(r.capacity) }); setOpen(true); };
  const set = (k: keyof RF) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { name: form.name, ageGroup: form.ageGroup, capacity: Number(form.capacity) };
    if (editing) {
      update.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      create.mutate(payload, { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <>
      <div className="flex justify-end">
        <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500"><Plus className="h-4 w-4" /> Add Room</button>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : !rooms?.length ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500"><Baby className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No rooms yet</p></div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {rooms.map(r => {
            const pct = r.capacity > 0 ? Math.min(100, Math.round((r.currentCount / r.capacity) * 100)) : 0;
            const color = pct >= 90 ? 'bg-red-500' : pct >= 70 ? 'bg-amber-500' : 'bg-emerald-500';
            return (
              <div key={r.id} className="rounded-xl border border-slate-700 bg-slate-800 p-5 space-y-3">
                <div className="flex items-start justify-between gap-2">
                  <div>
                    <p className="font-semibold text-slate-100">{r.name}</p>
                    <span className="rounded-full bg-indigo-500/20 px-2 py-0.5 text-xs text-indigo-400">Ages {r.ageGroup}</span>
                  </div>
                  <div className="flex gap-1">
                    <button onClick={() => openEdit(r)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                    <button onClick={() => setDeleteTarget(r)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
                  </div>
                </div>
                <div className="space-y-1">
                  <div className="flex items-center justify-between text-xs text-slate-400">
                    <span className="flex items-center gap-1"><Users className="h-3 w-3" /> {r.currentCount} / {r.capacity} children</span>
                    <span>{pct}%</span>
                  </div>
                  <div className="h-2 rounded-full bg-slate-700 overflow-hidden">
                    <div className={`h-full rounded-full transition-all ${color}`} style={{ width: `${pct}%` }} />
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-sm rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4">
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit Room' : 'Add Room'}</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <FLD label="Room Name *" value={form.name} onChange={set('name')} required />
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Age Group *</label>
                <select value={form.ageGroup} onChange={set('ageGroup')} required className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none">
                  <option value="">Select age group</option>
                  {AGE_GROUPS.map(g => <option key={g} value={g}>{g} years</option>)}
                </select>
              </div>
              <FLD label="Capacity *" value={form.capacity} onChange={set('capacity')} type="number" min="1" required />
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={create.isPending || update.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                  {(create.isPending || update.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}{editing ? 'Save' : 'Add'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog open={!!deleteTarget} title="Delete Room" description={`Delete "${deleteTarget?.name}"? Existing check-in records will remain.`} onConfirm={() => del.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={del.isPending} />
    </>
  );
}

function ChildrenTab() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const { data, isLoading } = useKidsChildren({ page, limit: 20, search: search || undefined });
  const children = data?.children ?? [];

  function age(dob: string) {
    const diff = Date.now() - new Date(dob).getTime();
    const years = Math.floor(diff / (1000 * 60 * 60 * 24 * 365.25));
    return `${years} yr${years !== 1 ? 's' : ''}`;
  }

  return (
    <>
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
        <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search children…" className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : children.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500"><Baby className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No children registered</p></div>
      ) : (
        <div className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
          <div className="divide-y divide-slate-700/50">
            {children.map((c: Child) => (
              <div key={c.id} className="flex items-center gap-4 p-4">
                {c.photoUrl ? (
                  <img src={c.photoUrl} alt="" className="h-10 w-10 rounded-full object-cover border border-slate-700 shrink-0" />
                ) : (
                  <span className="h-10 w-10 rounded-full bg-slate-700 flex items-center justify-center shrink-0 text-sm font-bold text-slate-300">{c.firstName[0]}</span>
                )}
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-slate-100">{c.firstName} {c.lastName}</p>
                  <p className="text-xs text-slate-400">{age(c.dateOfBirth)} · Parent: {c.parent.name}</p>
                  {c.allergies && <p className="text-xs text-red-400 mt-0.5">⚠ {c.allergies}</p>}
                </div>
                <div className="text-right text-xs text-slate-500 shrink-0">
                  <p>{c.parent.phone ?? c.parent.email}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} children</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5">{page} / {data?.totalPages}</span>
            <button onClick={() => setPage(p => Math.min(data?.totalPages ?? 1, p + 1))} disabled={page === data?.totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}
    </>
  );
}

function CheckinsTab() {
  const { data: checkins, isLoading } = useTodayCheckins();

  const checkedIn = checkins?.filter(c => c.status === 'CHECKED_IN') ?? [];
  const checkedOut = checkins?.filter(c => c.status !== 'CHECKED_IN') ?? [];

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-2 gap-4">
        <div className="rounded-xl border border-slate-700 bg-slate-800 p-4 text-center">
          <p className="text-3xl font-bold text-emerald-400">{checkedIn.length}</p>
          <p className="text-sm text-slate-400 mt-1">Currently Checked In</p>
        </div>
        <div className="rounded-xl border border-slate-700 bg-slate-800 p-4 text-center">
          <p className="text-3xl font-bold text-slate-300">{checkedOut.length}</p>
          <p className="text-sm text-slate-400 mt-1">Checked Out Today</p>
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : !checkins?.length ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500"><Baby className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No check-ins today</p></div>
      ) : (
        <div className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
          <div className="divide-y divide-slate-700/50">
            {checkins.map(c => (
              <div key={c.id} className="flex items-center gap-4 p-4">
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-slate-100">{c.child.firstName} {c.child.lastName}</p>
                  <p className="text-xs text-slate-400">{c.room.name} · Parent: {c.parent.name}</p>
                  <p className="text-xs text-slate-500 mt-0.5">In: {formatDate(c.checkedInAt)}{c.checkedOutAt ? ` · Out: ${formatDate(c.checkedOutAt)}` : ''}</p>
                </div>
                <div className="text-right shrink-0">
                  <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${c.status === 'CHECKED_IN' ? 'bg-emerald-500/20 text-emerald-400' : 'bg-slate-700 text-slate-400'}`}>{c.status.replace('_', ' ')}</span>
                  <p className="text-xs font-mono text-slate-400 mt-1">🔐 {c.securityCode}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
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
