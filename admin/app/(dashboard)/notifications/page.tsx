'use client';

import { useState } from 'react';
import { Send, Trash2, Loader2, Bell, Filter } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { useAdminNotifications, useSendNotificationToAll, useDeleteAdminNotification, NOTIFICATION_TYPES, type AdminNotification } from '@/hooks/useNotifications';
import { formatDate } from '@/lib/format';

type NF = { type: string; title: string; body: string };
const emptyNF: NF = { type: 'ANNOUNCEMENT', title: '', body: '' };

const TYPE_COLORS: Record<string, string> = {
  SERMON: 'bg-purple-500/20 text-purple-400',
  EVENT: 'bg-blue-500/20 text-blue-400',
  GIVING: 'bg-emerald-500/20 text-emerald-400',
  PRAYER: 'bg-rose-500/20 text-rose-400',
  ANNOUNCEMENT: 'bg-amber-500/20 text-amber-400',
  GROUP: 'bg-indigo-500/20 text-indigo-400',
  FORUM: 'bg-teal-500/20 text-teal-400',
  VOLUNTEER: 'bg-orange-500/20 text-orange-400',
};

export default function NotificationsPage() {
  const [page, setPage] = useState(1);
  const [form, setForm] = useState<NF>(emptyNF);
  const [sending, setSending] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<AdminNotification | null>(null);
  const [sent, setSent] = useState<{ count: number } | null>(null);

  const { data, isLoading } = useAdminNotifications({ page, limit: 20 });
  const sendAll = useSendNotificationToAll();
  const del = useDeleteAdminNotification();

  const notifications = data?.notifications ?? [];

  const set = (k: keyof NF) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault();
    sendAll.mutate(form, {
      onSuccess: (res) => {
        setSent({ count: res.data?.data?.sent ?? 0 });
        setForm(emptyNF);
      },
    });
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Notifications" description="Broadcast push notifications to all church members" />

      {/* Send Form */}
      <div className="rounded-xl border border-slate-700 bg-slate-800 p-6 space-y-4">
        <h3 className="font-semibold text-slate-100 flex items-center gap-2"><Send className="h-4 w-4 text-indigo-400" /> Send Broadcast Notification</h3>
        <form onSubmit={handleSend} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-sm font-medium text-slate-300">Type *</label>
              <select value={form.type} onChange={set('type')} className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none">
                {NOTIFICATION_TYPES.map(t => <option key={t} value={t}>{t}</option>)}
              </select>
            </div>
            <div className="space-y-1.5">
              <label className="text-sm font-medium text-slate-300">Title *</label>
              <input value={form.title} onChange={set('title')} required placeholder="Notification title…" className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
            </div>
          </div>
          <div className="space-y-1.5">
            <label className="text-sm font-medium text-slate-300">Message *</label>
            <textarea value={form.body} onChange={set('body')} required rows={3} placeholder="Write your message here…" className="w-full rounded-lg border border-slate-600 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none resize-none" />
          </div>
          <div className="flex items-center gap-3">
            <button type="submit" disabled={sendAll.isPending || !form.title || !form.body} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
              {sendAll.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
              {sendAll.isPending ? 'Sending…' : 'Send to All Members'}
            </button>
            {sent && (
              <p className="text-sm text-emerald-400">✓ Sent to {sent.count} member{sent.count !== 1 ? 's' : ''}</p>
            )}
          </div>
        </form>
      </div>

      {/* History */}
      <div className="space-y-4">
        <h3 className="font-semibold text-slate-200">Notification History</h3>

        {isLoading ? (
          <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
        ) : notifications.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-slate-500"><Bell className="h-10 w-10 mb-3" /><p className="font-medium text-slate-300">No notifications sent yet</p></div>
        ) : (
          <div className="space-y-2">
            {notifications.map(n => (
              <div key={n.id} className="rounded-xl border border-slate-700 bg-slate-800 p-4 flex items-start gap-3">
                <span className={`rounded-full px-2 py-0.5 text-xs font-medium shrink-0 mt-0.5 ${TYPE_COLORS[n.type] ?? 'bg-slate-700 text-slate-400'}`}>{n.type}</span>
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-slate-100 text-sm">{n.title}</p>
                  <p className="text-sm text-slate-400 line-clamp-2 mt-0.5">{n.body}</p>
                  <p className="text-xs text-slate-500 mt-1">To: {n.user.name} · {formatDate(n.createdAt)}</p>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  {n.isRead ? (
                    <span className="text-xs text-slate-500">Read</span>
                  ) : (
                    <span className="h-2 w-2 rounded-full bg-indigo-400" />
                  )}
                  <button onClick={() => setDeleteTarget(n)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-4 w-4" /></button>
                </div>
              </div>
            ))}
          </div>
        )}

        {(data?.totalPages ?? 1) > 1 && (
          <div className="flex items-center justify-between text-sm text-slate-400">
            <span>{data?.total} notifications</span>
            <div className="flex gap-2">
              <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
              <span className="px-3 py-1.5">{page} / {data?.totalPages}</span>
              <button onClick={() => setPage(p => Math.min(data?.totalPages ?? 1, p + 1))} disabled={page === data?.totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
            </div>
          </div>
        )}
      </div>

      <ConfirmDialog open={!!deleteTarget} title="Delete Notification" description="Delete this notification record?" onConfirm={() => del.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={del.isPending} />
    </div>
  );
}
