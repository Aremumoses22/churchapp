'use client';

import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Loader2 } from 'lucide-react';

interface Props { open: boolean; onClose: () => void }

export function InviteMemberDialog({ open, onClose }: Props) {
  const qc = useQueryClient();
  const [form, setForm] = useState({ name: '', email: '', role: 'MEMBER' });
  const [error, setError] = useState('');

  const invite = useMutation({
    mutationFn: () => api.post('/members/invite', form),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['members'] }); onClose(); setForm({ name: '', email: '', role: 'MEMBER' }); },
    onError: (e: any) => setError(e.response?.data?.message || 'Invitation failed'),
  });

  function field(k: keyof typeof form) {
    return (e: React.ChangeEvent<HTMLInputElement>) => setForm((f) => ({ ...f, [k]: e.target.value }));
  }

  return (
    <Dialog open={open} onOpenChange={(v) => !v && onClose()}>
      <DialogContent className="bg-slate-800 border-slate-700 text-slate-100 max-w-sm">
        <DialogHeader><DialogTitle>Invite Member</DialogTitle></DialogHeader>
        <form onSubmit={(e) => { e.preventDefault(); setError(''); invite.mutate(); }} className="space-y-4 mt-2">
          <div className="space-y-2">
            <Label className="text-slate-200">Full Name</Label>
            <Input value={form.name} onChange={field('name')} required placeholder="Jane Doe" className="bg-slate-700 border-slate-600 text-white" />
          </div>
          <div className="space-y-2">
            <Label className="text-slate-200">Email</Label>
            <Input type="email" value={form.email} onChange={field('email')} required placeholder="jane@example.com" className="bg-slate-700 border-slate-600 text-white" />
          </div>
          <div className="space-y-2">
            <Label className="text-slate-200">Role</Label>
            <Select value={form.role} onValueChange={(v) => v && setForm((f) => ({ ...f, role: v }))}>
              <SelectTrigger className="bg-slate-700 border-slate-600 text-slate-200"><SelectValue /></SelectTrigger>
              <SelectContent className="bg-slate-800 border-slate-700">
                {['MEMBER', 'LEADER', 'PASTOR'].map((r) => (
                  <SelectItem key={r} value={r} className="text-slate-300">{r}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          {error && <p className="text-sm text-red-400 bg-red-400/10 border border-red-400/20 rounded-md px-3 py-2">{error}</p>}
          <DialogFooter className="gap-2">
            <Button type="button" variant="outline" onClick={onClose} className="border-slate-600 text-slate-300 hover:bg-slate-700">Cancel</Button>
            <Button type="submit" disabled={invite.isPending}>
              {invite.isPending ? <><Loader2 className="w-4 h-4 mr-2 animate-spin" />Sending…</> : 'Send Invite'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
