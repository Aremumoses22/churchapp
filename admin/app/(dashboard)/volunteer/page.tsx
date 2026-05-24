'use client';

import { useState } from 'react';
import { Plus, Search, Pencil, Trash2, Loader2, UserCheck, Filter, Users, ChevronDown } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import {
  useVolunteerOpportunities, useCreateOpportunity, useUpdateOpportunity, useDeleteOpportunity,
  useToggleOpportunityActive, useOpportunitySignups, useUpdateSignupStatus,
  VOLUNTEER_DEPARTMENTS, type VolunteerOpportunity, type VolunteerSignup,
} from '@/hooks/useVolunteer';
import { formatDate } from '@/lib/format';

type OF = { title: string; description: string; department: string; requirements: string; imageUrl: string };
const emptyOF: OF = { title: '', description: '', department: 'Media', requirements: '', imageUrl: '' };

const STATUS_COLORS: Record<string, string> = {
  PENDING: 'bg-amber-500/20 text-amber-400',
  APPROVED: 'bg-emerald-500/20 text-emerald-400',
  REJECTED: 'bg-red-500/20 text-red-400',
};

export default function VolunteerPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [department, setDepartment] = useState('');
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<VolunteerOpportunity | null>(null);
  const [form, setForm] = useState<OF>(emptyOF);
  const [deleteTarget, setDeleteTarget] = useState<VolunteerOpportunity | null>(null);
  const [signupsFor, setSignupsFor] = useState<VolunteerOpportunity | null>(null);

  const { data, isLoading } = useVolunteerOpportunities({ page, limit: 20, search: search || undefined, department: department || undefined });
  const create = useCreateOpportunity();
  const update = useUpdateOpportunity();
  const del = useDeleteOpportunity();
  const toggleActive = useToggleOpportunityActive();

  const opportunities = data?.opportunities ?? [];

  const openCreate = () => { setEditing(null); setForm(emptyOF); setOpen(true); };
  const openEdit = (o: VolunteerOpportunity) => {
    setEditing(o);
    setForm({ title: o.title, description: o.description ?? '', department: o.department, requirements: o.requirements ?? '', imageUrl: o.imageUrl ?? '' });
    setOpen(true);
  };
  const set = (k: keyof OF) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { title: form.title, description: form.description || undefined, department: form.department, requirements: form.requirements || undefined, imageUrl: form.imageUrl || undefined, isActive: true };
    if (editing) {
      update.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      create.mutate(payload as any, { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Volunteer" description="Manage volunteer opportunities and applications"
        actions={<button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500"><Plus className="h-4 w-4" /> New Opportunity</button>}
      />

      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search opportunities…" className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 pointer-events-none" />
          <select value={department} onChange={e => { setDepartment(e.target.value); setPage(1); }} className="rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-8 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none appearance-none cursor-pointer">
            <option value="">All Departments</option>
            {VOLUNTEER_DEPARTMENTS.map(d => <option key={d} value={d}>{d}</option>)}
          </select>
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : opportunities.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500"><UserCheck className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No opportunities found</p></div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {opportunities.map(o => (
            <div key={o.id} className={`rounded-xl border bg-slate-800 p-5 space-y-3 ${o.isActive ? 'border-slate-700' : 'border-slate-700/50 opacity-60'}`}>
              <div className="flex items-start justify-between gap-2">
                <div className="min-w-0">
                  <p className="font-semibold text-slate-100 truncate">{o.title}</p>
                  <span className="rounded-full bg-indigo-500/20 px-2 py-0.5 text-xs text-indigo-400">{o.department}</span>
                </div>
                <div className="flex gap-1 shrink-0">
                  <button onClick={() => openEdit(o)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                  <button onClick={() => setDeleteTarget(o)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
                </div>
              </div>
              {o.description && <p className="text-sm text-slate-400 line-clamp-2">{o.description}</p>}
              <div className="flex items-center justify-between pt-1">
                <button onClick={() => setSignupsFor(o)} className="flex items-center gap-1.5 text-xs text-slate-400 hover:text-slate-200">
                  <Users className="h-3.5 w-3.5" />{o._count?.signups ?? 0} applicants
                </button>
                <button onClick={() => toggleActive.mutate(o.id)} disabled={toggleActive.isPending} className={`text-xs rounded-full px-2 py-0.5 font-medium ${o.isActive ? 'bg-emerald-500/20 text-emerald-400 hover:bg-emerald-500/30' : 'bg-slate-700 text-slate-400 hover:bg-slate-600'}`}>
                  {o.isActive ? 'Active' : 'Inactive'}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} opportunities</span>
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
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit Opportunity' : 'New Opportunity'}</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <FLD label="Title *" value={form.title} onChange={set('title')} required />
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Department *</label>
                <select value={form.department} onChange={set('department')} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none">
                  {VOLUNTEER_DEPARTMENTS.map(d => <option key={d} value={d}>{d}</option>)}
                </select>
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Description</label>
                <textarea value={form.description} onChange={set('description')} rows={3} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none resize-none" />
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-300">Requirements</label>
                <textarea value={form.requirements} onChange={set('requirements')} rows={2} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none resize-none" />
              </div>
              <FLD label="Image URL" value={form.imageUrl} onChange={set('imageUrl')} placeholder="https://..." />
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

      <ConfirmDialog open={!!deleteTarget} title="Delete Opportunity" description={`Delete "${deleteTarget?.title}"? All signups will be removed.`} onConfirm={() => del.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={del.isPending} />

      {signupsFor && <SignupsModal opp={signupsFor} onClose={() => setSignupsFor(null)} />}
    </div>
  );
}

function SignupsModal({ opp, onClose }: { opp: VolunteerOpportunity; onClose: () => void }) {
  const { data: signups, isLoading } = useOpportunitySignups(opp.id);
  const updateStatus = useUpdateSignupStatus();

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="w-full max-w-lg rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4 max-h-[80vh] flex flex-col">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-slate-100">Applicants — {opp.title}</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-200 text-sm">Close</button>
        </div>

        <div className="flex-1 overflow-y-auto space-y-2">
          {isLoading ? (
            <div className="flex justify-center py-10"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
          ) : !signups?.length ? (
            <div className="flex flex-col items-center justify-center py-10 text-slate-500"><Users className="h-8 w-8 mb-2" /><p className="text-sm">No applicants yet</p></div>
          ) : (
            signups.map((s: VolunteerSignup) => (
              <div key={s.id} className="flex items-center gap-3 rounded-xl border border-slate-700 bg-slate-800 p-3">
                {s.user.avatarUrl ? (
                  <img src={s.user.avatarUrl} alt="" className="h-9 w-9 rounded-full object-cover border border-slate-700 shrink-0" />
                ) : (
                  <span className="h-9 w-9 rounded-full bg-slate-700 flex items-center justify-center shrink-0 text-sm font-bold text-slate-300">{s.user.name[0]}</span>
                )}
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-slate-100 text-sm">{s.user.name}</p>
                  <p className="text-xs text-slate-400">{s.user.email} · Applied {formatDate(s.appliedAt)}</p>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_COLORS[s.status] ?? 'bg-slate-700 text-slate-400'}`}>{s.status}</span>
                  {s.status === 'PENDING' && (
                    <>
                      <button onClick={() => updateStatus.mutate({ signupId: s.id, status: 'APPROVED' })} disabled={updateStatus.isPending} className="text-xs rounded-lg bg-emerald-600 px-2 py-1 text-white hover:bg-emerald-500 disabled:opacity-50">Approve</button>
                      <button onClick={() => updateStatus.mutate({ signupId: s.id, status: 'REJECTED' })} disabled={updateStatus.isPending} className="text-xs rounded-lg bg-red-700 px-2 py-1 text-white hover:bg-red-600 disabled:opacity-50">Reject</button>
                    </>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
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
