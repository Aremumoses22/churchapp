'use client';

import { useParams, useRouter } from 'next/navigation';
import { useMember, useChangeRole, useSetMemberStatus, useDeleteMember, useMemberGivingHistory } from '@/hooks/useMembers';
import { useAdminUser } from '@/hooks/useAdmin';
import { PageHeader } from '@/components/shared/PageHeader';
import { RoleBadge } from '@/components/members/RoleBadge';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { formatDate, formatCurrency, formatRelativeTime } from '@/lib/format';
import { ArrowLeft, Pencil, Trash2, Mail, Phone, Building2 } from 'lucide-react';
import { useState } from 'react';

const ROLES = ['MEMBER', 'LEADER', 'PASTOR', 'ADMIN', 'SUPER_ADMIN'];

export default function MemberDetailPage() {
  const { id = '' } = useParams() as { id: string };
  const router = useRouter();
  const { data: me } = useAdminUser();
  const { data: member, isLoading } = useMember(id);
  const changeRole = useChangeRole();
  const setStatus = useSetMemberStatus();
  const deleteMember = useDeleteMember();
  const { data: giving } = useMemberGivingHistory(id);
  const [showDelete, setShowDelete] = useState(false);

  if (isLoading) {
    return <div className="space-y-4">{Array.from({ length: 4 }).map((_, i) => <div key={i} className="h-20 bg-slate-800 rounded-xl animate-pulse" />)}</div>;
  }

  if (!member) return <p className="text-slate-400">Member not found.</p>;

  const isSuperAdmin = me?.role === 'SUPER_ADMIN';

  return (
    <div className="space-y-6 max-w-4xl">
      <div className="flex items-center gap-3">
        <Button variant="ghost" size="icon" onClick={() => router.back()} className="text-slate-400 hover:text-slate-100">
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <PageHeader
          title={member.name}
          description={member.email}
          actions={
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={() => router.push(`/members/${id}/edit`)} className="border-slate-600 text-slate-300 hover:bg-slate-700">
                <Pencil className="w-4 h-4 mr-2" /> Edit
              </Button>
              <Button variant="outline" size="sm" onClick={() => setShowDelete(true)} className="border-red-500/40 text-red-400 hover:bg-red-400/10">
                <Trash2 className="w-4 h-4 mr-2" /> Delete
              </Button>
            </div>
          }
        />
      </div>

      {/* Profile card */}
      <div className="bg-slate-800 border border-slate-700 rounded-xl p-6 flex flex-col sm:flex-row gap-6">
        <Avatar className="w-20 h-20 shrink-0">
          <AvatarImage src={member.avatarUrl ?? ''} />
          <AvatarFallback className="bg-slate-600 text-slate-200 text-2xl font-bold">
            {member.name.slice(0, 2).toUpperCase()}
          </AvatarFallback>
        </Avatar>

        <div className="flex-1 space-y-3">
          <div className="flex flex-wrap items-center gap-2">
            <RoleBadge role={member.role} />
            <Badge variant="outline" className={member.isActive ? 'border-emerald-500/40 text-emerald-400' : 'border-red-500/40 text-red-400'}>
              {member.isActive ? 'Active' : 'Inactive'}
            </Badge>
            {member.emailVerified && <Badge variant="outline" className="border-sky-500/40 text-sky-400">Email Verified</Badge>}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-slate-300">
            {member.phone && <span className="flex items-center gap-2"><Phone className="w-4 h-4 text-slate-500" />{member.phone}</span>}
            <span className="flex items-center gap-2"><Mail className="w-4 h-4 text-slate-500" />{member.email}</span>
            {member.department && <span className="flex items-center gap-2"><Building2 className="w-4 h-4 text-slate-500" />{member.department}</span>}
          </div>

          {member.bio && <p className="text-sm text-slate-400 leading-relaxed">{member.bio}</p>}

          <p className="text-xs text-slate-500">Joined {formatDate(member.createdAt)}</p>
        </div>

        {/* Quick actions */}
        <div className="flex flex-col gap-3 shrink-0 min-w-40">
          {isSuperAdmin && (
            <div className="space-y-1">
              <p className="text-xs text-slate-500 font-medium">Change Role</p>
              <Select
                value={member.role}
                onValueChange={(role) => role && changeRole.mutate({ id, role })}
                disabled={changeRole.isPending}
              >
                <SelectTrigger className="bg-slate-700 border-slate-600 text-slate-200 text-sm">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-slate-800 border-slate-700">
                  {ROLES.map((r) => <SelectItem key={r} value={r} className="text-slate-300">{r.replace('_', ' ')}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
          )}
          <Button
            variant="outline"
            size="sm"
            className={`text-xs ${member.isActive ? 'border-amber-500/40 text-amber-400 hover:bg-amber-400/10' : 'border-emerald-500/40 text-emerald-400 hover:bg-emerald-400/10'}`}
            onClick={() => setStatus.mutate({ id, isActive: !member.isActive })}
            disabled={setStatus.isPending}
          >
            {member.isActive ? 'Deactivate' : 'Activate'} Account
          </Button>
        </div>
      </div>

      {/* Stats strip */}
      {member._count && (
        <div className="grid grid-cols-3 gap-4">
          {[
            { label: 'Donations', value: member._count.donations },
            { label: 'Event Registrations', value: member._count.eventRegistrations },
            { label: 'Group Memberships', value: member._count.groupMemberships },
          ].map(({ label, value }) => (
            <div key={label} className="bg-slate-800 border border-slate-700 rounded-xl p-4 text-center">
              <p className="text-2xl font-bold text-slate-100">{value}</p>
              <p className="text-xs text-slate-400 mt-1">{label}</p>
            </div>
          ))}
        </div>
      )}

      {/* Tabs */}
      <Tabs defaultValue="giving">
        <TabsList className="bg-slate-800 border border-slate-700">
          <TabsTrigger value="giving" className="data-[state=active]:bg-slate-700 text-slate-400 data-[state=active]:text-slate-100">Giving History</TabsTrigger>
        </TabsList>

        <TabsContent value="giving" className="mt-4">
          {giving ? (
            <div className="bg-slate-800 border border-slate-700 rounded-xl overflow-hidden">
              <div className="px-4 py-3 border-b border-slate-700 flex justify-between items-center">
                <p className="text-sm font-medium text-slate-200">Total Given</p>
                <p className="text-lg font-bold text-emerald-400">{formatCurrency(giving.totalGiven)}</p>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-slate-700 text-left">
                      <th className="px-4 py-2 text-xs text-slate-400 font-medium">Date</th>
                      <th className="px-4 py-2 text-xs text-slate-400 font-medium">Category</th>
                      <th className="px-4 py-2 text-xs text-slate-400 font-medium">Method</th>
                      <th className="px-4 py-2 text-xs text-slate-400 font-medium text-right">Amount</th>
                      <th className="px-4 py-2 text-xs text-slate-400 font-medium">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {giving.donations.length === 0 ? (
                      <tr><td colSpan={5} className="px-4 py-8 text-center text-slate-400">No donations yet</td></tr>
                    ) : giving.donations.map((d: any) => (
                      <tr key={d.id} className="border-b border-slate-700/50">
                        <td className="px-4 py-3 text-slate-400">{formatRelativeTime(d.createdAt)}</td>
                        <td className="px-4 py-3 text-slate-300">{d.category?.name ?? '—'}</td>
                        <td className="px-4 py-3 text-slate-400">{d.paymentMethod}</td>
                        <td className="px-4 py-3 text-right font-medium text-slate-100">{formatCurrency(d.amount, d.currency)}</td>
                        <td className="px-4 py-3">
                          <Badge variant="outline" className={d.status === 'SUCCESS' ? 'border-emerald-500/40 text-emerald-400' : 'border-slate-600 text-slate-400'}>
                            {d.status}
                          </Badge>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          ) : <div className="h-32 bg-slate-800 rounded-xl animate-pulse" />}
        </TabsContent>
      </Tabs>

      <ConfirmDialog
        open={showDelete}
        onClose={() => setShowDelete(false)}
        onConfirm={() => deleteMember.mutate(id, { onSuccess: () => router.push('/members') })}
        title={`Delete ${member.name}`}
        description="This permanently deletes the member account. This cannot be undone."
        confirmLabel="Delete"
        loading={deleteMember.isPending}
      />
    </div>
  );
}
