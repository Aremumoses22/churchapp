'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Save, Loader2 } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { useChurchInfo, useUpdateLogo, useUpdateCoverImage, useUpdateTimeline } from '@/hooks/useChurch';

export default function MediaBrandingPage() {
  const router = useRouter();
  const { data: church, isLoading } = useChurchInfo();
  const updateLogo = useUpdateLogo();
  const updateCover = useUpdateCoverImage();
  const updateTimeline = useUpdateTimeline();

  const [logoUrl, setLogoUrl] = useState('');
  const [coverImageUrl, setCoverImageUrl] = useState('');
  const [foundedYear, setFoundedYear] = useState('');
  const [history, setHistory] = useState('');

  useEffect(() => {
    if (church) {
      setLogoUrl(church.logoUrl ?? '');
      setCoverImageUrl(church.coverImageUrl ?? '');
      const s = church.settings as Record<string, unknown> | null;
      setFoundedYear(s?.foundedYear ? String(s.foundedYear) : '');
      setHistory(typeof s?.history === 'string' ? s.history : '');
    }
  }, [church]);

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
        title="Media & Branding"
        description="Manage your church logo, cover image, and history"
        actions={
          <button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100">
            <ArrowLeft className="h-4 w-4" /> Back
          </button>
        }
      />

      {/* Logo */}
      <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
        <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">Logo</h2>
        {logoUrl && (
          <img src={logoUrl} alt="Church logo" className="h-20 w-20 rounded-lg object-cover border border-slate-600" />
        )}
        <div className="flex gap-3 items-end">
          <div className="flex-1 space-y-1.5">
            <label className="text-sm font-medium text-slate-300">Logo URL</label>
            <input
              value={logoUrl}
              onChange={e => setLogoUrl(e.target.value)}
              className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
              placeholder="https://..."
            />
          </div>
          <button
            onClick={() => updateLogo.mutate(logoUrl)}
            disabled={updateLogo.isPending || !logoUrl}
            className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60"
          >
            {updateLogo.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            Save
          </button>
        </div>
      </section>

      {/* Cover Image */}
      <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
        <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">Cover Image</h2>
        {coverImageUrl && (
          <img src={coverImageUrl} alt="Cover" className="h-32 w-full rounded-lg object-cover border border-slate-600" />
        )}
        <div className="flex gap-3 items-end">
          <div className="flex-1 space-y-1.5">
            <label className="text-sm font-medium text-slate-300">Cover Image URL</label>
            <input
              value={coverImageUrl}
              onChange={e => setCoverImageUrl(e.target.value)}
              className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
              placeholder="https://..."
            />
          </div>
          <button
            onClick={() => updateCover.mutate(coverImageUrl)}
            disabled={updateCover.isPending || !coverImageUrl}
            className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60"
          >
            {updateCover.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            Save
          </button>
        </div>
      </section>

      {/* Church History / Timeline */}
      <section className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
        <h2 className="text-sm font-semibold text-slate-300 uppercase tracking-wider">History & Timeline</h2>
        <div className="space-y-1.5">
          <label className="text-sm font-medium text-slate-300">Founded Year</label>
          <input
            type="number"
            value={foundedYear}
            onChange={e => setFoundedYear(e.target.value)}
            className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
            placeholder="e.g. 1998"
          />
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium text-slate-300">Church History</label>
          <textarea
            value={history}
            onChange={e => setHistory(e.target.value)}
            rows={5}
            className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 resize-none"
            placeholder="A brief history of your church..."
          />
        </div>
        <div className="flex justify-end">
          <button
            onClick={() => updateTimeline.mutate({ foundedYear: foundedYear ? Number(foundedYear) : undefined, history })}
            disabled={updateTimeline.isPending}
            className="flex items-center gap-2 rounded-lg bg-indigo-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60"
          >
            {updateTimeline.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            Save Timeline
          </button>
        </div>
      </section>
    </div>
  );
}
