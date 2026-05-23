import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/utils';

const ROLE_CONFIG: Record<string, { label: string; class: string }> = {
  MEMBER: { label: 'Member', class: 'border-slate-600 text-slate-300' },
  LEADER: { label: 'Leader', class: 'border-blue-500/50 text-blue-400' },
  PASTOR: { label: 'Pastor', class: 'border-violet-500/50 text-violet-400' },
  ADMIN: { label: 'Admin', class: 'border-amber-500/50 text-amber-400' },
  SUPER_ADMIN: { label: 'Super Admin', class: 'border-rose-500/50 text-rose-400' },
};

export function RoleBadge({ role }: { role: string }) {
  const cfg = ROLE_CONFIG[role] ?? { label: role, class: 'border-slate-600 text-slate-300' };
  return (
    <Badge variant="outline" className={cn('text-xs font-medium', cfg.class)}>
      {cfg.label}
    </Badge>
  );
}
