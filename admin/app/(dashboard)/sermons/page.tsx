'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Plus, Search, Star, StarOff, Trash2, Pencil, Loader2, BookOpen, Filter } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useSermons, useDeleteSermon, useToggleFeatured, useSermonSeries } from '@/hooks/useSermons';
import { formatDate } from '@/lib/format';

export default function SermonsPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [seriesId, setSeriesId] = useState('');
  const [deleteTarget, setDeleteTarget] = useState<{ id: string; title: string } | null>(null);

  const { data, isLoading } = useSermons({ page, limit: 20, search: search || undefined, seriesId: seriesId || undefined });
  const { data: allSeries } = useSermonSeries();
  const deleteSermon = useDeleteSermon();
  const toggleFeatured = useToggleFeatured();

  const sermons = data?.sermons ?? [];
  const totalPages = data?.totalPages ?? 1;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Sermons"
        description="Manage sermon recordings, series, and content"
        actions={
          <div className="flex items-center gap-3">
            <Link href="/sermons/series" className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">
              Manage Series
            </Link>
            <Link href="/sermons/create" className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500">
              <Plus className="h-4 w-4" /> Add Sermon
            </Link>
          </div>
        }
      />

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
          <input
            value={search}
            onChange={e => { setSearch(e.target.value); setPage(1); }}
            placeholder="Search by title or speaker…"
            className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
          />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 pointer-events-none" />
          <select
            value={seriesId}
            onChange={e => { setSeriesId(e.target.value); setPage(1); }}
            className="rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-8 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none appearance-none cursor-pointer"
          >
            <option value="">All Series</option>
            {allSeries?.map(s => <option key={s.id} value={s.id}>{s.title}</option>)}
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
        {isLoading ? (
          <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
        ) : sermons.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-slate-500">
            <BookOpen className="h-10 w-10 mb-3" />
            <p className="font-medium text-slate-300">No sermons found</p>
            <p className="text-sm mt-1">Add your first sermon to get started</p>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="border-b border-slate-700 text-xs font-medium text-slate-400 uppercase tracking-wider">
              <tr>
                <th className="px-5 py-3 text-left">Sermon</th>
                <th className="px-5 py-3 text-left hidden md:table-cell">Speaker</th>
                <th className="px-5 py-3 text-left hidden lg:table-cell">Series</th>
                <th className="px-5 py-3 text-left hidden sm:table-cell">Date</th>
                <th className="px-5 py-3 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-700/50">
              {sermons.map(sermon => (
                <tr key={sermon.id} className="hover:bg-slate-700/30 transition-colors">
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-3">
                      {sermon.thumbnailUrl ? (
                        <img src={sermon.thumbnailUrl} alt="" className="h-10 w-16 rounded object-cover shrink-0 border border-slate-700" />
                      ) : (
                        <span className="h-10 w-16 rounded bg-slate-700 flex items-center justify-center shrink-0">
                          <BookOpen className="h-4 w-4 text-slate-500" />
                        </span>
                      )}
                      <div className="min-w-0">
                        <p className="font-medium text-slate-100 truncate max-w-[180px]">{sermon.title}</p>
                        {sermon.scriptureRef && <p className="text-xs text-indigo-400 truncate">{sermon.scriptureRef}</p>}
                        {sermon.isFeatured && <span className="inline-flex items-center gap-1 text-xs text-amber-400"><Star className="h-3 w-3 fill-current" /> Featured</span>}
                      </div>
                    </div>
                  </td>
                  <td className="px-5 py-4 text-slate-300 hidden md:table-cell">{sermon.speaker}</td>
                  <td className="px-5 py-4 hidden lg:table-cell">
                    {sermon.series ? <span className="rounded-full bg-slate-700 px-2.5 py-0.5 text-xs text-slate-300">{sermon.series.title}</span> : <span className="text-slate-600">—</span>}
                  </td>
                  <td className="px-5 py-4 text-slate-400 hidden sm:table-cell whitespace-nowrap">{formatDate(sermon.date)}</td>
                  <td className="px-5 py-4">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => toggleFeatured.mutate(sermon.id)}
                        title={sermon.isFeatured ? 'Unfeature' : 'Feature'}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-amber-400 hover:bg-slate-700"
                      >
                        {sermon.isFeatured ? <StarOff className="h-4 w-4" /> : <Star className="h-4 w-4" />}
                      </button>
                      <Link href={`/sermons/${sermon.id}/edit`} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700">
                        <Pencil className="h-4 w-4" />
                      </Link>
                      <button onClick={() => setDeleteTarget({ id: sermon.id, title: sermon.title })} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700">
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} sermons total</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5 text-slate-300">{page} / {totalPages}</span>
            <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete Sermon"
        description={`Delete "${deleteTarget?.title}"? This cannot be undone.`}
        onConfirm={() => deleteSermon.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })}
        onClose={() => setDeleteTarget(null)}
        loading={deleteSermon.isPending}
      />
    </div>
  );
}
