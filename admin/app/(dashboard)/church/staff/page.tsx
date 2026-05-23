'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Plus, Pencil, Trash2, Loader2, User } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useChurchInfo, useCreateStaff, useUpdateStaff, useDeleteStaff, type StaffMember } from '@/hooks/useChurch';

type FormState = Omit<StaffMember, 'id'>;

const empty: FormState = { name: '', title: '', bio: '', imageUrl: '', email: '', phone: '', order: 0 };

export default function StaffPage() {
  const router = useRouter();
  const { data: church, isLoading } = useChurchInfo();
  const createStaff = useCreateStaff();
  const updateStaff = useUpdateStaff();
  const deleteStaff = useDeleteStaff();

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<StaffMember | null>(null);
  const [form, setForm] = useState<FormState>(empty);
  const [deleteTarget, setDeleteTarget] = useState<StaffMember | null>(null);

  const staff = church?.staff ?? [];

  const openCreate = () => { setEditing(null); setForm(empty); setOpen(true); };
  const openEdit = (s: StaffMember) => { setEditing(s); setForm({ name: s.name, title: s.title, bio: s.bio ?? '', imageUrl: s.imageUrl ?? '', email: s.email ?? '', phone: s.phone ?? '', order: s.order }); setOpen(true); };

  const set = (k: keyof FormState) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(f => ({ ...f, [k]: k === 'order' ? Number(e.target.value) : e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editing) {
      updateStaff.mutate({ id: editing.id, ...form }, { onSuccess: () => setOpen(false) });
    } else {
      createStaff.mutate(form, { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Staff & Leadership"
        description="Manage your church staff members"
        actions={
          <div className="flex items-center gap-3">
            <button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100">
              <ArrowLeft className="h-4 w-4" /> Back
            </button>
            <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500">
              <Plus className="h-4 w-4" /> Add Staff
            </button>
          </div>
        }
      />

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : staff.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-500">
          <User className="h-10 w-10 mb-3" />
          <p className="font-medium text-slate-300">No staff members yet</p>
          <p className="text-sm mt-1">Add your first staff member to get started</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[...staff].sort((a, b) => a.order - b.order).map(s => (
            <div key={s.id} className="rounded-xl border border-slate-700 bg-slate-800 p-5 flex gap-4">
              {s.imageUrl ? (
                <img src={s.imageUrl} alt={s.name} className="h-14 w-14 rounded-full object-cover shrink-0 border border-slate-600" />
              ) : (
                <span className="h-14 w-14 rounded-full bg-slate-700 flex items-center justify-center shrink-0">
                  <User className="h-6 w-6 text-slate-400" />
                </span>
              )}
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-slate-100 truncate">{s.name}</p>
                <p className="text-sm text-indigo-400 truncate">{s.title}</p>
                {s.email && <p className="text-xs text-slate-500 mt-1 truncate">{s.email}</p>}
              </div>
              <div className="flex flex-col gap-1 shrink-0">
                <button onClick={() => openEdit(s)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700">
                  <Pencil className="h-3.5 w-3.5" />
                </button>
                <button onClick={() => setDeleteTarget(s)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700">
                  <Trash2 className="h-3.5 w-3.5" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add/Edit Dialog */}
      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-5">
            <h3 className="text-lg font-semibold text-slate-100">{editing ? 'Edit Staff Member' : 'Add Staff Member'}</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <Field label="Name *" value={form.name} onChange={set('name')} required />
              <Field label="Title / Role *" value={form.title} onChange={set('title')} required />
              <div className="grid grid-cols-2 gap-3">
                <Field label="Email" value={form.email ?? ''} onChange={set('email')} type="email" />
                <Field label="Phone" value={form.phone ?? ''} onChange={set('phone')} />
              </div>
              <Field label="Photo URL" value={form.imageUrl ?? ''} onChange={set('imageUrl')} placeholder="https://..." />
              <TextareaField label="Bio" value={form.bio ?? ''} onChange={set('bio')} rows={3} />
              <Field label="Display Order" value={String(form.order)} onChange={set('order')} type="number" />
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
                <button type="submit" disabled={createStaff.isPending || updateStaff.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
                  {(createStaff.isPending || updateStaff.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}
                  {editing ? 'Save Changes' : 'Add Staff'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete Staff Member"
        description={`Remove ${deleteTarget?.name} from the staff list?`}
        onConfirm={() => { deleteStaff.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) }); }}
        onClose={() => setDeleteTarget(null)}
        loading={deleteStaff.isPending}
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

function TextareaField({ label, rows = 3, ...props }: React.TextareaHTMLAttributes<HTMLTextAreaElement> & { label: string; rows?: number }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <textarea {...props} rows={rows} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 resize-none" />
    </div>
  );
}
