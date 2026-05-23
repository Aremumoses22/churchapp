'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Plus, Pencil, Trash2, Loader2, MapPin, Clock, ChevronDown, ChevronUp } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import {
  useChurchInfo, useCreateCampus, useUpdateCampus, useDeleteCampus, useUpsertServiceTimes,
  type Campus, type ServiceTime,
} from '@/hooks/useChurch';

type CampusForm = Omit<Campus, 'id' | 'serviceTimes'>;
const emptyCampus: CampusForm = { name: '', address: '', city: '', state: '', phone: '', email: '', isMain: false };

export default function CampusesPage() {
  const router = useRouter();
  const { data: church, isLoading } = useChurchInfo();
  const createCampus = useCreateCampus();
  const updateCampus = useUpdateCampus();
  const deleteCampus = useDeleteCampus();
  const upsertTimes = useUpsertServiceTimes();

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Campus | null>(null);
  const [form, setForm] = useState<CampusForm>(emptyCampus);
  const [deleteTarget, setDeleteTarget] = useState<Campus | null>(null);
  const [expanded, setExpanded] = useState<string | null>(null);
  const [timesEdit, setTimesEdit] = useState<Record<string, Omit<ServiceTime, 'id'>[]>>({});

  const campuses = church?.campuses ?? [];

  const openCreate = () => { setEditing(null); setForm(emptyCampus); setOpen(true); };
  const openEdit = (c: Campus) => { setEditing(c); setForm({ name: c.name, address: c.address ?? '', city: c.city ?? '', state: c.state ?? '', phone: c.phone ?? '', email: c.email ?? '', isMain: c.isMain }); setOpen(true); };

  const set = (k: keyof CampusForm) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setForm(f => ({ ...f, [k]: k === 'isMain' ? (e.target as HTMLInputElement).checked : e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editing) {
      updateCampus.mutate({ id: editing.id, ...form }, { onSuccess: () => setOpen(false) });
    } else {
      createCampus.mutate(form, { onSuccess: () => setOpen(false) });
    }
  };

  const getTimesForCampus = (c: Campus) => timesEdit[c.id] ?? c.serviceTimes.map(({ day, time, label }) => ({ day, time, label: label ?? '' }));

  const addTime = (campusId: string) => {
    const current = getTimesForCampus(campuses.find(c => c.id === campusId)!);
    setTimesEdit(t => ({ ...t, [campusId]: [...current, { day: 'Sunday', time: '9:00 AM', label: '' }] }));
  };

  const updateTime = (campusId: string, idx: number, key: keyof Omit<ServiceTime, 'id'>, val: string) => {
    const current = [...getTimesForCampus(campuses.find(c => c.id === campusId)!)];
    current[idx] = { ...current[idx], [key]: val };
    setTimesEdit(t => ({ ...t, [campusId]: current }));
  };

  const removeTime = (campusId: string, idx: number) => {
    const current = [...getTimesForCampus(campuses.find(c => c.id === campusId)!)];
    current.splice(idx, 1);
    setTimesEdit(t => ({ ...t, [campusId]: current }));
  };

  const saveServiceTimes = (campusId: string) => {
    const times = getTimesForCampus(campuses.find(c => c.id === campusId)!);
    upsertTimes.mutate({ campusId, serviceTimes: times }, { onSuccess: () => setTimesEdit(t => { const next = { ...t }; delete next[campusId]; return next; }) });
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Campuses & Locations"
        description="Manage your church campuses and service times"
        actions={
          <div className="flex items-center gap-3">
            <button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100">
              <ArrowLeft className="h-4 w-4" /> Back
            </button>
            <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500">
              <Plus className="h-4 w-4" /> Add Campus
            </button>
          </div>
        }
      />

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : campuses.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500">
          <MapPin className="h-10 w-10 mb-3" />
          <p className="font-medium text-slate-300">No campuses yet</p>
        </div>
      ) : (
        <div className="space-y-4">
          {campuses.map(c => {
            const isExpanded = expanded === c.id;
            const editedTimes = timesEdit[c.id];
            const times = getTimesForCampus(c);
            return (
              <div key={c.id} className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
                <div className="flex items-center gap-4 p-5">
                  <span className="flex h-10 w-10 items-center justify-center rounded-lg bg-indigo-500/20 text-indigo-400 shrink-0">
                    <MapPin className="h-5 w-5" />
                  </span>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="font-semibold text-slate-100">{c.name}</p>
                      {c.isMain && <span className="rounded-full bg-indigo-500/20 px-2 py-0.5 text-xs text-indigo-400 font-medium">Main</span>}
                    </div>
                    {(c.address || c.city) && (
                      <p className="text-sm text-slate-400 mt-0.5">{[c.address, c.city, c.state].filter(Boolean).join(', ')}</p>
                    )}
                    <p className="text-xs text-slate-500 mt-0.5">{c.serviceTimes.length} service time{c.serviceTimes.length !== 1 ? 's' : ''}</p>
                  </div>
                  <div className="flex items-center gap-2">
                    <button onClick={() => setExpanded(isExpanded ? null : c.id)} className="flex items-center gap-1.5 rounded-lg border border-slate-600 px-3 py-1.5 text-xs text-slate-300 hover:bg-slate-700">
                      <Clock className="h-3.5 w-3.5" /> Times {isExpanded ? <ChevronUp className="h-3 w-3" /> : <ChevronDown className="h-3 w-3" />}
                    </button>
                    <button onClick={() => openEdit(c)} className="p-2 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-4 w-4" /></button>
                    <button onClick={() => setDeleteTarget(c)} className="p-2 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-4 w-4" /></button>
                  </div>
                </div>

                {isExpanded && (
                  <div className="border-t border-slate-700 p-5 space-y-3 bg-slate-900/40">
                    <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Service Times</p>
                    {times.map((t, i) => (
                      <div key={i} className="flex gap-2 items-center">
                        <input value={t.day} onChange={e => updateTime(c.id, i, 'day', e.target.value)} placeholder="Day" className="w-28 rounded-lg border border-slate-600 bg-slate-800 px-3 py-1.5 text-sm text-slate-100" />
                        <input value={t.time} onChange={e => updateTime(c.id, i, 'time', e.target.value)} placeholder="Time" className="w-28 rounded-lg border border-slate-600 bg-slate-800 px-3 py-1.5 text-sm text-slate-100" />
                        <input value={t.label ?? ''} onChange={e => updateTime(c.id, i, 'label', e.target.value)} placeholder="Label (optional)" className="flex-1 rounded-lg border border-slate-600 bg-slate-800 px-3 py-1.5 text-sm text-slate-100" />
                        <button onClick={() => removeTime(c.id, i)} className="text-red-400 hover:text-red-300 p-1"><Trash2 className="h-4 w-4" /></button>
                      </div>
                    ))}
                    <div className="flex gap-3 pt-1">
                      <button onClick={() => addTime(c.id)} className="flex items-center gap-1.5 text-sm text-slate-400 hover:text-indigo-400">
                        <Plus className="h-4 w-4" /> Add time
                      </button>
                      {(editedTimes !== undefined) && (
                        <button onClick={() => saveServiceTimes(c.id)} disabled={upsertTimes.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-1.5 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                          {upsertTimes.isPending && <Loader2 className="h-3.5 w-3.5 animate-spin" />} Save Times
                        </button>
                      )}
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {/* Add/Edit Dialog */}
      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4">
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit Campus' : 'Add Campus'}</h3>
            <form onSubmit={handleSubmit} className="space-y-3">
              <Field label="Campus Name *" value={form.name} onChange={set('name')} required />
              <Field label="Street Address" value={form.address ?? ''} onChange={set('address')} />
              <div className="grid grid-cols-2 gap-3">
                <Field label="City" value={form.city ?? ''} onChange={set('city')} />
                <Field label="State" value={form.state ?? ''} onChange={set('state')} />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <Field label="Phone" value={form.phone ?? ''} onChange={set('phone')} />
                <Field label="Email" value={form.email ?? ''} onChange={set('email')} type="email" />
              </div>
              <label className="flex items-center gap-2 text-sm text-slate-300">
                <input type="checkbox" checked={form.isMain} onChange={set('isMain')} className="rounded border-slate-600" />
                Main Campus
              </label>
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={createCampus.isPending || updateCampus.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                  {(createCampus.isPending || updateCampus.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}
                  {editing ? 'Save Changes' : 'Add Campus'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete Campus"
        description={`Delete "${deleteTarget?.name}"? This cannot be undone.`}
        onConfirm={() => deleteCampus.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })}
        onClose={() => setDeleteTarget(null)}
        loading={deleteCampus.isPending}
      />
    </div>
  );
}

function Field({ label, required, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { label: string }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <input {...props} required={required} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
    </div>
  );
}
