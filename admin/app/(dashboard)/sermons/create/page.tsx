'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Save, Loader2 } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { useCreateSermon } from '@/hooks/useSermons';
import { useSermonSeries } from '@/hooks/useSermons';

type FormState = {
  title: string; speaker: string; description: string; date: string;
  audioUrl: string; videoUrl: string; thumbnailUrl: string; scriptureRef: string;
  seriesId: string; tags: string;
};

const empty: FormState = { title: '', speaker: '', description: '', date: '', audioUrl: '', videoUrl: '', thumbnailUrl: '', scriptureRef: '', seriesId: '', tags: '' };

export default function CreateSermonPage() {
  const router = useRouter();
  const createSermon = useCreateSermon();
  const { data: seriesList } = useSermonSeries();
  const [form, setForm] = useState<FormState>(empty);

  const set = (k: keyof FormState) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) =>
    setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    createSermon.mutate(
      {
        ...form,
        tags: form.tags ? form.tags.split(',').map(t => t.trim()).filter(Boolean) : [],
        seriesId: form.seriesId || undefined,
        audioUrl: form.audioUrl || undefined,
        videoUrl: form.videoUrl || undefined,
        thumbnailUrl: form.thumbnailUrl || undefined,
        scriptureRef: form.scriptureRef || undefined,
        description: form.description || undefined,
      } as Parameters<typeof createSermon.mutate>[0],
      { onSuccess: () => router.push('/sermons') }
    );
  };

  return (
    <div className="space-y-6 max-w-3xl">
      <PageHeader
        title="Add Sermon"
        description="Create a new sermon record"
        actions={
          <button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100">
            <ArrowLeft className="h-4 w-4" /> Back
          </button>
        }
      />

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Core Info */}
        <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
          <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">Details</h2>
          <Field label="Title *" value={form.title} onChange={set('title')} required />
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Field label="Speaker *" value={form.speaker} onChange={set('speaker')} required />
            <Field label="Date *" value={form.date} onChange={set('date')} type="date" required />
          </div>
          <TextareaField label="Description" value={form.description} onChange={set('description')} rows={3} />
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Field label="Scripture Reference" value={form.scriptureRef} onChange={set('scriptureRef')} placeholder="e.g. John 3:16" />
            <div className="space-y-1.5">
              <label className="text-sm font-medium text-slate-300">Series</label>
              <select value={form.seriesId} onChange={set('seriesId')} className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                <option value="">No Series</option>
                {seriesList?.map(s => <option key={s.id} value={s.id}>{s.title}</option>)}
              </select>
            </div>
          </div>
          <Field label="Tags (comma-separated)" value={form.tags} onChange={set('tags')} placeholder="e.g. faith, hope, love" />
        </section>

        {/* Media URLs */}
        <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
          <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">Media</h2>
          <Field label="Audio URL" value={form.audioUrl} onChange={set('audioUrl')} type="url" placeholder="https://..." />
          <Field label="Video URL" value={form.videoUrl} onChange={set('videoUrl')} type="url" placeholder="https://..." />
          <Field label="Thumbnail URL" value={form.thumbnailUrl} onChange={set('thumbnailUrl')} type="url" placeholder="https://..." />
        </section>

        <div className="flex justify-end">
          <button type="submit" disabled={createSermon.isPending} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
            {createSermon.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            Save Sermon
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
