import { useId, useState, type FormEvent } from 'react';
import { ArrowRight, Mail } from 'lucide-react';
import { Card, CardContent, CardHeader } from './ui/card';

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

interface InviteColleagueProps {
  title?: string;
  description?: string;
  ctaLabel?: string;
  onSendInvitation?: (email: string) => Promise<void>;
}

type InviteMode = 'idle' | 'form' | 'sending' | 'sent' | 'error';

export function InviteColleague({
  title = 'Invite a colleague',
  description = 'Invite a colleague to join the Intel Partner Alliance (IPA) program and help your team unlock more value.',
  ctaLabel = 'Send invitation',
  onSendInvitation,
}: InviteColleagueProps) {
  const id = useId();
  const [mode, setMode] = useState<InviteMode>('idle');
  const [email, setEmail] = useState('');

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const trimmed = email.trim();
    if (!EMAIL_RE.test(trimmed)) return;
    setMode('sending');
    try {
      if (onSendInvitation) {
        await onSendInvitation(trimmed);
      }
      setMode('sent');
      setEmail('');
    } catch {
      setMode('error');
    }
  };

  return (
    <Card
      role="region"
      aria-labelledby={`${id}-heading`}
      className="flex min-w-0 flex-col gap-2 rounded-xl border border-sky-100 bg-linear-to-br from-[#f5f9ff] to-[#e6f0fc] py-3 text-[#0b2340] shadow-xs"
    >
      <CardHeader className="flex items-center justify-between gap-2 px-4">
        <h2 id={`${id}-heading`} className="text-sm font-bold">
          {title}
        </h2>
      </CardHeader>
      <CardContent className="flex min-w-0 flex-col gap-2.5 px-4">
        <div className="grid grid-cols-[1fr_auto] items-center gap-3">
          <p className="m-0 text-xs leading-relaxed text-[#0b2340]">
            {description}
          </p>
          <span
            aria-hidden="true"
            className="inline-flex size-10 shrink-0 items-center justify-center rounded-xl bg-linear-to-br from-[#4aa3f5] to-[#1e6fd9] text-white shadow-sm"
          >
            <Mail className="size-4.5" />
          </span>
        </div>

        {mode === 'idle' && (
          <button
            type="button"
            onClick={() => setMode('form')}
            className="inline-flex items-center gap-1.5 self-start rounded-md border border-sky-700 bg-white px-3 py-1.5 text-xs font-semibold text-sky-700 transition-colors hover:bg-sky-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-700"
          >
            {ctaLabel} <ArrowRight aria-hidden="true" className="size-3.5" />
          </button>
        )}

        {(mode === 'form' || mode === 'sending' || mode === 'error') && (
          <form
            onSubmit={handleSubmit}
            className="mt-auto flex flex-wrap items-center gap-1.5"
          >
            <input
              type="email"
              required
              placeholder="colleague@company.com"
              value={email}
              onChange={e => setEmail(e.target.value)}
              aria-label="Colleague email"
              className="h-8 min-w-0 flex-1 rounded-md border border-slate-300 bg-white px-2.5 text-xs text-slate-900 placeholder:text-slate-400 focus-visible:outline-2 focus-visible:outline-sky-700"
            />
            <button
              type="submit"
              disabled={mode === 'sending'}
              className="h-8 shrink-0 rounded-md bg-sky-700 px-3 text-xs font-semibold text-white transition-colors hover:bg-sky-800 disabled:opacity-60"
            >
              {mode === 'sending' ? 'Sending…' : 'Send'}
            </button>
            {mode === 'error' && (
              <p
                role="alert"
                className="m-0 basis-full text-xs text-red-700"
              >
                Could not send. Try again.
              </p>
            )}
          </form>
        )}

        {mode === 'sent' && (
          <p
            role="status"
            className="mt-auto m-0 text-xs font-medium text-emerald-700"
          >
            Invitation sent.{' '}
            <button
              type="button"
              onClick={() => setMode('form')}
              className="font-semibold text-sky-700 hover:underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-700"
            >
              Invite another
            </button>
          </p>
        )}
      </CardContent>
    </Card>
  );
}

