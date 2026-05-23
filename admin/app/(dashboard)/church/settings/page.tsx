'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Save, Loader2 } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { useChurchInfo, useUpdateChurchInfo } from '@/hooks/useChurch';

export default function ChurchSettingsPage() {
  const router = useRouter();
  const { data: church, isLoading } = useChurchInfo();
  const update = useUpdateChurchInfo();

  const [form, setForm] = useState({
    name: '', tagline: '', mission: '', vision: '', description: '',
    phone: '', email: '', website: '',
    address: '', city: '', state: '', country: '',
  });

  useEffect(() => {
    if (church) {
      setForm({
        name: church.name ?? '',
        tagline: church.tagline ?? '',
        mission: church.mission ?? '',
        vision: church.vision ?? '',
        description: church.description ?? '',
        phone: church.phone ?? '',
        email: church.email ?? '',
        website: church.website ?? '',
        address: church.address ?? '',
        city: church.city ?? '',
        state: church.state ?? '',
        country: church.country ?? '',
      });
    }
  }, [church]);

  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    update.mutate(form);
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[40vh]">
        <Loader2 className="h-6 w-6 animate-spin text-indigo-400" />
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-3xl">
      <PageHeader
        title="General Settings"
        description="Update your church's core profile information"
        actions={
          <button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100">
            <ArrowLeft className="h-4 w-4" /> Back
          </button>
        }
      />

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Identity */}
        <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
          <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">Identity</h2>
          <Field label="Church Name *" value={form.name} onChange={set('name')} required />
          <Field label="Tagline" value={form.tagline} onChange={set('tagline')} />
          <TextareaField label="Mission Statement" value={form.mission} onChange={set('mission')} rows={3} />
          <TextareaField label="Vision Statement" value={form.vision} onChange={set('vision')} rows={3} />
          <TextareaField label="Description" value={form.description} onChange={set('description')} rows={4} />
        </section>

        {/* Contact */}
        <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
          <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">Contact</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Field label="Phone" value={form.phone} onChange={set('phone')} type="tel" />
            <Field label="Email" value={form.email} onChange={set('email')} type="email" />
          </div>
          <Field label="Website" value={form.website} onChange={set('website')} type="url" placeholder="https://" />
        </section>

        {/* Location */}
        <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
          <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">Location</h2>
          <Field label="Street Address" value={form.address} onChange={set('address')} />
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <Field label="City" value={form.city} onChange={set('city')} />
            <Field label="State / Province" value={form.state} onChange={set('state')} />
            <Field label="Country" value={form.country} onChange={set('country')} />
          </div>
        </section>

        <div className="flex justify-end">
          <button
            type="submit"
            disabled={update.isPending}
            className="flex items-center gap-2 rounded-lg bg-indigo-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60"
          >
            {update.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            Save Changes
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
      <input
        {...props}
        required={required}
        className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
      />
    </div>
  );
}

function TextareaField({ label, rows = 3, ...props }: React.TextareaHTMLAttributes<HTMLTextAreaElement> & { label: string; rows?: number }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <textarea
        {...props}
        rows={rows}
        className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 resize-none"
      />
    </div>
  );
}
