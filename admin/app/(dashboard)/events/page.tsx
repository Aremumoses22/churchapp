'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Plus, Search, Star, StarOff, Trash2, Pencil, Loader2, Calendar, Users, Filter } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useEvents, useDeleteEvent, useToggleEventFeatured, EVENT_CATEGORIES } from '@/hooks/useEvents';
import { formatDate } from '@/lib/format';

export default function EventsPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('');
  const [deleteTarget, setDeleteTarget] = useState<{ id: string; title: string } | null>(null);

  const { data, isLoading } = useEvents({ page, limit: 20, search: search || undefined, category: category || undefined });
  const deleteEvent = useDeleteEvent();
  const toggleFeatured = useToggleEventFeatured();

  const events = data?.events ?? [];
  const totalPages = data?.totalPages ?? 1;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Events"
        description="Manage church events and registrations"
        actions={
          <Link href="/events/create" className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500">
            <Plus className="h-4 w-4" /> Create Event
          </Link>
        }
      />

      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search events…" className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 pointer-events-none" />
          <select value={category} onChange={e => { setCategory(e.target.value); setPage(1); }} className="rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-8 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none appearance-none cursor-pointer capitalize">
            <option value="">All Categories</option>
            {EVENT_CATEGORIES.map(c => <option key={c} value={c} className="capitalize">{c}</option>)}
          </select>
        </div>
      </div>

      <div className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
        {isLoading ? (
          <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
        ) : events.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-slate-500">
            <Calendar className="h-10 w-10 mb-3" />
            <p className="font-medium text-slate-300">No events found</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-0 divide-y divide-slate-700/50 md:divide-y-0">
            {events.map(event => (
              <div key={event.id} className="p-5 border-b border-slate-700/50 last:border-0 space-y-3 hover:bg-slate-700/20 transition-colors">
                <div className="flex items-start gap-3">
                  {event.imageUrl ? (
                    <img src={event.imageUrl} alt="" className="h-14 w-20 rounded-lg object-cover shrink-0 border border-slate-700" />
                  ) : (
                    <span className="h-14 w-20 rounded-lg bg-slate-700 flex items-center justify-center shrink-0">
                      <Calendar className="h-6 w-6 text-slate-500" />
                    </span>
                  )}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-1">
                      <p className="font-semibold text-slate-100 leading-tight">{event.title}</p>
                      {event.isFeatured && <Star className="h-3.5 w-3.5 text-amber-400 fill-current shrink-0 mt-0.5" />}
                    </div>
                    <span className="inline-block rounded-full bg-indigo-500/20 px-2 py-0.5 text-xs text-indigo-400 capitalize mt-1">{event.category}</span>
                  </div>
                </div>
                <div className="text-xs text-slate-400 space-y-1">
                  <p className="flex items-center gap-1.5"><Calendar className="h-3 w-3" />{formatDate(event.startDate)}</p>
                  {event.location && <p className="truncate">📍 {event.location}</p>}
                  <p className="flex items-center gap-1.5"><Users className="h-3 w-3" />{event._count?.registrations ?? event.registeredCount} registered{event.maxCapacity ? ` / ${event.maxCapacity}` : ''}</p>
                </div>
                <div className="flex items-center justify-between pt-1">
                  <Link href={`/events/${event.id}/registrations`} className="text-xs text-indigo-400 hover:text-indigo-300">View registrations →</Link>
                  <div className="flex gap-1">
                    <button onClick={() => toggleFeatured.mutate(event.id)} title={event.isFeatured ? 'Unfeature' : 'Feature'} className="p-1.5 rounded-lg text-slate-400 hover:text-amber-400 hover:bg-slate-700">
                      {event.isFeatured ? <StarOff className="h-3.5 w-3.5" /> : <Star className="h-3.5 w-3.5" />}
                    </button>
                    <Link href={`/events/${event.id}/edit`} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700">
                      <Pencil className="h-3.5 w-3.5" />
                    </Link>
                    <button onClick={() => setDeleteTarget({ id: event.id, title: event.title })} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700">
                      <Trash2 className="h-3.5 w-3.5" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {totalPages > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} events total</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5 text-slate-300">{page} / {totalPages}</span>
            <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}

      <ConfirmDialog open={!!deleteTarget} title="Delete Event" description={`Delete "${deleteTarget?.title}"? This cannot be undone.`} onConfirm={() => deleteEvent.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={deleteEvent.isPending} />
    </div>
  );
}
