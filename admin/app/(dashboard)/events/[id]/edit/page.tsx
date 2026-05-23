'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { ArrowLeft, Save, Loader2 } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { useEvent, useUpdateEvent, EVENT_CATEGORIES } from '@/hooks/useEvents';

type F = { title: string; description: string; category: string; location: string; startDate: string; endDate: string; imageUrl: string; registrationRequired: boolean; maxCapacity: string; tags: string };

export default function EditEventPage() {
  const { id = '' } = useParams() as { id: string };
  const router = useRouter();
  const { data: event, isLoading } = useEvent(id);
  const updateEvent = useUpdateEvent();
  const [form, setForm] = useState<F>({ title: '', description: '', category: 'worship', location: '', startDate: '', endDate: '', imageUrl: '', registrationRequired: false, maxCapacity: '', tags: '' });

  useEffect(() => {
    if (event) {
      setForm({
        title: event.title, description: event.description ?? '', category: event.category,
        location: event.location ?? '', imageUrl: event.imageUrl ?? '',
        startDate: event.startDate ? event.startDate.slice(0, 16) : '',
        endDate: event.endDate ? event.endDate.slice(0, 16) : '',
        registrationRequired: event.registrationRequired,
        maxCapacity: event.maxCapacity ? String(event.maxCapacity) : '',
        tags: event.tags.join(', '),
      });
    }
  }, [event]);

  const set = (k: keyof F) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) =>
    setForm(f => ({ ...f, [k]: k === 'registrationRequired' ? (e.target as HTMLInputElement).checked : e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    updateEvent.mutate({
      id, title: form.title, description: form.description || null, category: form.category,
      location: form.location || null, startDate: form.startDate, endDate: form.endDate || null,
      imageUrl: form.imageUrl || null, registrationRequired: form.registrationRequired,
      maxCapacity: form.maxCapacity ? Number(form.maxCapacity) : null,
      tags: form.tags ? form.tags.split(',').map(t => t.trim()).filter(Boolean) : [],
    }, { onSuccess: () => router.push('/events') });
  };

  if (isLoading) return <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>;

  return (
    <div className="space-y-6 max-w-3xl">
      <PageHeader title="Edit Event" description={event?.title ?? ''}
        actions={<button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100"><ArrowLeft className="h-4 w-4" /> Back</button>}
      />
      <form onSubmit={handleSubmit} className="space-y-6">
        <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
          <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">Details</h2>
          <Field label="Title *" value={form.title} onChange={set('title')} required />
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-sm font-medium text-slate-300">Category *</label>
              <select value={form.category} onChange={set('category')} className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none capitalize">
                {EVENT_CATEGORIES.map(c => <option key={c} value={c} className="capitalize">{c}</option>)}
              </select>
            </div>
            <Field label="Location" value={form.location} onChange={set('location')} />
          </div>
          <TextareaField label="Description" value={form.description} onChange={set('description')} rows={3} />
          <div className="grid grid-cols-2 gap-4">
            <Field label="Start Date & Time *" value={form.startDate} onChange={set('startDate')} type="datetime-local" required />
            <Field label="End Date & Time" value={form.endDate} onChange={set('endDate')} type="datetime-local" />
          </div>
          <Field label="Tags (comma-separated)" value={form.tags} onChange={set('tags')} placeholder="e.g. youth, conference" />
        </section>
        <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
          <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">Registration & Media</h2>
          <label className="flex items-center gap-2 text-sm text-slate-300 cursor-pointer">
            <input type="checkbox" checked={form.registrationRequired} onChange={set('registrationRequired')} className="rounded border-slate-600" />
            Registration Required
          </label>
          {form.registrationRequired && <Field label="Max Capacity" value={form.maxCapacity} onChange={set('maxCapacity')} type="number" />}
          <Field label="Cover Image URL" value={form.imageUrl} onChange={set('imageUrl')} placeholder="https://..." />
        </section>
        <div className="flex justify-end">
          <button type="submit" disabled={updateEvent.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
            {updateEvent.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />} Save Changes
          </button>
        </div>
      </form>
    </div>
  );
}

function Field({ label, required, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { label: string }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <input {...props} required={required} className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
    </div>
  );
}

function TextareaField({ label, rows = 3, ...props }: React.TextareaHTMLAttributes<HTMLTextAreaElement> & { label: string; rows?: number }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <textarea {...props} rows={rows} className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 resize-none" />
    </div>
  );
}
