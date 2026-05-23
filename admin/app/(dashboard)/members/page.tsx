'use client';

import { useState, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useMembers, useSetMemberStatus, useDeleteMember } from '@/hooks/useMembers';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { RoleBadge } from '@/components/members/RoleBadge';
import { InviteMemberDialog } from '@/components/members/InviteMemberDialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { formatDate } from '@/lib/format';
import { api } from '@/lib/api';
import { Search, Download, ChevronLeft, ChevronRight, Eye, Pencil, Trash2, PowerOff, Power } from 'lucide-react';

const ROLES = ['MEMBER', 'LEADER', 'PASTOR', 'ADMIN', 'SUPER_ADMIN'];

export default function MembersPage() {
  const router = useRouter();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [deleteTarget, setDeleteTarget] = useState<string | null>(null);
  const [showInvite, setShowInvite] = useState(false);

  const { data, isLoading } = useMembers({
    page, limit: 20,
    search: search || undefined,
    role: roleFilter || undefined,
    status: statusFilter || undefined,
  });

  const setStatus = useSetMemberStatus();
  const deleteMember = useDeleteMember();

  const members = data?.data ?? [];
  const meta = data?.meta;

  const handleExport = useCallback(async () => {
    const res = await api.get('/members/export', { responseType: 'blob' });
    const url = URL.createObjectURL(new Blob([res.data]));
    const a = document.createElement('a');
    a.href = url; a.download = 'members.csv'; a.click();
    URL.revokeObjectURL(url);
  }, []);

  return (
    <div className="space-y-5">
      <PageHeader
        title="Members"
        description={meta ? `${meta.total.toLocaleString()} total` : 'All church members'}
        actions={
          <div className="flex gap-2">
            <Button size="sm" onClick={() => setShowInvite(true)}>+ Invite Member</Button>
            <Button variant="outline" size="sm" onClick={handleExport} className="border-slate-600 text-slate-300 hover:bg-slate-700">
              <Download className="w-4 h-4 mr-2" /> Export CSV
            </Button>
          </div>
        }
      />

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        <div className="relative flex-1 min-w-48">
          <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <Input
            placeholder="Search name or email…"
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            className="pl-9 bg-slate-800 border-slate-600 text-slate-100 placeholder:text-slate-500"
          />
        </div>
        <Select value={roleFilter} onValueChange={(v) => { setRoleFilter((v ?? 'all') === 'all' ? '' : (v ?? '')); setPage(1); }}>
          <SelectTrigger className="w-40 bg-slate-800 border-slate-600 text-slate-300">
            <SelectValue placeholder="All roles" />
          </SelectTrigger>
          <SelectContent className="bg-slate-800 border-slate-700">
            <SelectItem value="all" className="text-slate-300">All roles</SelectItem>
            {ROLES.map((r) => <SelectItem key={r} value={r} className="text-slate-300">{r.replace('_', ' ')}</SelectItem>)}
          </SelectContent>
        </Select>
        <Select value={statusFilter} onValueChange={(v) => { setStatusFilter((v ?? 'all') === 'all' ? '' : (v ?? '')); setPage(1); }}>
          <SelectTrigger className="w-36 bg-slate-800 border-slate-600 text-slate-300">
            <SelectValue placeholder="All status" />
          </SelectTrigger>
          <SelectContent className="bg-slate-800 border-slate-700">
            <SelectItem value="all" className="text-slate-300">All status</SelectItem>
            <SelectItem value="active" className="text-slate-300">Active</SelectItem>
            <SelectItem value="inactive" className="text-slate-300">Inactive</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Table */}
      <div className="bg-slate-800 border border-slate-700 rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-700 text-left">
                <th className="px-4 py-3 text-xs font-medium text-slate-400 uppercase tracking-wide">Member</th>
                <th className="px-4 py-3 text-xs font-medium text-slate-400 uppercase tracking-wide">Role</th>
                <th className="px-4 py-3 text-xs font-medium text-slate-400 uppercase tracking-wide hidden md:table-cell">Department</th>
                <th className="px-4 py-3 text-xs font-medium text-slate-400 uppercase tracking-wide hidden lg:table-cell">Joined</th>
                <th className="px-4 py-3 text-xs font-medium text-slate-400 uppercase tracking-wide">Status</th>
                <th className="px-4 py-3 text-xs font-medium text-slate-400 uppercase tracking-wide text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                Array.from({ length: 8 }).map((_, i) => (
                  <tr key={i} className="border-b border-slate-700/50">
                    {Array.from({ length: 6 }).map((_, j) => (
                      <td key={j} className="px-4 py-3"><div className="h-4 bg-slate-700 rounded animate-pulse" /></td>
                    ))}
                  </tr>
                ))
              ) : members.length === 0 ? (
                <tr><td colSpan={6} className="px-4 py-12 text-center text-slate-400">No members found</td></tr>
              ) : members.map((member) => (
                <tr key={member.id} className="border-b border-slate-700/50 hover:bg-slate-700/30 transition-colors">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-3">
                      <Avatar className="w-8 h-8 shrink-0">
                        <AvatarImage src={member.avatarUrl ?? ''} />
                        <AvatarFallback className="bg-slate-600 text-slate-200 text-xs">{member.name.slice(0, 2).toUpperCase()}</AvatarFallback>
                      </Avatar>
                      <div>
                        <p className="font-medium text-slate-100">{member.name}</p>
                        <p className="text-xs text-slate-400">{member.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3"><RoleBadge role={member.role} /></td>
                  <td className="px-4 py-3 text-slate-400 hidden md:table-cell">{member.department ?? '—'}</td>
                  <td className="px-4 py-3 text-slate-400 hidden lg:table-cell">{formatDate(member.createdAt)}</td>
                  <td className="px-4 py-3">
                    <Badge variant="outline" className={member.isActive ? 'border-emerald-500/40 text-emerald-400' : 'border-red-500/40 text-red-400'}>
                      {member.isActive ? 'Active' : 'Inactive'}
                    </Badge>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center justify-end gap-1">
                      <Button variant="ghost" size="icon" className="w-8 h-8 text-slate-400 hover:text-slate-100" onClick={() => router.push(`/members/${member.id}`)}>
                        <Eye className="w-4 h-4" />
                      </Button>
                      <Button variant="ghost" size="icon" className="w-8 h-8 text-slate-400 hover:text-slate-100" onClick={() => router.push(`/members/${member.id}/edit`)}>
                        <Pencil className="w-4 h-4" />
                      </Button>
                      <Button variant="ghost" size="icon"
                        className={`w-8 h-8 ${member.isActive ? 'text-amber-400 hover:text-amber-300' : 'text-emerald-400 hover:text-emerald-300'}`}
                        onClick={() => setStatus.mutate({ id: member.id, isActive: !member.isActive })}
                        title={member.isActive ? 'Deactivate' : 'Activate'}
                      >
                        {member.isActive ? <PowerOff className="w-4 h-4" /> : <Power className="w-4 h-4" />}
                      </Button>
                      <Button variant="ghost" size="icon" className="w-8 h-8 text-red-400 hover:text-red-300" onClick={() => setDeleteTarget(member.id)}>
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {meta && meta.totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-slate-700">
            <p className="text-sm text-slate-400">Page {meta.page} of {meta.totalPages} · {meta.total} members</p>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={() => setPage((p) => Math.max(1, p - 1))} disabled={page === 1} className="border-slate-600 text-slate-300 hover:bg-slate-700">
                <ChevronLeft className="w-4 h-4" />
              </Button>
              <Button variant="outline" size="sm" onClick={() => setPage((p) => Math.min(meta.totalPages, p + 1))} disabled={page === meta.totalPages} className="border-slate-600 text-slate-300 hover:bg-slate-700">
                <ChevronRight className="w-4 h-4" />
              </Button>
            </div>
          </div>
        )}
      </div>

      <InviteMemberDialog open={showInvite} onClose={() => setShowInvite(false)} />

      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={() => deleteMember.mutate(deleteTarget!, { onSuccess: () => setDeleteTarget(null) })}
        title="Delete Member"
        description="This permanently deletes the member account and all associated data. This cannot be undone."
        confirmLabel="Delete"
        loading={deleteMember.isPending}
      />
    </div>
  );
}
