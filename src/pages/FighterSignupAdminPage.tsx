import {useEffect,useMemo,useState} from 'react';
import {useAppState} from '../features/AppState';
import {createEventSignupCode,disableEventSignupCode,listEventSignupCodes,listFighterSignups,updateFighterSignup,type EventSignupCode,type FighterEventSignup,type FighterSignupStatus} from '../lib/fighterSignup';

const statuses:FighterSignupStatus[]=['new','confirmed','declined','contacted','archived'];

export function FighterSignupAdminPage(){
  const {event}=useAppState();
  const [rows,setRows]=useState<FighterEventSignup[]>([]);
  const [filter,setFilter]=useState<FighterSignupStatus|'all'>('all');
  const [notes,setNotes]=useState<Record<string,string>>({});
  const [message,setMessage]=useState('');
  const [busy,setBusy]=useState(false);
  const [codes,setCodes]=useState<EventSignupCode[]>([]);
  const [newCode,setNewCode]=useState('');
  const [codeForm,setCodeForm]=useState({label:'Fighter invite',maxUses:1,expiresAt:''});

  const refresh=async()=>{
    if(!event)return;
    const [data,codeRows]=await Promise.all([listFighterSignups(event.id),listEventSignupCodes(event.id)]);
    setRows(data);
    setCodes(codeRows);
    setNotes(Object.fromEntries(data.map(row=>[row.id,row.organizerNotes??''])));
  };

  useEffect(()=>{refresh().catch(error=>setMessage(error instanceof Error?error.message:'Unable to load fighter signups.'))},[event?.id]);

  const filtered=useMemo(()=>filter==='all'?rows:rows.filter(row=>row.status===filter),[rows,filter]);
  const counts=useMemo(()=>rows.reduce<Record<string,number>>((acc,row)=>{acc[row.status]=(acc[row.status]??0)+1;return acc},{}),[rows]);

  if(!event)return <div className="state-card">Choose an event first.</div>;

  const createCode=async()=>{
    if(!event)return;
    setBusy(true);setMessage('');setNewCode('');
    try{
      const code=await createEventSignupCode({eventId:event.id,label:codeForm.label,maxUses:codeForm.maxUses,expiresAt:codeForm.expiresAt||undefined});
      setNewCode(code);
      await refresh();
      setMessage('Signup code created. Copy the full code now; it is only shown once.');
    }catch(error){setMessage(error instanceof Error?error.message:'Unable to create signup code.')}
    finally{setBusy(false)}
  };

  const save=async(row:FighterEventSignup,status:FighterSignupStatus)=>{
    setBusy(true);setMessage('');
    try{
      await updateFighterSignup(row.id,status,notes[row.id]??'');
      await refresh();
      setMessage('Fighter signup updated.');
    }catch(error){setMessage(error instanceof Error?error.message:'Unable to update fighter signup.')}
    finally{setBusy(false)}
  };

  return <>
    <section className="section-head"><div><span className="eyebrow">Event entries</span><h1>Fighter Signups</h1><p>{event.name} · preliminary fighter interest stored privately in BuhurtOS.</p></div></section>
    <div className="admin-grid">
      <section className="panel-card">
        <h2>Create fighter signup code</h2>
        <p>Codes are branded to this event. Anyone authorized through the host team, organization or platform can issue them.</p>
        <div className="form-stack">
          <label>Label<input value={codeForm.label} onChange={e=>setCodeForm(v=>({...v,label:e.target.value}))}/></label>
          <label>Maximum uses<input type="number" min={1} max={500} value={codeForm.maxUses} onChange={e=>setCodeForm(v=>({...v,maxUses:Math.max(1,Number(e.target.value)||1)}))}/></label>
          <label>Expires (optional)<input type="datetime-local" value={codeForm.expiresAt} onChange={e=>setCodeForm(v=>({...v,expiresAt:e.target.value}))}/></label>
          <button className="primary" disabled={busy} onClick={createCode}>Create signup code</button>
          {newCode&&<div className="state-card"><strong>Copy this code now</strong><div className="access-code-reveal"><code>{newCode}</code><button onClick={()=>navigator.clipboard?.writeText(newCode)}>Copy</button></div></div>}
        </div>
      </section>
      <section className="panel-card">
        <h2>Active codes</h2>
        <div className="membership-list">{codes.length===0?<div className="state-card">No signup codes yet.</div>:codes.map(code=><article key={code.id}><div className="grow"><strong>{code.label}</strong><small>{code.codePrefix}-•••••• · {code.uses}/{code.maxUses} used{code.expiresAt?' · expires '+new Date(code.expiresAt).toLocaleString():''}</small></div>{code.disabledAt?<span className="status-chip">Disabled</span>:<button disabled={busy} onClick={async()=>{setBusy(true);try{await disableEventSignupCode(code.id);await refresh()}finally{setBusy(false)}}}>Disable</button>}</article>)}</div>
      </section>
    </div>
    <div className="registration-summary">
      {statuses.map(status=><button key={status} className={filter===status?'selected':''} onClick={()=>setFilter(status)}><b>{counts[status]??0}</b><span>{status}</span></button>)}
      <button className={filter==='all'?'selected':''} onClick={()=>setFilter('all')}><b>{rows.length}</b><span>all</span></button>
    </div>
    {message&&<div className="auth-message">{message}</div>}
    {filtered.length===0?<div className="state-card">No fighter signups match this filter.</div>:
      <div className="registration-review-list">{filtered.map(row=><article className="panel-card" key={row.id}>
        <div className="registration-review-head"><div><span className="eyebrow">{row.teamName||'Independent / no team listed'}</span><h3>{row.displayName}</h3><p>{row.email}{row.phone?' · '+row.phone:''}</p></div><span className="status-pill">{row.status}</span></div>
        <div className="registration-review-meta">
          <span><small>Experience</small><b>{row.experienceYears!=null?row.experienceYears+' years':'Not given'}</b></span>
          <span><small>Armor</small><b>{row.armorStatus||'Not given'}</b></span>
          <span><small>Submitted</small><b>{new Date(row.createdAt).toLocaleDateString()}</b></span>
        </div>
        <div className="fighter-signup-admin-details">
          <div><small>Fighting interests</small><p>{row.fightingCategories.length?row.fightingCategories.join(', '):'None selected'}</p></div>
          {row.attendanceNotes&&<div><small>Attendance / travel</small><p>{row.attendanceNotes}</p></div>}
          {row.emergencyContact&&<div><small>Emergency contact</small><p>{row.emergencyContact}</p></div>}
          {row.additionalNotes&&<div><small>Additional notes</small><p>{row.additionalNotes}</p></div>}
        </div>
        <div className="form-stack"><label>Organizer notes<textarea value={notes[row.id]??''} onChange={e=>setNotes(current=>({...current,[row.id]:e.target.value}))}/></label></div>
        <div className="header-actions">{statuses.filter(status=>status!=='new').map(status=><button key={status} className={status==='confirmed'?'primary':''} disabled={busy||row.status===status} onClick={()=>save(row,status)}>{status==='confirmed'?'Accept':status==='declined'?'Deny':status.replace(/^./,c=>c.toUpperCase())}</button>)}</div>
      </article>)}</div>}
  </>;
}
