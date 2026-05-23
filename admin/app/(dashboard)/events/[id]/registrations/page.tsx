'use client';

import { useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { ArrowLeft, Loader2, Users, User } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { useEvent, useEventRegistrations } from '@/hooks/useEvents';
import { formatDate } from '@/lib/format';

export default function EventRegistrationsPage() {
  const { id = '' } = useParams() as { id: string };
  const router = useRouter();
  const [page, setPage] = useState(1);
  const { data: event } = useEvent(id);
  const { data, isLoading } = useEventRegistrations(id, page, 20);

  const registrations = data?.registrations ?? [];

  return (
    <div className="space-y-6 max-w-3xl">
      <PageHeader
        title="Registrations"
        description={event ? `${event.title} — ${data?.total ?? 0} registered` : 'Loading…'}
        actions={
          <button type="button" onClick={() => router.back()} className="flex items-center gap-2 text-sm text-slate-400 hover:text-slate-100">
            <ArrowLeft className="h-4 w-4" /> Back
          </button>
        }
      />

      <div className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
        {isLoading ? (
          <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
        ) : registrations.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-slate-500">
            <Users className="h-10 w-10 mb-3" />
            <p className="font-medium text-slate-300">No registrations yet</p>
          </div>
        ) : (
          <div className="divide-y divide-slate-700/50">
            {registrations.map(reg => (
              <div key={reg.id} className="flex items-center gap-4 p-4">
                {reg.user.avatarUrl ? (
                  <img src={reg.user.avatarUrl} alt="" className="h-9 w-9 rounded-full object-cover border border-slate-700" />
                ) : (
                  <span className="h-9 w-9 rounded-full bg-slate-700 flex items-center justify-center shrink-0"><User className="h-4 w-4 text-slate-400" /></span>
                )}
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-slate-100 truncate">{reg.user.name}</p>
                  <p className="text-xs text-slate-400">{reg.user.email}</p>
                </div>
                <div className="text-right shrink-0">
                  <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${reg.status === 'REGISTERED' ? 'bg-emerald-500/20 text-emerald-400' : 'bg-slate-700 text-slate-400'}`}>{reg.status}</span>
                  <p className="text-xs text-slate-500 mt-1">{formatDate(reg.registeredAt)}</p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} total</span>
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
