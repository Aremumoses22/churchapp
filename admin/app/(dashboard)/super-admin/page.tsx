'use client';

import { useState } from 'react';
import {
  usePlatformStats, useChurches, useCreateChurch, useUpdateChurch,
  useSuspendChurch, useUnsuspendChurch, useRegenerateChurchCode, useDeleteChurch,
  useChurchDetail, useChurchMembers, useRemoveChurchMember,
  type ChurchSummary, type CreateChurchInput, type UpdateChurchInput,
} from '@/hooks/useSuperAdmin';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import {
  Search, Plus, Building2, Users, RefreshCw, Trash2, PowerOff, Power,
  ChevronLeft, ChevronRight, Eye, Pencil, Copy, Check, BookOpen, Calendar,
  Globe, Mail, Phone, MapPin, Shield,
} from 'lucide-react';
import { formatDate } from '@/lib/format';

// ─────────────────────────────────────────────────────────────────────────────
// Stat card
// ─────────────────────────────────────────────────────────────────────────────

function StatCard({ label, value, sub, icon: Icon, color }: {
  label: string; value: number | string; sub?: string;
  icon: React.ElementType; color: string;
}) {
  return (
    <div className="bg-slate-800 border border-slate-700 rounded-xl p-5 flex items-start gap-4">
      <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${color}`}>
        <Icon className="w-5 h-5 text-white" />
      </div>
      <div>
        <p className="text-2xl font-bold text-white">{value}</p>
        <p className="text-slate-400 text-sm">{label}</p>
        {sub && <p className="text-slate-500 text-xs mt-0.5">{sub}</p>}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Copy button
// ─────────────────────────────────────────────────────────────────────────────

function CopyButton({ text }: { text: string }) {
  const [copied, setCopied] = useState(false);
  function copy() {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }
  return (
    <button onClick={copy} className="ml-2 text-slate-400 hover:text-slate-200 transition-colors">
      {copied ? <Check className="w-3.5 h-3.5 text-green-400" /> : <Copy className="w-3.5 h-3.5" />}
    </button>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Create Church Modal
// ─────────────────────────────────────────────────────────────────────────────

function CreateChurchModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const create = useCreateChurch();
  const [form, setForm] = useState<CreateChurchInput>({
    name: '', tagline: '', email: '', phone: '', address: '', website: '',
    adminName: '', adminEmail: '', adminPassword: '',
  });
  const [error, setError] = useState('');

  function set(k: keyof CreateChurchInput, v: string) {
    setForm((f) => ({ ...f, [k]: v }));
  }

  async function submit() {
    setError('');
    try {
      await create.mutateAsync(form);
      onClose();
      setForm({ name: '', tagline: '', email: '', phone: '', address: '', website: '', adminName: '', adminEmail: '', adminPassword: '' });
    } catch (e: unknown) {
      const err = e as { response?: { data?: { message?: string } } };
      setError(err?.response?.data?.message ?? 'Failed to create church');
    }
  }

  return (
    <Dialog open={open} onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="bg-slate-900 border-slate-700 text-white max-w-xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Register New Church</DialogTitle>
        </DialogHeader>

        <div className="space-y-5 py-2">
          {/* Church Info */}
          <div>
            <p className="text-xs font-semibold uppercase text-slate-400 mb-3 tracking-wider">Church Details</p>
            <div className="space-y-3">
              <div>
                <Label className="text-slate-300 text-sm">Church Name *</Label>
                <Input value={form.name} onChange={(e) => set('name', e.target.value)}
                  className="mt-1 bg-slate-800 border-slate-600 text-white" placeholder="Grace Community Church" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <Label className="text-slate-300 text-sm">Email</Label>
                  <Input value={form.email} onChange={(e) => set('email', e.target.value)}
                    className="mt-1 bg-slate-800 border-slate-600 text-white" placeholder="info@church.com" />
                </div>
                <div>
                  <Label className="text-slate-300 text-sm">Phone</Label>
                  <Input value={form.phone} onChange={(e) => set('phone', e.target.value)}
                    className="mt-1 bg-slate-800 border-slate-600 text-white" placeholder="+1 234 567 8900" />
                </div>
              </div>
              <div>
                <Label className="text-slate-300 text-sm">Address</Label>
                <Input value={form.address} onChange={(e) => set('address', e.target.value)}
                  className="mt-1 bg-slate-800 border-slate-600 text-white" placeholder="123 Main St, City, State" />
              </div>
              <div>
                <Label className="text-slate-300 text-sm">Website</Label>
                <Input value={form.website} onChange={(e) => set('website', e.target.value)}
                  className="mt-1 bg-slate-800 border-slate-600 text-white" placeholder="https://church.com" />
              </div>
            </div>
          </div>

          {/* Admin Account */}
          <div>
            <p className="text-xs font-semibold uppercase text-slate-400 mb-3 tracking-wider">Admin Account</p>
            <div className="space-y-3">
              <div>
                <Label className="text-slate-300 text-sm">Admin Full Name *</Label>
                <Input value={form.adminName} onChange={(e) => set('adminName', e.target.value)}
                  className="mt-1 bg-slate-800 border-slate-600 text-white" placeholder="Pastor John Doe" />
              </div>
              <div>
                <Label className="text-slate-300 text-sm">Admin Email *</Label>
                <Input value={form.adminEmail} onChange={(e) => set('adminEmail', e.target.value)}
                  className="mt-1 bg-slate-800 border-slate-600 text-white" placeholder="admin@church.com" />
              </div>
              <div>
                <Label className="text-slate-300 text-sm">Temporary Password *</Label>
                <Input type="password" value={form.adminPassword} onChange={(e) => set('adminPassword', e.target.value)}
                  className="mt-1 bg-slate-800 border-slate-600 text-white" placeholder="Min 8 characters" />
              </div>
            </div>
          </div>

          {error && <p className="text-red-400 text-sm">{error}</p>}
        </div>

        <DialogFooter>
          <Button variant="ghost" onClick={onClose} className="text-slate-400">Cancel</Button>
          <Button onClick={submit} disabled={create.isPending || !form.name || !form.adminName || !form.adminEmail || !form.adminPassword}>
            {create.isPending ? 'Creating…' : 'Create Church & Send Credentials'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Church Modal
// ─────────────────────────────────────────────────────────────────────────────

function EditChurchModal({ church, onClose }: { church: ChurchSummary; onClose: () => void }) {
  const update = useUpdateChurch();
  const [form, setForm] = useState<UpdateChurchInput>({
    name: church.name,
    email: church.email ?? '',
    phone: church.phone ?? '',
    address: church.address ?? '',
    website: church.website ?? '',
    tagline: church.tagline ?? '',
  });
  const [error, setError] = useState('');

  function set(k: keyof UpdateChurchInput, v: string) {
    setForm((f) => ({ ...f, [k]: v }));
  }

  async function submit() {
    setError('');
    try {
      await update.mutateAsync({ id: church.id, ...form });
      onClose();
    } catch (e: unknown) {
      const err = e as { response?: { data?: { message?: string } } };
      setError(err?.response?.data?.message ?? 'Failed to update church');
    }
  }

  return (
    <Dialog open onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="bg-slate-900 border-slate-700 text-white max-w-xl">
        <DialogHeader><DialogTitle>Edit Church — {church.name}</DialogTitle></DialogHeader>
        <div className="space-y-3 py-2">
          <div>
            <Label className="text-slate-300 text-sm">Church Name</Label>
            <Input value={form.name} onChange={(e) => set('name', e.target.value)}
              className="mt-1 bg-slate-800 border-slate-600 text-white" />
          </div>
          <div>
            <Label className="text-slate-300 text-sm">Tagline</Label>
            <Input value={form.tagline} onChange={(e) => set('tagline', e.target.value)}
              className="mt-1 bg-slate-800 border-slate-600 text-white" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label className="text-slate-300 text-sm">Email</Label>
              <Input value={form.email} onChange={(e) => set('email', e.target.value)}
                className="mt-1 bg-slate-800 border-slate-600 text-white" />
            </div>
            <div>
              <Label className="text-slate-300 text-sm">Phone</Label>
              <Input value={form.phone} onChange={(e) => set('phone', e.target.value)}
                className="mt-1 bg-slate-800 border-slate-600 text-white" />
            </div>
          </div>
          <div>
            <Label className="text-slate-300 text-sm">Address</Label>
            <Input value={form.address} onChange={(e) => set('address', e.target.value)}
              className="mt-1 bg-slate-800 border-slate-600 text-white" />
          </div>
          <div>
            <Label className="text-slate-300 text-sm">Website</Label>
            <Input value={form.website} onChange={(e) => set('website', e.target.value)}
              className="mt-1 bg-slate-800 border-slate-600 text-white" />
          </div>
          {error && <p className="text-red-400 text-sm">{error}</p>}
        </div>
        <DialogFooter>
          <Button variant="ghost" onClick={onClose} className="text-slate-400">Cancel</Button>
          <Button onClick={submit} disabled={update.isPending}>{update.isPending ? 'Saving…' : 'Save Changes'}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Suspend Modal
// ─────────────────────────────────────────────────────────────────────────────

function SuspendModal({ church, onClose }: { church: ChurchSummary; onClose: () => void }) {
  const suspend = useSuspendChurch();
  const [reason, setReason] = useState('');

  async function submit() {
    await suspend.mutateAsync({ id: church.id, reason });
    onClose();
  }

  return (
    <Dialog open onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="bg-slate-900 border-slate-700 text-white max-w-md">
        <DialogHeader><DialogTitle>Suspend {church.name}</DialogTitle></DialogHeader>
        <div className="py-2 space-y-3">
          <p className="text-slate-400 text-sm">
            Suspending this church will block all its members from accessing the mobile app. Admin access is also blocked.
          </p>
          <div>
            <Label className="text-slate-300 text-sm">Reason for suspension *</Label>
            <Textarea value={reason} onChange={(e) => setReason(e.target.value)}
              className="mt-1 bg-slate-800 border-slate-600 text-white resize-none"
              placeholder="e.g. Payment overdue, Terms of service violation…" rows={3} />
          </div>
        </div>
        <DialogFooter>
          <Button variant="ghost" onClick={onClose} className="text-slate-400">Cancel</Button>
          <Button variant="destructive" onClick={submit} disabled={suspend.isPending || reason.trim().length < 5}>
            {suspend.isPending ? 'Suspending…' : 'Suspend Church'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Church Detail Drawer
// ─────────────────────────────────────────────────────────────────────────────

function ChurchDetailDrawer({ churchId, onClose }: { churchId: string; onClose: () => void }) {
  const { data: church, isLoading } = useChurchDetail(churchId);
  const [memberSearch, setMemberSearch] = useState('');
  const [memberPage, setMemberPage] = useState(1);
  const { data: members } = useChurchMembers(churchId, { page: memberPage, limit: 15, search: memberSearch || undefined });
  const removeM = useRemoveChurchMember();
  const regen = useRegenerateChurchCode();
  const [regenConfirm, setRegenConfirm] = useState(false);
  const [removeMid, setRemoveMid] = useState<string | null>(null);

  return (
    <div className="fixed inset-0 z-50 flex">
      <div className="flex-1 bg-black/50" onClick={onClose} />
      <div className="w-full max-w-2xl bg-slate-900 border-l border-slate-700 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-700">
          <h2 className="text-white font-semibold text-lg">{isLoading ? 'Loading…' : church?.name}</h2>
          <Button variant="ghost" size="sm" onClick={onClose} className="text-slate-400">✕</Button>
        </div>

        {isLoading && <div className="flex-1 flex items-center justify-center text-slate-400">Loading…</div>}

        {church && (
          <div className="flex-1 overflow-y-auto">
            <Tabs defaultValue="info">
              <TabsList className="w-full bg-slate-800 rounded-none border-b border-slate-700">
                <TabsTrigger value="info" className="flex-1 data-[state=active]:bg-slate-700">Info</TabsTrigger>
                <TabsTrigger value="admins" className="flex-1 data-[state=active]:bg-slate-700">Admins</TabsTrigger>
                <TabsTrigger value="members" className="flex-1 data-[state=active]:bg-slate-700">Members</TabsTrigger>
              </TabsList>

              {/* Info tab */}
              <TabsContent value="info" className="p-6 space-y-5">
                {/* Church code */}
                <div className="bg-slate-800 rounded-xl p-4">
                  <p className="text-xs text-slate-400 mb-1">Church Code</p>
                  <div className="flex items-center justify-between">
                    <span className="text-2xl font-mono font-bold text-emerald-400 tracking-widest">{church.code}</span>
                    <div className="flex items-center gap-2">
                      <CopyButton text={church.code} />
                      <Button size="sm" variant="outline" className="border-slate-600 text-slate-300"
                        onClick={() => setRegenConfirm(true)}>
                        <RefreshCw className="w-3.5 h-3.5 mr-1" /> Regenerate
                      </Button>
                    </div>
                  </div>
                  <p className="text-slate-500 text-xs mt-2">Members enter this code in the mobile app to join the church.</p>
                </div>

                {/* Status */}
                <div className="flex items-center gap-3">
                  <Badge className={church.isActive ? 'bg-emerald-500/20 text-emerald-400' : 'bg-red-500/20 text-red-400'}>
                    {church.isActive ? 'Active' : 'Suspended'}
                  </Badge>
                  {church.suspendedAt && (
                    <span className="text-slate-500 text-xs">Suspended {formatDate(church.suspendedAt)}</span>
                  )}
                </div>

                {church.suspendReason && (
                  <div className="bg-red-500/10 border border-red-500/20 rounded-lg p-3">
                    <p className="text-red-400 text-xs font-semibold mb-1">Suspension Reason</p>
                    <p className="text-red-300 text-sm">{church.suspendReason}</p>
                  </div>
                )}

                {/* Details grid */}
                <div className="space-y-3">
                  {church.email && (
                    <div className="flex items-center gap-3 text-sm">
                      <Mail className="w-4 h-4 text-slate-400 shrink-0" />
                      <span className="text-slate-300">{church.email}</span>
                    </div>
                  )}
                  {church.phone && (
                    <div className="flex items-center gap-3 text-sm">
                      <Phone className="w-4 h-4 text-slate-400 shrink-0" />
                      <span className="text-slate-300">{church.phone}</span>
                    </div>
                  )}
                  {church.address && (
                    <div className="flex items-center gap-3 text-sm">
                      <MapPin className="w-4 h-4 text-slate-400 shrink-0" />
                      <span className="text-slate-300">{church.address}</span>
                    </div>
                  )}
                  {church.website && (
                    <div className="flex items-center gap-3 text-sm">
                      <Globe className="w-4 h-4 text-slate-400 shrink-0" />
                      <a href={church.website} target="_blank" rel="noreferrer" className="text-primary hover:underline">{church.website}</a>
                    </div>
                  )}
                </div>

                {/* Stats */}
                <div className="grid grid-cols-3 gap-3">
                  <div className="bg-slate-800 rounded-lg p-3 text-center">
                    <p className="text-xl font-bold text-white">{church._count.users}</p>
                    <p className="text-slate-400 text-xs">Members</p>
                  </div>
                  <div className="bg-slate-800 rounded-lg p-3 text-center">
                    <p className="text-xl font-bold text-white">{church._count.sermons}</p>
                    <p className="text-slate-400 text-xs">Sermons</p>
                  </div>
                  <div className="bg-slate-800 rounded-lg p-3 text-center">
                    <p className="text-xl font-bold text-white">{church._count.events}</p>
                    <p className="text-slate-400 text-xs">Events</p>
                  </div>
                </div>

                <div className="text-slate-500 text-xs">
                  Registered {formatDate(church.createdAt)}
                </div>
              </TabsContent>

              {/* Admins tab */}
              <TabsContent value="admins" className="p-6">
                <div className="space-y-3">
                  {church.users.map((u) => (
                    <div key={u.id} className="flex items-center gap-3 bg-slate-800 rounded-lg p-3">
                      <Avatar className="w-8 h-8">
                        <AvatarFallback className="bg-primary/20 text-primary text-xs">
                          {u.name.slice(0, 2).toUpperCase()}
                        </AvatarFallback>
                      </Avatar>
                      <div className="flex-1 min-w-0">
                        <p className="text-white text-sm font-medium truncate">{u.name}</p>
                        <p className="text-slate-400 text-xs truncate">{u.email}</p>
                      </div>
                      <Badge className="text-xs bg-slate-700 text-slate-300 shrink-0">{u.role}</Badge>
                    </div>
                  ))}
                  {church.users.length === 0 && (
                    <p className="text-slate-500 text-sm text-center py-4">No admins found</p>
                  )}
                </div>
              </TabsContent>

              {/* Members tab */}
              <TabsContent value="members" className="p-6 space-y-4">
                <div className="relative">
                  <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                  <Input
                    placeholder="Search members…"
                    value={memberSearch}
                    onChange={(e) => { setMemberSearch(e.target.value); setMemberPage(1); }}
                    className="pl-9 bg-slate-800 border-slate-600 text-white"
                  />
                </div>

                <div className="space-y-2">
                  {members?.data.map((m) => (
                    <div key={m.id} className="flex items-center gap-3 bg-slate-800 rounded-lg p-2.5">
                      <Avatar className="w-7 h-7 shrink-0">
                        <AvatarFallback className="bg-slate-700 text-slate-300 text-xs">
                          {m.name.slice(0, 2).toUpperCase()}
                        </AvatarFallback>
                      </Avatar>
                      <div className="flex-1 min-w-0">
                        <p className="text-white text-sm truncate">{m.name}</p>
                        <p className="text-slate-500 text-xs truncate">{m.email}</p>
                      </div>
                      <Badge className="text-xs bg-slate-700 text-slate-400 shrink-0">{m.role}</Badge>
                      <Button size="sm" variant="ghost" className="text-red-400 hover:text-red-300 h-7 w-7 p-0"
                        onClick={() => setRemoveMid(m.id)}>
                        <Trash2 className="w-3.5 h-3.5" />
                      </Button>
                    </div>
                  ))}
                  {members?.data.length === 0 && (
                    <p className="text-slate-500 text-sm text-center py-4">No members found</p>
                  )}
                </div>

                {/* Pagination */}
                {members && members.meta.totalPages > 1 && (
                  <div className="flex items-center justify-between text-sm text-slate-400">
                    <span>Page {members.meta.page} of {members.meta.totalPages}</span>
                    <div className="flex gap-2">
                      <Button size="sm" variant="outline" className="border-slate-600 h-7"
                        onClick={() => setMemberPage((p) => Math.max(1, p - 1))} disabled={members.meta.page === 1}>
                        <ChevronLeft className="w-3.5 h-3.5" />
                      </Button>
                      <Button size="sm" variant="outline" className="border-slate-600 h-7"
                        onClick={() => setMemberPage((p) => p + 1)} disabled={members.meta.page >= members.meta.totalPages}>
                        <ChevronRight className="w-3.5 h-3.5" />
                      </Button>
                    </div>
                  </div>
                )}
              </TabsContent>
            </Tabs>
          </div>
        )}

        {/* Confirm regenerate code */}
        <ConfirmDialog
          open={regenConfirm}
          onClose={() => setRegenConfirm(false)}
          title="Regenerate Church Code?"
          description="The old code will immediately stop working. All existing members are already linked, but new members will need the new code."
          confirmLabel="Regenerate"
          onConfirm={async () => { await regen.mutateAsync(churchId); setRegenConfirm(false); }}
        />

        {/* Confirm remove member */}
        <ConfirmDialog
          open={!!removeMid}
          onClose={() => setRemoveMid(null)}
          title="Remove Member?"
          description="This will unlink the member from the church. They can rejoin using the church code."
          confirmLabel="Remove"
          variant="destructive"
          onConfirm={async () => {
            if (removeMid) {
              await removeM.mutateAsync({ churchId, userId: removeMid });
              setRemoveMid(null);
            }
          }}
        />
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Church row
// ─────────────────────────────────────────────────────────────────────────────

function ChurchRow({ church, onView, onEdit, onSuspend, onUnsuspend, onDelete }: {
  church: ChurchSummary;
  onView: () => void;
  onEdit: () => void;
  onSuspend: () => void;
  onUnsuspend: () => void;
  onDelete: () => void;
}) {
  return (
    <tr className="border-b border-slate-700/50 hover:bg-slate-800/40 transition-colors">
      <td className="px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 bg-primary/10 rounded-lg flex items-center justify-center shrink-0">
            <Building2 className="w-4 h-4 text-primary" />
          </div>
          <div className="min-w-0">
            <p className="text-white text-sm font-medium truncate">{church.name}</p>
            {church.email && <p className="text-slate-500 text-xs truncate">{church.email}</p>}
          </div>
        </div>
      </td>
      <td className="px-4 py-3">
        <span className="font-mono text-emerald-400 font-semibold text-sm tracking-widest">
          {church.code}
        </span>
        <CopyButton text={church.code} />
      </td>
      <td className="px-4 py-3">
        <div className="flex items-center gap-1.5 text-slate-300 text-sm">
          <Users className="w-3.5 h-3.5 text-slate-400" />
          <span>{church._count.users}</span>
          <BookOpen className="w-3.5 h-3.5 text-slate-400 ml-2" />
          <span>{church._count.sermons}</span>
          <Calendar className="w-3.5 h-3.5 text-slate-400 ml-2" />
          <span>{church._count.events}</span>
        </div>
      </td>
      <td className="px-4 py-3">
        <Badge className={church.isActive
          ? 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30'
          : 'bg-red-500/20 text-red-400 border-red-500/30'}>
          {church.isActive ? 'Active' : 'Suspended'}
        </Badge>
      </td>
      <td className="px-4 py-3 text-slate-500 text-xs">{formatDate(church.createdAt)}</td>
      <td className="px-4 py-3">
        <div className="flex items-center gap-1">
          <Button size="sm" variant="ghost" className="h-7 w-7 p-0 text-slate-400 hover:text-white" onClick={onView}>
            <Eye className="w-3.5 h-3.5" />
          </Button>
          <Button size="sm" variant="ghost" className="h-7 w-7 p-0 text-slate-400 hover:text-white" onClick={onEdit}>
            <Pencil className="w-3.5 h-3.5" />
          </Button>
          {church.isActive ? (
            <Button size="sm" variant="ghost" className="h-7 w-7 p-0 text-amber-400 hover:text-amber-300" onClick={onSuspend}>
              <PowerOff className="w-3.5 h-3.5" />
            </Button>
          ) : (
            <Button size="sm" variant="ghost" className="h-7 w-7 p-0 text-emerald-400 hover:text-emerald-300" onClick={onUnsuspend}>
              <Power className="w-3.5 h-3.5" />
            </Button>
          )}
          <Button size="sm" variant="ghost" className="h-7 w-7 p-0 text-red-400 hover:text-red-300" onClick={onDelete}>
            <Trash2 className="w-3.5 h-3.5" />
          </Button>
        </div>
      </td>
    </tr>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Page
// ─────────────────────────────────────────────────────────────────────────────

export default function SuperAdminPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [showCreate, setShowCreate] = useState(false);
  const [editChurch, setEditChurch] = useState<ChurchSummary | null>(null);
  const [suspendChurch, setSuspendChurch] = useState<ChurchSummary | null>(null);
  const [detailId, setDetailId] = useState<string | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const { data: stats } = usePlatformStats();
  const { data: churches, isLoading } = useChurches({
    page, limit: 15, search: search || undefined, status: statusFilter || undefined,
  });
  const unsuspend = useUnsuspendChurch();
  const deleteChurch = useDeleteChurch();

  const rows = churches?.data ?? [];
  const meta = churches?.meta;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Super Admin — Church Management"
        description="Platform-wide control: register, manage, and monitor all churches"
        actions={
          <Button onClick={() => setShowCreate(true)}>
            <Plus className="w-4 h-4 mr-2" /> Register Church
          </Button>
        }
      />

      {/* Platform Stats */}
      {stats && (
        <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
          <StatCard label="Total Churches" value={stats.totalChurches} icon={Building2} color="bg-primary" />
          <StatCard label="Active" value={stats.activeChurches} icon={Power} color="bg-emerald-600" />
          <StatCard label="Suspended" value={stats.suspendedChurches} icon={PowerOff} color="bg-red-600" />
          <StatCard label="Total Users" value={stats.totalUsers.toLocaleString()} icon={Users} color="bg-blue-600" />
          <StatCard label="New This Month" value={stats.newChurchesThisMonth} icon={Shield} color="bg-violet-600"
            sub="churches onboarded" />
        </div>
      )}

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        <div className="relative flex-1 min-w-48">
          <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <Input
            placeholder="Search name, email, or code…"
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            className="pl-9 bg-slate-800 border-slate-600 text-slate-100 placeholder:text-slate-500"
          />
        </div>
        <Select value={statusFilter} onValueChange={(v) => { setStatusFilter(v === 'all' ? '' : (v ?? '')); setPage(1); }}>
          <SelectTrigger className="w-40 bg-slate-800 border-slate-600 text-slate-300">
            <SelectValue placeholder="All statuses" />
          </SelectTrigger>
          <SelectContent className="bg-slate-800 border-slate-700 text-white">
            <SelectItem value="all">All statuses</SelectItem>
            <SelectItem value="active">Active</SelectItem>
            <SelectItem value="suspended">Suspended</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Table */}
      <div className="bg-slate-800 border border-slate-700 rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead>
              <tr className="border-b border-slate-700 bg-slate-800/80">
                <th className="px-4 py-3 text-slate-400 font-medium">Church</th>
                <th className="px-4 py-3 text-slate-400 font-medium">Code</th>
                <th className="px-4 py-3 text-slate-400 font-medium">Stats</th>
                <th className="px-4 py-3 text-slate-400 font-medium">Status</th>
                <th className="px-4 py-3 text-slate-400 font-medium">Created</th>
                <th className="px-4 py-3 text-slate-400 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody>
              {isLoading && (
                <tr><td colSpan={6} className="px-4 py-10 text-center text-slate-500">Loading churches…</td></tr>
              )}
              {!isLoading && rows.length === 0 && (
                <tr><td colSpan={6} className="px-4 py-10 text-center text-slate-500">No churches found</td></tr>
              )}
              {rows.map((church) => (
                <ChurchRow
                  key={church.id}
                  church={church}
                  onView={() => setDetailId(church.id)}
                  onEdit={() => setEditChurch(church)}
                  onSuspend={() => setSuspendChurch(church)}
                  onUnsuspend={() => unsuspend.mutate(church.id)}
                  onDelete={() => setDeleteId(church.id)}
                />
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {meta && meta.totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-slate-700 text-sm text-slate-400">
            <span>{meta.total} total churches</span>
            <div className="flex items-center gap-3">
              <Button size="sm" variant="outline" className="border-slate-600 h-8"
                onClick={() => setPage((p) => Math.max(1, p - 1))} disabled={page === 1}>
                <ChevronLeft className="w-4 h-4" />
              </Button>
              <span>Page {meta.page} of {meta.totalPages}</span>
              <Button size="sm" variant="outline" className="border-slate-600 h-8"
                onClick={() => setPage((p) => p + 1)} disabled={page >= meta.totalPages}>
                <ChevronRight className="w-4 h-4" />
              </Button>
            </div>
          </div>
        )}
      </div>

      {/* Modals */}
      <CreateChurchModal open={showCreate} onClose={() => setShowCreate(false)} />
      {editChurch && <EditChurchModal church={editChurch} onClose={() => setEditChurch(null)} />}
      {suspendChurch && <SuspendModal church={suspendChurch} onClose={() => setSuspendChurch(null)} />}
      {detailId && <ChurchDetailDrawer churchId={detailId} onClose={() => setDetailId(null)} />}

      <ConfirmDialog
        open={!!deleteId}
        onClose={() => setDeleteId(null)}
        title="Delete Church?"
        description="This will permanently delete the church and all its data. This cannot be undone."
        confirmLabel="Delete Church"
        variant="destructive"
        onConfirm={async () => {
          if (deleteId) {
            await deleteChurch.mutateAsync(deleteId);
            setDeleteId(null);
          }
        }}
      />
    </div>
  );
}
