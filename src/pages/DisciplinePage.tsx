import { useEffect, useMemo, useState } from 'react';
import { useAppState } from '../features/AppState';
import type { DisciplineCard, Suspension } from '../types';
import { supabase } from '../lib/supabase';
import { disciplineCsv, downloadText, htmlTable, openPrintableReport, suspensionsCsv } from '../lib/export';

const DEMO_KEY = 'buhurtos-demo-discipline';
const DEMO_SUSP_KEY = 'buhurtos-demo-suspensions';
const demoSeed: DisciplineCard[] = [{ id: 'dc-1', eventId: 'event-hacsa-demo', seasonId: 'season-2026', rosterEntryId: 'r3', color: 'yellow', reason: 'Unsafe strike warning', notes: 'First warning', issuedAt: '2026-09-20T16:40:00.000Z' }];
const demoSuspSeed: Suspension[] = [{ id: 's-1', organizationId: 'org-hacsa-demo', rosterEntryId: 'r12', startsAt: '2026-09-25T00:00:00.000Z', endsAt: '2026-10-05T00:00:00.000Z', reason: 'Headshot on downed opponent', notes: 'Appeal window open', issuedAt: '2026-09-24T10:00:00.000Z', status: 'active' }];

function suspensionStatus(s: { startsAt: string; endsAt: string; revokedAt?: string | null }): Suspension['status'] {
  if (s.revokedAt) return 'revoked';
  const now = Date.now();
  const start = new Date(s.startsAt).getTime();
  const end = new Date(s.endsAt).getTime();
  if (now < start) return 'upcoming';
  if (now >= start && now < end) return 'active';
  return 'expired';
}

export function DisciplinePage() {
  const { event, roster, user } = useAppState();
  const [cards, setCards] = useState<DisciplineCard[]>([]);
  const [suspensions, setSuspensions] = useState<Suspension[]>([]);
  const [form, setForm] = useState({ rosterEntryId: '', color: 'yellow' as 'yellow'|'red', reason: '', notes: '' });
  const [suspForm, setSuspForm] = useState({ rosterEntryId: '', days: '14', reason: '' });
  const [message, setMessage] = useState('');

  const demo = !supabase;

  useEffect(() => {
    if (!event) return;
    if (!supabase) {
      const stored = localStorage.getItem(DEMO_KEY);
      setCards(stored ? JSON.parse(stored) : demoSeed);
      const sStored = localStorage.getItem(DEMO_SUSP_KEY);
      setSuspensions(sStored ? JSON.parse(sStored) : demoSuspSeed);
      return;
    }
    supabase.from('disciplinary_cards').select('*').eq('season_id', event.seasonId).order('issued_at', { ascending: false }).then(({ data, error }) => {
      if (error) return setMessage(error.message);
      setCards((data ?? []).map((c:any) => ({ id:c.id,eventId:c.event_id,seasonId:c.season_id,matchId:c.match_id??undefined,fighterId:c.fighter_id??undefined,rosterEntryId:c.roster_entry_id??undefined,color:c.color,reason:c.card_reason,notes:c.notes??undefined,issuedAt:c.issued_at })));
    });
    // Suspensions are read through RLS: org staff/admins and the fighter
    // themselves see only what they are allowed to.
    const byOrg = supabase.from('suspensions').select('*').eq('organization_id', event.organizationId).order('starts_at', { ascending: false }).then(({ data, error }) => error ? [] : ((data ?? []) as any[]).map((s:any) => normalizeSuspension(s)));
    const byEvent = supabase.from('suspensions').select('*').eq('event_id', event.id).order('starts_at', { ascending: false }).then(({ data, error }) => error ? [] : ((data ?? []) as any[]).map((s:any) => normalizeSuspension(s)));
    Promise.all([byOrg, byEvent]).then(([org, ev]) => {
      const merged = new Map<string, Suspension>();
      for (const s of [...org, ...ev]) merged.set(s.id, s);
      setSuspensions([...merged.values()].sort((a,b)=>b.startsAt.localeCompare(a.startsAt)));
    });
  }, [event?.id]);

  const rosterByName = useMemo(() => {
    const m = new Map<string, (typeof roster)[number]>();
    for (const r of roster) m.set(r.id, r);
    return m;
  }, [roster]);

  if (!event) return null;

  const save = async () => {
    if (!form.rosterEntryId || !form.reason.trim()) return;
    const entry = roster.find(r => r.id === form.rosterEntryId);
    if (!entry) return;
    if (!supabase) {
      const card: DisciplineCard = { id: crypto.randomUUID(), eventId:event.id, seasonId:event.seasonId, rosterEntryId:entry.id, fighterId:entry.fighterId, color:form.color, reason:form.reason.trim(), notes:form.notes.trim() || undefined, issuedAt:new Date().toISOString() };
      const next=[card,...cards]; setCards(next); localStorage.setItem(DEMO_KEY,JSON.stringify(next));
    } else {
      const { data, error } = await supabase.rpc('issue_discipline_card', {
        p_roster_entry_id: form.rosterEntryId,
        p_color: form.color,
        p_reason: form.reason.trim(),
        p_notes: form.notes.trim() || null,
      });
      if (error || !data) return setMessage(error?.message ?? 'The card could not be recorded.');
      const card: DisciplineCard = { id: data as string, eventId:event.id, seasonId:event.seasonId, rosterEntryId:entry.id, fighterId:entry.fighterId, color:form.color, reason:form.reason.trim(), notes:form.notes.trim() || undefined, issuedAt:new Date().toISOString() };
      setCards([card,...cards]);
    }
    setForm({ rosterEntryId:'',color:'yellow',reason:'',notes:'' }); setMessage('Card recorded in the season history.');
  };

  const issueSuspension = async () => {
    if (!suspForm.rosterEntryId || !suspForm.reason.trim()) return;
    const entry = roster.find(r => r.id === suspForm.rosterEntryId);
    if (!entry) return;
    const days = Math.max(1, parseInt(suspForm.days, 10) || 14);
    const startsAt = new Date();
    const endsAt = new Date(startsAt.getTime() + days * 86400000);
    const startIso = startsAt.toISOString();
    const endIso = endsAt.toISOString();
    if (!supabase) {
      const s: Suspension = { id: crypto.randomUUID(), organizationId: event.organizationId, rosterEntryId: entry.id, fighterId: entry.fighterId, eventId: event.id, seasonId: event.seasonId, startsAt: startIso, endsAt: endIso, reason: suspForm.reason.trim(), issuedAt: startIso, status: 'active' };
      const next=[s,...suspensions]; setSuspensions(next); localStorage.setItem(DEMO_SUSP_KEY,JSON.stringify(next));
      setSuspForm({ rosterEntryId:'',days:'14',reason:'' }); setMessage('Suspension recorded (demo).');
      return;
    }
    const { error } = await supabase.rpc('issue_suspension', {
      p_organization_id: event.organizationId,
      p_fighter_id: entry.fighterId ?? null,
      p_starts_at: startIso,
      p_ends_at: endIso,
      p_reason: suspForm.reason.trim(),
      p_notes: null,
      p_event_id: event.id,
      p_season_id: event.seasonId,
    });
    if (error) return setMessage(error.message);
    const s: Suspension = { id: crypto.randomUUID(), organizationId: event.organizationId, rosterEntryId: entry.id, fighterId: entry.fighterId, eventId: event.id, seasonId: event.seasonId, startsAt: startIso, endsAt: endIso, reason: suspForm.reason.trim(), issuedAt: startIso, status: 'active' };
    setSuspensions([s,...suspensions]);
    setSuspForm({ rosterEntryId:'',days:'14',reason:'' }); setMessage('Suspension issued. The fighter cannot be cleared for competition while it is active.');
  };

  const revokeSuspension = async (id: string) => {
    if (!supabase) {
      const next = suspensions.map(s => s.id === id ? { ...s, revokedAt: new Date().toISOString(), status: 'revoked' as const } : s);
      setSuspensions(next); localStorage.setItem(DEMO_SUSP_KEY, JSON.stringify(next)); return;
    }
    const { error } = await supabase.rpc('revoke_suspension', { p_suspension_id: id });
    if (error) return setMessage(error.message);
    setSuspensions(suspensions.map(s => s.id === id ? { ...s, revokedAt: new Date().toISOString(), status: 'revoked' as const } : s));
    setMessage('Suspension revoked; competition clearance is available again.');
  };

  const name=(id?:string)=>rosterByName.get(id ?? '')?.displayName ?? 'Unknown fighter';

  const fighterName = (fighterId?: string, rosterId?: string) => {
    if (rosterId) { const r = rosterByName.get(rosterId); if (r) return r.displayName; }
    if (fighterId) {
      const r = roster.find(x => x.fighterId === fighterId);
      if (r) return r.displayName;
    }
    return 'Unknown fighter';
  };

  return <>
    <section className="section-head">
      <div><span className="eyebrow">Event</span><h1>Cards &amp; suspensions</h1><p>Cards stay tied to both the event and season so repeat issues can be reviewed across events. Suspensions block competition clearance while active.</p></div>
      <div className="header-actions">
        <button onClick={() => downloadText('buhurtos-discipline-cards.csv', disciplineCsv(cards.map(c => ({ name: name(c.rosterEntryId), color: c.color, reason: c.reason, notes: c.notes, issuedAt: c.issuedAt }))))}>Export cards CSV</button>
        <button onClick={() => downloadText('buhurtos-suspensions.csv', suspensionsCsv(suspensions.map(s => ({ name: fighterName(s.fighterId, s.rosterEntryId), reason: s.reason, startsAt: s.startsAt, endsAt: s.endsAt, status: suspensionStatus(s), revokedAt: s.revokedAt }))))}>Export suspensions CSV</button>
        <button onClick={() => openPrintableReport(`${event.name} Discipline Report`, `${htmlTable(['Competitor', 'Color', 'Reason', 'Notes', 'Issued At'], cards.map(c => [name(c.rosterEntryId), c.color, c.reason, c.notes ?? '', new Date(c.issuedAt).toLocaleString()]))}${suspensions.length ? htmlTable(['Competitor', 'Reason', 'From', 'To', 'Status'], suspensions.map(s => [fighterName(s.fighterId, s.rosterEntryId), s.reason, new Date(s.startsAt).toLocaleDateString(), new Date(s.endsAt).toLocaleDateString(), suspensionStatus(s)])) : ''}`)}>Print / PDF</button>
      </div>
    </section>
    <div className="admin-grid">
      <section className="panel-card"><h2>Issue card</h2>
        <div className="form-stack">
          <label>Competitor<select value={form.rosterEntryId} onChange={e=>setForm(f=>({...f,rosterEntryId:e.target.value}))}><option value="">Choose competitor</option>{roster.filter(r=>r.fighterId).map(r=><option key={r.id} value={r.id}>{r.displayName}</option>)}</select></label>
          <label>Card<select value={form.color} onChange={e=>setForm(f=>({...f,color:e.target.value as 'yellow'|'red'}))}><option value="yellow">Yellow</option><option value="red">Red</option></select></label>
          <label>Reason<input value={form.reason} onChange={e=>setForm(f=>({...f,reason:e.target.value}))}/></label>
          <label>Notes<textarea value={form.notes} onChange={e=>setForm(f=>({...f,notes:e.target.value}))}/></label>
          <button className="primary big" onClick={save} disabled={!demo && (!user || !form.rosterEntryId)}>Record Card</button>
        </div>
      </section>
      <section className="panel-card"><h2>Season history</h2>
        <div className="discipline-list">{cards.map(card=><article key={card.id}><span className={`card-dot ${card.color}`}></span><div><b>{name(card.rosterEntryId)}</b><p>{card.reason}</p><small>{new Date(card.issuedAt).toLocaleString()}</small></div></article>)}</div>
      </section>
      <section className="panel-card"><h2>Suspend competitor</h2>
        <p className="field-hint">An active suspension prevents competition clearance for the covered event(s) at the database level, on every path.</p>
        <div className="form-stack">
          <label>Competitor<select value={suspForm.rosterEntryId} onChange={e=>setSuspForm(f=>({...f,rosterEntryId:e.target.value}))}><option value="">Choose competitor</option>{roster.filter(r=>r.fighterId).map(r=><option key={r.id} value={r.id}>{r.displayName}</option>)}</select></label>
          <label>Duration (days)<input type="number" min={1} max={730} value={suspForm.days} onChange={e=>setSuspForm(f=>({...f,days:e.target.value}))}/></label>
          <label>Reason<input value={suspForm.reason} onChange={e=>setSuspForm(f=>({...f,reason:e.target.value}))} placeholder="e.g. headshot on downed opponent"/></label>
          <button className="primary big" onClick={issueSuspension} disabled={!demo && (!user || !suspForm.rosterEntryId)}>Issue Suspension</button>
        </div>
      </section>
      <section className="panel-card"><h2>Suspensions</h2>
        <div className="discipline-list">{suspensions.map(s=>{const st = suspensionStatus(s); return <article key={s.id}><span className={`susp-dot ${st}`}></span><div><b>{fighterName(s.fighterId, s.rosterEntryId)}</b><p>{s.reason}</p><small>{st === 'revoked' ? `Revoked ${s.revokedAt ? new Date(s.revokedAt).toLocaleDateString() : ''}` : `${new Date(s.startsAt).toLocaleDateString()} – ${new Date(s.endsAt).toLocaleDateString()} · ${st}`}</small></div>{st !== 'revoked' && st !== 'expired' && <button className="ghost" onClick={()=>revokeSuspension(s.id)}>Revoke</button>}</article>;})}
        {suspensions.length === 0 && <p className="show-empty">No suspensions recorded for this organization.</p>}
        </div>
      </section>
    </div>
    {message&&<div className="auth-message">{message}</div>}
  </>;
}

function normalizeSuspension(s: any): Suspension {
  const st = suspensionStatus(s);
  return {
    id: s.id,
    organizationId: s.organization_id,
    fighterId: s.fighter_id ?? undefined,
    eventId: s.event_id ?? undefined,
    seasonId: s.season_id ?? undefined,
    startsAt: s.starts_at,
    endsAt: s.ends_at,
    reason: s.reason,
    notes: s.notes ?? undefined,
    revokedAt: s.revoked_at ?? null,
    revokedBy: s.revoked_by ?? null,
    issuedAt: s.created_at ?? s.starts_at,
    status: st,
  };
}