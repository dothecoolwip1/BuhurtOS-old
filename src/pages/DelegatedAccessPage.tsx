import { useEffect, useMemo, useState } from 'react';
import {
  createDelegatedAccessCode,
  disableDelegatedAccessCode,
  listDelegatedAccessCodes,
  listDelegatedAccessTargets,
  type DelegatedAccessCodeSummary,
  type DelegatedAccessTarget
} from '../lib/delegatedAccess';

const pretty = (value:string) => value.replaceAll('_',' ').replace(/\b\w/g, c => c.toUpperCase());

export function DelegatedAccessPage(){
  const [targets,setTargets]=useState<DelegatedAccessTarget[]>([]);
  const [codes,setCodes]=useState<DelegatedAccessCodeSummary[]>([]);
  const [targetKey,setTargetKey]=useState('');
  const [label,setLabel]=useState('');
  const [maxUses,setMaxUses]=useState(1);
  const [expiresAt,setExpiresAt]=useState('');
  const [newCode,setNewCode]=useState('');
  const [message,setMessage]=useState('');
  const [busy,setBusy]=useState(false);

  const refresh = async () => {
    const [targetRows,codeRows] = await Promise.all([listDelegatedAccessTargets(),listDelegatedAccessCodes()]);
    setTargets(targetRows);
    setCodes(codeRows);
    setTargetKey(current => current || (targetRows[0] ? [targetRows[0].scope,targetRows[0].targetId,targetRows[0].role].join('|') : ''));
  };

  useEffect(()=>{refresh().catch(error=>setMessage(error instanceof Error?error.message:'Unable to load access-code permissions.'))},[]);

  const selected = useMemo(()=>targets.find(row=>[row.scope,row.targetId,row.role].join('|')===targetKey),[targets,targetKey]);
  const grouped = useMemo(()=>{
    const map = new Map<string,DelegatedAccessTarget[]>();
    for(const row of targets){
      const key = row.scope+'|'+row.targetId+'|'+row.targetName;
      map.set(key,[...(map.get(key)??[]),row]);
    }
    return [...map.entries()];
  },[targets]);

  const create = async () => {
    if(!selected) return;
    setBusy(true); setMessage(''); setNewCode('');
    try{
      const code = await createDelegatedAccessCode({
        scope:selected.scope,
        targetId:selected.targetId,
        role:selected.role,
        label:label || selected.targetName+' '+pretty(selected.role),
        maxUses,
        expiresAt:expiresAt || undefined
      });
      setNewCode(code);
      setLabel('');
      await refresh();
      setMessage('Access code created. Copy it now; the full code is only shown once.');
    }catch(error){
      setMessage(error instanceof Error?error.message:'Unable to create access code.');
    }finally{setBusy(false)}
  };

  const disable = async (id:string) => {
    setBusy(true); setMessage('');
    try{ await disableDelegatedAccessCode(id); await refresh(); setMessage('Access code disabled.'); }
    catch(error){ setMessage(error instanceof Error?error.message:'Unable to disable code.'); }
    finally{setBusy(false)}
  };

  return <>
    <section className="section-head">
      <div>
        <span className="eyebrow">People & access</span>
        <h1>Access Codes</h1>
        <p>Create codes only for groups and roles below your authority. The server enforces the hierarchy, so a subgroup cannot promote itself above its parent.</p>
      </div>
    </section>

    {message && <div className="auth-message">{message}</div>}

    <div className="admin-grid">
      <section className="panel-card">
        <h2>Create a subgroup code</h2>
        {targets.length===0 ? <div className="state-card"><strong>No delegation permissions.</strong><p>Your current role does not allow you to issue access codes to another group.</p></div> :
        <div className="form-stack">
          <label>Group and role
            <select value={targetKey} onChange={e=>setTargetKey(e.target.value)}>
              {grouped.map(([key,rows])=>{
                const [scope,targetId,targetName]=key.split('|');
                return <optgroup key={key} label={pretty(scope)+': '+targetName}>
                  {rows.map(row=><option key={[row.scope,row.targetId,row.role].join('|')} value={[row.scope,row.targetId,row.role].join('|')}>{pretty(row.role)}</option>)}
                </optgroup>;
              })}
            </select>
          </label>
          <label>Label<input placeholder="e.g. Red Deer Reavers Fighters" value={label} onChange={e=>setLabel(e.target.value)}/></label>
          <label>Maximum uses<input type="number" min={1} max={500} value={maxUses} onChange={e=>setMaxUses(Math.max(1,Number(e.target.value)||1))}/></label>
          <label>Expires at (optional)<input type="datetime-local" value={expiresAt} onChange={e=>setExpiresAt(e.target.value)}/></label>
          <button className="primary big" disabled={busy || !selected} onClick={create}>{busy?'Creating…':'Create Access Code'}</button>
          {newCode && <div className="state-card"><strong>Copy this code now</strong><div className="access-code-reveal"><code>{newCode}</code><button onClick={()=>navigator.clipboard?.writeText(newCode)}>Copy</button></div><small>The full code is not stored in plaintext and cannot be shown again.</small></div>}
        </div>}
      </section>

      <section className="panel-card">
        <h2>How delegation works</h2>
        <div className="show-detail-rows">
          <div><span>Platform owner</span><b>Any organization, club or team</b></div>
          <div><span>Organization admin</span><b>Child organizations, clubs and teams</b></div>
          <div><span>Club admin</span><b>Teams inside that club</b></div>
          <div><span>Team admin</span><b>Captain, coach, fighter and support</b></div>
          <div><span>Fighter</span><b>No downstream code creation</b></div>
        </div>
      </section>
    </div>

    <section className="panel-card">
      <h2>Codes you can manage</h2>
      {codes.length===0 ? <div className="state-card">No delegated codes have been created yet.</div> :
      <div className="membership-list">{codes.map(code=><article key={code.id}>
        <div className="grow">
          <strong>{code.label}</strong>
          <small>{pretty(code.targetScope)} · {code.targetName} · {pretty(code.role)} · {code.activeUses}/{code.maxUses} uses · prefix {code.codePrefix}…</small>
          {code.expiresAt?<small>Expires {new Date(code.expiresAt).toLocaleString()}</small>:null}
        </div>
        {code.disabledAt?<span className="status-chip">Disabled</span>:<button disabled={busy} onClick={()=>disable(code.id)}>Disable</button>}
      </article>)}</div>}
    </section>
  </>;
}
