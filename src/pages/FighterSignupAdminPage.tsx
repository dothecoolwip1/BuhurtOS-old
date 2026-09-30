import {useEffect,useMemo,useState} from 'react';
import {useAppState} from '../features/AppState';
import {listFighterSignups,updateFighterSignup,type FighterEventSignup,type FighterSignupStatus} from '../lib/fighterSignup';

const statuses:FighterSignupStatus[]=['new','contacted','confirmed','declined','archived'];

export function FighterSignupAdminPage(){
  const {event}=useAppState();
  const [rows,setRows]=useState<FighterEventSignup[]>([]);
  const [filter,setFilter]=useState<FighterSignupStatus|'all'>('all');
  const [notes,setNotes]=useState<Record<string,string>>({});
  const [message,setMessage]=useState('');
  const [busy,setBusy]=useState(false);

  const refresh=async()=>{
    if(!event)return;
    const data=await listFighterSignups(event.id);
    setRows(data);
    setNotes(Object.fromEntries(data.map(row=>[row.id,row.organizerNotes??''])));
  };

  useEffect(()=>{refresh().catch(error=>setMessage(error instanceof Error?error.message:'Unable to load fighter signups.'))},[event?.id]);

  const filtered=useMemo(()=>filter==='all'?rows:rows.filter(row=>row.status===filter),[rows,filter]);
  const counts=useMemo(()=>rows.reduce<Record<string,number>>((acc,row)=>{acc[row.status]=(acc[row.status]??0)+1;return acc},{}),[rows]);

  if(!event)return <div className="state-card">Choose an event first.</div>;

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
    <section className="section-head"><div><span className="eyebrow">Event intake</span><h1>Fighter Signups</h1><p>{event.name} · preliminary fighter interest stored privately in BuhurtOS.</p></div></section>
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
        <div className="header-actions">{statuses.filter(status=>status!=='new').map(status=><button key={status} className={status==='confirmed'?'primary':''} disabled={busy||row.status===status} onClick={()=>save(row,status)}>{status.replace(/^./,c=>c.toUpperCase())}</button>)}</div>
      </article>)}</div>}
  </>;
}
