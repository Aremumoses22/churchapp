'use client';

import { useState } from 'react';
import { Plus, Search, Trash2, Pencil, Loader2, DollarSign, Tag, Target, Filter } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useDonations, useDonationSummary, useGivingCategories, useCreateGivingCategory, useUpdateGivingCategory, useDeleteGivingCategory, useGivingCampaigns, useCreateGivingCampaign, useUpdateGivingCampaign, useDeleteGivingCampaign, type GivingCategory, type GivingCampaign } from '@/hooks/useGiving';
import { formatCurrency, formatDate } from '@/lib/format';

type Tab = 'donations' | 'categories' | 'campaigns';

export default function GivingPage() {
  const [tab, setTab] = useState<Tab>('donations');
  const { data: summary } = useDonationSummary();

  return (
    <div className="space-y-6">
      <PageHeader title="Giving" description="Manage donations, giving categories, and campaigns" />

      {/* Summary Cards */}
      {summary && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[
            { label: 'Total Raised', value: formatCurrency(summary.totalRaised), color: 'text-emerald-400' },
            { label: 'This Month', value: formatCurrency(summary.thisMonth), color: 'text-indigo-400' },
            { label: 'Total Donations', value: summary.totalCount.toLocaleString(), color: 'text-slate-100' },
            { label: 'Pending', value: summary.pendingCount.toLocaleString(), color: 'text-amber-400' },
          ].map(({ label, value, color }) => (
            <div key={label} className="rounded-xl border border-slate-700 bg-slate-800 p-4">
              <p className="text-xs text-slate-400 mb-1">{label}</p>
              <p className={`text-xl font-bold ${color}`}>{value}</p>
            </div>
          ))}
        </div>
      )}

      {/* Tab Bar */}
      <div className="flex gap-1 rounded-xl border border-slate-700 bg-slate-800/50 p-1 w-fit">
        {([['donations', DollarSign, 'Donations'], ['categories', Tag, 'Categories'], ['campaigns', Target, 'Campaigns']] as const).map(([key, Icon, label]) => (
          <button key={key} onClick={() => setTab(key)} className={`flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium transition-colors ${tab === key ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-slate-100'}`}>
            <Icon className="h-4 w-4" />{label}
          </button>
        ))}
      </div>

      {tab === 'donations' && <DonationsTab />}
      {tab === 'categories' && <CategoriesTab />}
      {tab === 'campaigns' && <CampaignsTab />}
    </div>
  );
}

function DonationsTab() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const { data, isLoading } = useDonations({ page, limit: 20, search: search || undefined, status: status || undefined });
  const donations = data?.donations ?? [];

  return (
    <div className="space-y-4">
      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search by reference or donor…" className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 pointer-events-none" />
          <select value={status} onChange={e => { setStatus(e.target.value); setPage(1); }} className="rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-8 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none appearance-none cursor-pointer">
            <option value="">All Status</option>
            {['PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'].map(s => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>
      </div>
      <div className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
        {isLoading ? (
          <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
        ) : donations.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-slate-500"><DollarSign className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No donations found</p></div>
        ) : (
          <table className="w-full text-sm">
            <thead className="border-b border-slate-700 text-xs font-medium text-slate-400 uppercase tracking-wider">
              <tr>
                <th className="px-5 py-3 text-left">Donor</th>
                <th className="px-5 py-3 text-left hidden sm:table-cell">Amount</th>
                <th className="px-5 py-3 text-left hidden md:table-cell">Category</th>
                <th className="px-5 py-3 text-left hidden lg:table-cell">Status</th>
                <th className="px-5 py-3 text-left hidden xl:table-cell">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-700/50">
              {donations.map(d => (
                <tr key={d.id} className="hover:bg-slate-700/30">
                  <td className="px-5 py-3">
                    <p className="font-medium text-slate-100">{d.isAnonymous ? 'Anonymous' : d.user.name}</p>
                    <p className="text-xs text-slate-500 font-mono">{d.transactionRef.slice(0, 16)}…</p>
                  </td>
                  <td className="px-5 py-3 font-semibold text-emerald-400 hidden sm:table-cell">{formatCurrency(d.amount)}</td>
                  <td className="px-5 py-3 text-slate-400 hidden md:table-cell">{d.category?.name ?? '—'}</td>
                  <td className="px-5 py-3 hidden lg:table-cell">
                    <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${d.status === 'SUCCESS' ? 'bg-emerald-500/20 text-emerald-400' : d.status === 'PENDING' ? 'bg-amber-500/20 text-amber-400' : 'bg-red-500/20 text-red-400'}`}>{d.status}</span>
                  </td>
                  <td className="px-5 py-3 text-slate-400 hidden xl:table-cell whitespace-nowrap">{formatDate(d.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} donations</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5 text-slate-300">{page} / {data?.totalPages}</span>
            <button onClick={() => setPage(p => Math.min(data?.totalPages ?? 1, p + 1))} disabled={page === data?.totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}
    </div>
  );
}

function CategoriesTab() {
  const { data: categories, isLoading } = useGivingCategories();
  const create = useCreateGivingCategory();
  const update = useUpdateGivingCategory();
  const del = useDeleteGivingCategory();
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<GivingCategory | null>(null);
  const [form, setForm] = useState({ name: '', description: '', sortOrder: '0' });
  const [deleteTarget, setDeleteTarget] = useState<GivingCategory | null>(null);

  const openCreate = () => { setEditing(null); setForm({ name: '', description: '', sortOrder: String(categories?.length ?? 0) }); setOpen(true); };
  const openEdit = (c: GivingCategory) => { setEditing(c); setForm({ name: c.name, description: c.description ?? '', sortOrder: String(c.sortOrder) }); setOpen(true); };
  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { name: form.name, description: form.description || undefined, sortOrder: Number(form.sortOrder), isActive: true };
    if (editing) {
      update.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      create.mutate(payload as Parameters<typeof create.mutate>[0], { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500"><Plus className="h-4 w-4" /> Add Category</button>
      </div>
      {isLoading ? <div className="flex justify-center py-10"><Loader2 className="h-5 w-5 animate-spin text-indigo-400" /></div>
        : !categories || categories.length === 0 ? <EmptyState icon={Tag} label="No giving categories yet" />
        : (
          <div className="rounded-xl border border-slate-700 bg-slate-800 divide-y divide-slate-700/50">
            {categories.map(c => (
              <div key={c.id} className="flex items-center gap-4 px-5 py-4">
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-slate-100">{c.name}</p>
                  {c.description && <p className="text-sm text-slate-400 truncate">{c.description}</p>}
                </div>
                <span className={`rounded-full px-2 py-0.5 text-xs ${c.isActive ? 'bg-emerald-500/20 text-emerald-400' : 'bg-slate-700 text-slate-400'}`}>{c.isActive ? 'Active' : 'Inactive'}</span>
                <div className="flex gap-1">
                  <button onClick={() => openEdit(c)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                  <button onClick={() => setDeleteTarget(c)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
                </div>
              </div>
            ))}
          </div>
        )}
      {open && (
        <SmDialog title={editing ? 'Edit Category' : 'Add Category'} onClose={() => setOpen(false)}>
          <form onSubmit={handleSubmit} className="space-y-4">
            <SField label="Name *" value={form.name} onChange={set('name')} required />
            <SField label="Description" value={form.description} onChange={set('description')} />
            <SField label="Sort Order" value={form.sortOrder} onChange={set('sortOrder')} type="number" />
            <DlgActions onClose={() => setOpen(false)} loading={create.isPending || update.isPending} label={editing ? 'Save' : 'Add'} />
          </form>
        </SmDialog>
      )}
      <ConfirmDialog open={!!deleteTarget} title="Delete Category" description={`Delete "${deleteTarget?.name}"?`} onConfirm={() => del.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={del.isPending} />
    </div>
  );
}

function CampaignsTab() {
  const { data: campaigns, isLoading } = useGivingCampaigns();
  const create = useCreateGivingCampaign();
  const update = useUpdateGivingCampaign();
  const del = useDeleteGivingCampaign();
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<GivingCampaign | null>(null);
  const [form, setForm] = useState({ title: '', description: '', goalAmount: '', startDate: '', endDate: '', imageUrl: '' });
  const [deleteTarget, setDeleteTarget] = useState<GivingCampaign | null>(null);

  const openCreate = () => { setEditing(null); setForm({ title: '', description: '', goalAmount: '', startDate: '', endDate: '', imageUrl: '' }); setOpen(true); };
  const openEdit = (c: GivingCampaign) => { setEditing(c); setForm({ title: c.title, description: c.description ?? '', goalAmount: String(c.goalAmount), startDate: c.startDate.split('T')[0], endDate: c.endDate ? c.endDate.split('T')[0] : '', imageUrl: c.imageUrl ?? '' }); setOpen(true); };
  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { title: form.title, description: form.description || undefined, goalAmount: Number(form.goalAmount), startDate: form.startDate, endDate: form.endDate || undefined, imageUrl: form.imageUrl || undefined, isActive: true };
    if (editing) {
      update.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      create.mutate(payload as Parameters<typeof create.mutate>[0], { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500"><Plus className="h-4 w-4" /> New Campaign</button>
      </div>
      {isLoading ? <div className="flex justify-center py-10"><Loader2 className="h-5 w-5 animate-spin text-indigo-400" /></div>
        : !campaigns || campaigns.length === 0 ? <EmptyState icon={Target} label="No campaigns yet" />
        : (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {campaigns.map(c => {
              const pct = c.goalAmount > 0 ? Math.min(100, Math.round((c.raisedAmount / c.goalAmount) * 100)) : 0;
              return (
                <div key={c.id} className="rounded-xl border border-slate-700 bg-slate-800 p-5 space-y-3">
                  <div className="flex items-start justify-between gap-2">
                    <p className="font-semibold text-slate-100 leading-tight">{c.title}</p>
                    <div className="flex gap-1 shrink-0">
                      <button onClick={() => openEdit(c)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                      <button onClick={() => setDeleteTarget(c)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
                    </div>
                  </div>
                  <div className="space-y-1">
                    <div className="flex justify-between text-xs text-slate-400">
                      <span>{formatCurrency(c.raisedAmount)} raised</span>
                      <span>{pct}% of {formatCurrency(c.goalAmount)}</span>
                    </div>
                    <div className="h-2 rounded-full bg-slate-700 overflow-hidden">
                      <div className="h-full rounded-full bg-indigo-500 transition-all" style={{ width: `${pct}%` }} />
                    </div>
                  </div>
                  <p className="text-xs text-slate-500">{c.donorCount} donors · {formatDate(c.startDate)}{c.endDate ? ` – ${formatDate(c.endDate)}` : ''}</p>
                </div>
              );
            })}
          </div>
        )}
      {open && (
        <SmDialog title={editing ? 'Edit Campaign' : 'New Campaign'} onClose={() => setOpen(false)}>
          <form onSubmit={handleSubmit} className="space-y-4">
            <SField label="Title *" value={form.title} onChange={set('title')} required />
            <SField label="Goal Amount (₦) *" value={form.goalAmount} onChange={set('goalAmount')} type="number" required />
            <SField label="Description" value={form.description} onChange={set('description')} />
            <div className="grid grid-cols-2 gap-3">
              <SField label="Start Date *" value={form.startDate} onChange={set('startDate')} type="date" required />
              <SField label="End Date" value={form.endDate} onChange={set('endDate')} type="date" />
            </div>
            <SField label="Image URL" value={form.imageUrl} onChange={set('imageUrl')} placeholder="https://..." />
            <DlgActions onClose={() => setOpen(false)} loading={create.isPending || update.isPending} label={editing ? 'Save' : 'Create'} />
          </form>
        </SmDialog>
      )}
      <ConfirmDialog open={!!deleteTarget} title="Delete Campaign" description={`Delete "${deleteTarget?.title}"?`} onConfirm={() => del.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={del.isPending} />
    </div>
  );
}

function EmptyState({ icon: Icon, label }: { icon: React.ElementType; label: string }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-slate-500">
      <Icon className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">{label}</p>
    </div>
  );
}

function SmDialog({ title, children, onClose }: { title: string; children: React.ReactNode; onClose: () => void }) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4">
        <div className="flex items-center justify-between"><h3 className="text-lg font-semibold text-slate-100">{title}</h3><button onClick={onClose} className="text-slate-400 hover:text-slate-100 text-xl leading-none">×</button></div>
        {children}
      </div>
    </div>
  );
}

function SField({ label, required, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { label: string }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <input {...props} required={required} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
    </div>
  );
}

function DlgActions({ onClose, loading, label }: { onClose: () => void; loading: boolean; label: string }) {
  return (
    <div className="flex gap-3 justify-end pt-2">
      <button type="button" onClick={onClose} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
      <button type="submit" disabled={loading} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
        {loading && <Loader2 className="h-4 w-4 animate-spin" />}{label}
      </button>
    </div>
  );
}
