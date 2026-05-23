'use client';

import { useParams, useRouter } from 'next/navigation';
import { useMember, useUpdateMember } from '@/hooks/useMembers';
import { PageHeader } from '@/components/shared/PageHeader';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { ArrowLeft, Loader2, Save } from 'lucide-react';
import { useState, useEffect } from 'react';

export default function MemberEditPage() {
  const { id = '' } = useParams() as { id: string };
  const router = useRouter();
  const { data: member, isLoading } = useMember(id);
  const updateMember = useUpdateMember();
  const [error, setError] = useState('');

  const [form, setForm] = useState({ name: '', phone: '', bio: '', department: '' });

  useEffect(() => {
    if (member) {
      setForm({
        name: member.name,
        phone: member.phone ?? '',
        bio: member.bio ?? '',
        department: member.department ?? '',
      });
    }
  }, [member]);

  function field(key: keyof typeof form) {
    return (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
      setForm((f) => ({ ...f, [key]: e.target.value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    try {
      await updateMember.mutateAsync({ id, ...form });
      router.push(`/members/${id}`);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Update failed');
    }
  }

  if (isLoading) return <div className="h-48 bg-slate-800 rounded-xl animate-pulse" />;
  if (!member) return <p className="text-slate-400">Member not found.</p>;

  return (
    <div className="max-w-xl space-y-6">
      <div className="flex items-center gap-3">
        <Button variant="ghost" size="icon" onClick={() => router.back()} className="text-slate-400 hover:text-slate-100">
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <PageHeader title={`Edit ${member.name}`} />
      </div>

      <form onSubmit={handleSubmit} className="bg-slate-800 border border-slate-700 rounded-xl p-6 space-y-5">
        <div className="space-y-2">
          <Label htmlFor="name" className="text-slate-200">Full Name</Label>
          <Input id="name" value={form.name} onChange={field('name')} required className="bg-slate-700 border-slate-600 text-white" />
        </div>

        <div className="space-y-2">
          <Label htmlFor="phone" className="text-slate-200">Phone</Label>
          <Input id="phone" value={form.phone} onChange={field('phone')} placeholder="+234…" className="bg-slate-700 border-slate-600 text-white" />
        </div>

        <div className="space-y-2">
          <Label htmlFor="department" className="text-slate-200">Department</Label>
          <Input id="department" value={form.department} onChange={field('department')} placeholder="e.g. Worship Team" className="bg-slate-700 border-slate-600 text-white" />
        </div>

        <div className="space-y-2">
          <Label htmlFor="bio" className="text-slate-200">Bio</Label>
          <Textarea id="bio" value={form.bio} onChange={field('bio')} rows={4} placeholder="Short bio…" className="bg-slate-700 border-slate-600 text-white resize-none" />
        </div>

        {error && <p className="text-sm text-red-400 bg-red-400/10 border border-red-400/20 rounded-md px-3 py-2">{error}</p>}

        <div className="flex justify-end gap-3 pt-2">
          <Button type="button" variant="outline" onClick={() => router.back()} className="border-slate-600 text-slate-300 hover:bg-slate-700">
            Cancel
          </Button>
          <Button type="submit" disabled={updateMember.isPending}>
            {updateMember.isPending ? <><Loader2 className="w-4 h-4 mr-2 animate-spin" /> Saving…</> : <><Save className="w-4 h-4 mr-2" /> Save Changes</>}
          </Button>
        </div>
      </form>
    </div>
  );
}
