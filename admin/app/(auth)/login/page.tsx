'use client';

import { useState } from 'react';
import { useAdminLogin } from '@/hooks/useAdmin';
import { GuestGuard } from '@/components/shared/AuthGuard';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Church, Eye, EyeOff, Loader2 } from 'lucide-react';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPw, setShowPw] = useState(false);
  const [error, setError] = useState('');

  const login = useAdminLogin();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    try {
      await login.mutateAsync({ email, password });
    } catch (err: any) {
      setError(err.response?.data?.message || 'Login failed. Check your credentials.');
    }
  }

  return (
    <GuestGuard>
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 p-4">
        <div className="w-full max-w-md space-y-6">
          {/* Logo */}
          <div className="flex flex-col items-center gap-2">
            <div className="w-14 h-14 bg-primary rounded-2xl flex items-center justify-center shadow-lg">
              <Church className="w-8 h-8 text-primary-foreground" />
            </div>
            <h1 className="text-2xl font-bold text-white">Church Admin</h1>
            <p className="text-slate-400 text-sm">Sign in to manage your church</p>
          </div>

          <Card className="border-slate-700 bg-slate-800/60 backdrop-blur shadow-xl">
            <CardHeader className="space-y-1 pb-4">
              <CardTitle className="text-xl text-white">Sign in</CardTitle>
              <CardDescription className="text-slate-400">
                Admin and Super Admin accounts only
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="email" className="text-slate-200">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    placeholder="admin@church.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    autoFocus
                    className="bg-slate-700 border-slate-600 text-white placeholder:text-slate-400 focus-visible:ring-primary"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="password" className="text-slate-200">Password</Label>
                  <div className="relative">
                    <Input
                      id="password"
                      type={showPw ? 'text' : 'password'}
                      placeholder="••••••••"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                      className="bg-slate-700 border-slate-600 text-white placeholder:text-slate-400 focus-visible:ring-primary pr-10"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPw(!showPw)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-200"
                      tabIndex={-1}
                    >
                      {showPw ? <EyeOff size={16} /> : <Eye size={16} />}
                    </button>
                  </div>
                </div>

                {error && (
                  <p className="text-sm text-red-400 bg-red-400/10 border border-red-400/20 rounded-md px-3 py-2">
                    {error}
                  </p>
                )}

                <Button
                  type="submit"
                  className="w-full"
                  disabled={login.isPending}
                >
                  {login.isPending ? (
                    <><Loader2 className="w-4 h-4 mr-2 animate-spin" /> Signing in…</>
                  ) : 'Sign in'}
                </Button>
              </form>
            </CardContent>
          </Card>

          <p className="text-center text-slate-500 text-xs">
            Church App Admin Dashboard · Restricted Access
          </p>
        </div>
      </div>
    </GuestGuard>
  );
}
