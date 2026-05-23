'use client';

import { useState } from 'react';
import { Plus, Pencil, Trash2, Loader2, Image as ImageIcon, Mic, Music, Search, Images } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { ConfirmDialog } from '@/components/shared/ConfirmDialog';
import {
  useAlbums, useCreateAlbum, useUpdateAlbum, useDeleteAlbum, useAlbumPhotos, useAddPhotos, useDeletePhoto,
  usePodcasts, useCreatePodcast, useUpdatePodcast, useDeletePodcast,
  useSongs, useCreateSong, useUpdateSong, useDeleteSong,
  type PhotoAlbum, type PodcastEpisode, type WorshipSong,
} from '@/hooks/useMedia';
import { formatDate } from '@/lib/format';

type Tab = 'albums' | 'podcasts' | 'songs';

export default function MediaPage() {
  const [tab, setTab] = useState<Tab>('albums');

  return (
    <div className="space-y-6">
      <PageHeader title="Media Library" description="Manage photo albums, podcast episodes, and worship songs" />

      {/* Tab Bar */}
      <div className="flex gap-1 rounded-xl border border-slate-700 bg-slate-800/50 p-1 w-fit">
        {([['albums', ImageIcon, 'Albums'], ['podcasts', Mic, 'Podcasts'], ['songs', Music, 'Songs']] as const).map(([key, Icon, label]) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={`flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium transition-colors ${tab === key ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-slate-100'}`}
          >
            <Icon className="h-4 w-4" />
            {label}
          </button>
        ))}
      </div>

      {tab === 'albums' && <AlbumsTab />}
      {tab === 'podcasts' && <PodcastsTab />}
      {tab === 'songs' && <SongsTab />}
    </div>
  );
}

// ── Albums Tab ────────────────────────────────────────────────
function AlbumsTab() {
  const { data: albums, isLoading } = useAlbums();
  const createAlbum = useCreateAlbum();
  const updateAlbum = useUpdateAlbum();
  const deleteAlbum = useDeleteAlbum();

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<PhotoAlbum | null>(null);
  const [form, setForm] = useState({ title: '', description: '', coverImageUrl: '' });
  const [deleteTarget, setDeleteTarget] = useState<PhotoAlbum | null>(null);
  const [viewAlbum, setViewAlbum] = useState<PhotoAlbum | null>(null);

  const openCreate = () => { setEditing(null); setForm({ title: '', description: '', coverImageUrl: '' }); setOpen(true); };
  const openEdit = (a: PhotoAlbum) => { setEditing(a); setForm({ title: a.title, description: a.description ?? '', coverImageUrl: a.coverImageUrl ?? '' }); setOpen(true); };

  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const data = { ...form, description: form.description || undefined, coverImageUrl: form.coverImageUrl || undefined };
    if (editing) {
      updateAlbum.mutate({ id: editing.id, ...data }, { onSuccess: () => setOpen(false) });
    } else {
      createAlbum.mutate(data as Parameters<typeof createAlbum.mutate>[0], { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500">
          <Plus className="h-4 w-4" /> New Album
        </button>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : !albums || albums.length === 0 ? (
        <Empty icon={Images} label="No albums yet" />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {albums.map(a => (
            <div key={a.id} className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
              {a.coverImageUrl ? (
                <img src={a.coverImageUrl} alt={a.title} className="w-full h-36 object-cover" />
              ) : (
                <div className="w-full h-36 bg-slate-700 flex items-center justify-center">
                  <ImageIcon className="h-8 w-8 text-slate-500" />
                </div>
              )}
              <div className="p-4">
                <p className="font-semibold text-slate-100">{a.title}</p>
                {a.description && <p className="text-sm text-slate-400 mt-1 line-clamp-2">{a.description}</p>}
                <div className="flex items-center justify-between mt-3">
                  <button onClick={() => setViewAlbum(a)} className="text-xs text-indigo-400 hover:text-indigo-300">
                    {(a._count?.photos ?? a.photoCount)} photos →
                  </button>
                  <div className="flex gap-1">
                    <button onClick={() => openEdit(a)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                    <button onClick={() => setDeleteTarget(a)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {open && (
        <Dialog title={editing ? 'Edit Album' : 'New Album'} onClose={() => setOpen(false)}>
          <form onSubmit={handleSubmit} className="space-y-4">
            <DField label="Album Title *" value={form.title} onChange={set('title')} required />
            <DTextarea label="Description" value={form.description} onChange={set('description')} />
            <DField label="Cover Image URL" value={form.coverImageUrl} onChange={set('coverImageUrl')} placeholder="https://..." />
            <DialogActions onClose={() => setOpen(false)} loading={createAlbum.isPending || updateAlbum.isPending} label={editing ? 'Save' : 'Create'} />
          </form>
        </Dialog>
      )}

      {viewAlbum && <AlbumPhotosDialog album={viewAlbum} onClose={() => setViewAlbum(null)} />}

      <ConfirmDialog open={!!deleteTarget} title="Delete Album" description={`Delete "${deleteTarget?.title}" and all its photos?`} onConfirm={() => deleteAlbum.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={deleteAlbum.isPending} />
    </div>
  );
}

function AlbumPhotosDialog({ album, onClose }: { album: PhotoAlbum; onClose: () => void }) {
  const { data: photos, isLoading } = useAlbumPhotos(album.id);
  const addPhotos = useAddPhotos();
  const deletePhoto = useDeletePhoto();
  const [newUrl, setNewUrl] = useState('');
  const [newCaption, setNewCaption] = useState('');

  const handleAdd = () => {
    if (!newUrl.trim()) return;
    addPhotos.mutate({ albumId: album.id, photos: [{ imageUrl: newUrl.trim(), caption: newCaption.trim() || undefined }] }, { onSuccess: () => { setNewUrl(''); setNewCaption(''); } });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="w-full max-w-2xl rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-5 max-h-[90vh] flex flex-col">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-slate-100">{album.title} — Photos</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-100 text-xl leading-none">×</button>
        </div>

        <div className="flex gap-2">
          <input value={newUrl} onChange={e => setNewUrl(e.target.value)} placeholder="Image URL" className="flex-1 rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none" />
          <input value={newCaption} onChange={e => setNewCaption(e.target.value)} placeholder="Caption" className="w-40 rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 focus:border-indigo-500 focus:outline-none" />
          <button onClick={handleAdd} disabled={addPhotos.isPending || !newUrl.trim()} className="flex items-center gap-1.5 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
            {addPhotos.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />} Add
          </button>
        </div>

        <div className="overflow-y-auto flex-1">
          {isLoading ? (
            <div className="flex justify-center py-10"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
          ) : !photos || photos.length === 0 ? (
            <p className="text-center text-slate-500 py-10">No photos in this album</p>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
              {photos.map(p => (
                <div key={p.id} className="relative group rounded-lg overflow-hidden border border-slate-700">
                  <img src={p.imageUrl} alt={p.caption ?? ''} className="w-full h-28 object-cover" />
                  {p.caption && <p className="text-xs text-slate-400 px-2 py-1 bg-slate-800 truncate">{p.caption}</p>}
                  <button
                    onClick={() => deletePhoto.mutate({ photoId: p.id, albumId: album.id })}
                    className="absolute top-1 right-1 hidden group-hover:flex h-6 w-6 items-center justify-center rounded bg-red-600/90 text-white"
                  >
                    <Trash2 className="h-3 w-3" />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ── Podcasts Tab ──────────────────────────────────────────────
function PodcastsTab() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const { data, isLoading } = usePodcasts({ page, limit: 20, search: search || undefined });
  const createPodcast = useCreatePodcast();
  const updatePodcast = useUpdatePodcast();
  const deletePodcast = useDeletePodcast();

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<PodcastEpisode | null>(null);
  const [form, setForm] = useState({ title: '', description: '', audioUrl: '', duration: '', thumbnailUrl: '', publishedAt: '' });
  const [deleteTarget, setDeleteTarget] = useState<PodcastEpisode | null>(null);

  const episodes = data?.episodes ?? [];

  const openCreate = () => { setEditing(null); setForm({ title: '', description: '', audioUrl: '', duration: '', thumbnailUrl: '', publishedAt: '' }); setOpen(true); };
  const openEdit = (ep: PodcastEpisode) => {
    setEditing(ep);
    setForm({ title: ep.title, description: ep.description ?? '', audioUrl: ep.audioUrl, duration: String(ep.duration), thumbnailUrl: ep.thumbnailUrl ?? '', publishedAt: ep.publishedAt.split('T')[0] });
    setOpen(true);
  };

  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { ...form, duration: Number(form.duration), description: form.description || undefined, thumbnailUrl: form.thumbnailUrl || undefined, publishedAt: form.publishedAt || undefined };
    if (editing) {
      updatePodcast.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      createPodcast.mutate(payload as Parameters<typeof createPodcast.mutate>[0], { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search podcasts…" className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
        </div>
        <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 shrink-0">
          <Plus className="h-4 w-4" /> New Episode
        </button>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : episodes.length === 0 ? (
        <Empty icon={Mic} label="No podcast episodes yet" />
      ) : (
        <div className="rounded-xl border border-slate-700 bg-slate-800 divide-y divide-slate-700/50">
          {episodes.map(ep => (
            <div key={ep.id} className="flex items-center gap-4 p-4 hover:bg-slate-700/30">
              {ep.thumbnailUrl ? (
                <img src={ep.thumbnailUrl} alt="" className="h-12 w-12 rounded object-cover shrink-0 border border-slate-700" />
              ) : (
                <span className="h-12 w-12 rounded bg-slate-700 flex items-center justify-center shrink-0"><Mic className="h-5 w-5 text-slate-500" /></span>
              )}
              <div className="flex-1 min-w-0">
                <p className="font-medium text-slate-100 truncate">{ep.title}</p>
                <p className="text-xs text-slate-400">{formatDate(ep.publishedAt)} · {Math.floor(ep.duration / 60)}m {ep.duration % 60}s</p>
              </div>
              <div className="flex gap-1 shrink-0">
                <button onClick={() => openEdit(ep)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                <button onClick={() => setDeleteTarget(ep)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
              </div>
            </div>
          ))}
        </div>
      )}

      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} episodes</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5 text-slate-300">{page} / {data?.totalPages}</span>
            <button onClick={() => setPage(p => Math.min(data?.totalPages ?? 1, p + 1))} disabled={page === data?.totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}

      {open && (
        <Dialog title={editing ? 'Edit Episode' : 'New Podcast Episode'} onClose={() => setOpen(false)}>
          <form onSubmit={handleSubmit} className="space-y-4">
            <DField label="Title *" value={form.title} onChange={set('title')} required />
            <DTextarea label="Description" value={form.description} onChange={set('description')} />
            <DField label="Audio URL *" value={form.audioUrl} onChange={set('audioUrl')} required placeholder="https://..." />
            <div className="grid grid-cols-2 gap-3">
              <DField label="Duration (seconds) *" value={form.duration} onChange={set('duration')} required type="number" />
              <DField label="Published Date" value={form.publishedAt} onChange={set('publishedAt')} type="date" />
            </div>
            <DField label="Thumbnail URL" value={form.thumbnailUrl} onChange={set('thumbnailUrl')} placeholder="https://..." />
            <DialogActions onClose={() => setOpen(false)} loading={createPodcast.isPending || updatePodcast.isPending} label={editing ? 'Save' : 'Create'} />
          </form>
        </Dialog>
      )}

      <ConfirmDialog open={!!deleteTarget} title="Delete Episode" description={`Delete "${deleteTarget?.title}"?`} onConfirm={() => deletePodcast.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={deletePodcast.isPending} />
    </div>
  );
}

// ── Songs Tab ─────────────────────────────────────────────────
function SongsTab() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const { data, isLoading } = useSongs({ page, limit: 20, search: search || undefined });
  const createSong = useCreateSong();
  const updateSong = useUpdateSong();
  const deleteSong = useDeleteSong();

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<WorshipSong | null>(null);
  const [form, setForm] = useState({ title: '', artist: '', key: '', tempo: '', tags: '' });
  const [deleteTarget, setDeleteTarget] = useState<WorshipSong | null>(null);

  const songs = data?.songs ?? [];

  const openCreate = () => { setEditing(null); setForm({ title: '', artist: '', key: '', tempo: '', tags: '' }); setOpen(true); };
  const openEdit = (s: WorshipSong) => { setEditing(s); setForm({ title: s.title, artist: s.artist, key: s.key ?? '', tempo: s.tempo ? String(s.tempo) : '', tags: s.tags.join(', ') }); setOpen(true); };

  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { title: form.title, artist: form.artist, key: form.key || undefined, tempo: form.tempo ? Number(form.tempo) : undefined, tags: form.tags ? form.tags.split(',').map(t => t.trim()).filter(Boolean) : [] };
    if (editing) {
      updateSong.mutate({ id: editing.id, ...payload }, { onSuccess: () => setOpen(false) });
    } else {
      createSong.mutate(payload as Parameters<typeof createSong.mutate>[0], { onSuccess: () => setOpen(false) });
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search by title or artist…" className="w-full rounded-lg border border-slate-700 bg-slate-800 pl-9 pr-4 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
        </div>
        <button onClick={openCreate} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 shrink-0">
          <Plus className="h-4 w-4" /> Add Song
        </button>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20"><Loader2 className="h-6 w-6 animate-spin text-indigo-400" /></div>
      ) : songs.length === 0 ? (
        <Empty icon={Music} label="No songs yet" />
      ) : (
        <div className="rounded-xl border border-slate-700 bg-slate-800 overflow-hidden">
          <table className="w-full text-sm">
            <thead className="border-b border-slate-700 text-xs font-medium text-slate-400 uppercase tracking-wider">
              <tr>
                <th className="px-5 py-3 text-left">Title</th>
                <th className="px-5 py-3 text-left hidden sm:table-cell">Artist</th>
                <th className="px-5 py-3 text-left hidden md:table-cell">Key</th>
                <th className="px-5 py-3 text-left hidden lg:table-cell">Tempo</th>
                <th className="px-5 py-3 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-700/50">
              {songs.map(s => (
                <tr key={s.id} className="hover:bg-slate-700/30">
                  <td className="px-5 py-3 font-medium text-slate-100">{s.title}</td>
                  <td className="px-5 py-3 text-slate-400 hidden sm:table-cell">{s.artist}</td>
                  <td className="px-5 py-3 hidden md:table-cell">
                    {s.key ? <span className="rounded bg-slate-700 px-2 py-0.5 text-xs text-slate-300">{s.key}</span> : <span className="text-slate-600">—</span>}
                  </td>
                  <td className="px-5 py-3 text-slate-400 hidden lg:table-cell">{s.tempo ? `${s.tempo} BPM` : '—'}</td>
                  <td className="px-5 py-3">
                    <div className="flex justify-end gap-1">
                      <button onClick={() => openEdit(s)} className="p-1.5 rounded-lg text-slate-400 hover:text-indigo-400 hover:bg-slate-700"><Pencil className="h-3.5 w-3.5" /></button>
                      <button onClick={() => setDeleteTarget(s)} className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700"><Trash2 className="h-3.5 w-3.5" /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {(data?.totalPages ?? 1) > 1 && (
        <div className="flex items-center justify-between text-sm text-slate-400">
          <span>{data?.total} songs</span>
          <div className="flex gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Previous</button>
            <span className="px-3 py-1.5 text-slate-300">{page} / {data?.totalPages}</span>
            <button onClick={() => setPage(p => Math.min(data?.totalPages ?? 1, p + 1))} disabled={page === data?.totalPages} className="rounded-lg border border-slate-700 px-3 py-1.5 hover:bg-slate-700 disabled:opacity-40">Next</button>
          </div>
        </div>
      )}

      {open && (
        <Dialog title={editing ? 'Edit Song' : 'Add Song'} onClose={() => setOpen(false)}>
          <form onSubmit={handleSubmit} className="space-y-4">
            <DField label="Title *" value={form.title} onChange={set('title')} required />
            <DField label="Artist *" value={form.artist} onChange={set('artist')} required />
            <div className="grid grid-cols-2 gap-3">
              <DField label="Key" value={form.key} onChange={set('key')} placeholder="e.g. G, Am" />
              <DField label="Tempo (BPM)" value={form.tempo} onChange={set('tempo')} type="number" placeholder="e.g. 120" />
            </div>
            <DField label="Tags (comma-separated)" value={form.tags} onChange={set('tags')} placeholder="e.g. worship, contemporary" />
            <DialogActions onClose={() => setOpen(false)} loading={createSong.isPending || updateSong.isPending} label={editing ? 'Save' : 'Add'} />
          </form>
        </Dialog>
      )}

      <ConfirmDialog open={!!deleteTarget} title="Delete Song" description={`Delete "${deleteTarget?.title}"?`} onConfirm={() => deleteSong.mutate(deleteTarget!.id, { onSuccess: () => setDeleteTarget(null) })} onClose={() => setDeleteTarget(null)} loading={deleteSong.isPending} />
    </div>
  );
}

// ── Shared UI Primitives ──────────────────────────────────────
function Empty({ icon: Icon, label }: { icon: React.ElementType; label: string }) {
  return (
    <div className="flex flex-col items-center justify-center py-20 text-slate-500">
      <Icon className="h-10 w-10 mb-3" />
      <p className="font-medium text-slate-300">{label}</p>
    </div>
  );
}

function Dialog({ title, children, onClose }: { title: string; children: React.ReactNode; onClose: () => void }) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 space-y-4">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-slate-100">{title}</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-100 text-xl leading-none">×</button>
        </div>
        {children}
      </div>
    </div>
  );
}

function DField({ label, required, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { label: string }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <input {...props} required={required} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500" />
    </div>
  );
}

function DTextarea({ label, ...props }: React.TextareaHTMLAttributes<HTMLTextAreaElement> & { label: string }) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium text-slate-300">{label}</label>
      <textarea {...props} rows={3} className="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 resize-none" />
    </div>
  );
}

function DialogActions({ onClose, loading, label }: { onClose: () => void; loading: boolean; label: string }) {
  return (
    <div className="flex gap-3 justify-end pt-2">
      <button type="button" onClick={onClose} className="rounded-lg border border-slate-600 px-4 py-2 text-sm text-slate-300 hover:bg-slate-800">Cancel</button>
      <button type="submit" disabled={loading} className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-60">
        {loading && <Loader2 className="h-4 w-4 animate-spin" />} {label}
      </button>
    </div>
  );
}
