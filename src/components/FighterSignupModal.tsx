import {useEffect,useMemo,useState} from 'react';
import {Link,useLocation} from 'react-router-dom';
import {submitFighterSignup,validateFighterSignupCode} from '../lib/fighterSignup';
import {describeAccess,getEventRegistrationAccess,requestEventRegistrationAccess,type RegistrationAccess} from '../lib/registrationAccess';
import {friendlyError} from '../lib/friendlyError';

const categories=['5v5','12v12','30v30','Longsword','Sword & Buckler','Polearm','Pro Fight','Other'];

export function FighterSignupModal({open,onClose,eventId,eventName}:{open:boolean;onClose:()=>void;eventId:string;eventName:string}){
  const [form,setForm]=useState({
    displayName:'',email:'',phone:'',teamName:'',experienceYears:'',
    armorStatus:'Full kit',attendanceNotes:'',emergencyContact:'',additionalNotes:'',consent:false
  });
  const [selected,setSelected]=useState<string[]>([]);
  const [busy,setBusy]=useState(false);
  const [message,setMessage]=useState('');
  const [submitted,setSubmitted]=useState(false);
  const [code,setCode]=useState('');
  const [codeValid,setCodeValid]=useState(false);
  const [codeLabel,setCodeLabel]=useState('');
  const location=useLocation();
  const [access,setAccess]=useState<RegistrationAccess>();
  const [accessLoading,setAccessLoading]=useState(false);
  const [accessAttempt,setAccessAttempt]=useState(0);
  const [proceedWithoutCode,setProceedWithoutCode]=useState(false);
  const [showCodeEntry,setShowCodeEntry]=useState(false);
  const [reason,setReason]=useState('');
  const [requestSent,setRequestSent]=useState(false);

  // The server decides whether this person needs a code. The form only renders that answer.
  useEffect(()=>{
    if(!open)return;
    let active=true;
    setAccessLoading(true);setProceedWithoutCode(false);setShowCodeEntry(false);setRequestSent(false);
    getEventRegistrationAccess(eventId)
      .then(result=>{if(active)setAccess(result)})
      .catch(error=>{friendlyError(error);if(active)setAccess({state:'error'})})
      .finally(()=>{if(active)setAccessLoading(false)});
    return()=>{active=false};
  },[open,eventId,accessAttempt]);

  useEffect(()=>{
    if(!open)return;
    const onKey=(event:KeyboardEvent)=>{if(event.key==='Escape')onClose()};
    document.addEventListener('keydown',onKey);
    const previous=document.body.style.overflow;
    document.body.style.overflow='hidden';
    return()=>{document.removeEventListener('keydown',onKey);document.body.style.overflow=previous};
  },[open,onClose]);

  const valid=useMemo(()=>(codeValid||proceedWithoutCode) && form.displayName.trim().length>=2 && /.+@.+\..+/.test(form.email) && form.consent,[form,codeValid,proceedWithoutCode]);

  if(!open)return null;

  const toggle=(value:string)=>setSelected(current=>current.includes(value)?current.filter(item=>item!==value):[...current,value]);

  const verifyCode=async()=>{
    if(!code.trim())return;
    setBusy(true);setMessage('');
    try{
      const result=await validateFighterSignupCode(eventId,code);
      setCodeValid(Boolean(result.valid));
      setCodeLabel(result.label??'');
      setMessage(result.valid?'Code accepted. Fighter signup unlocked.':result.message??'Invalid signup code.');
    }catch(error){
      setCodeValid(false);
      setMessage(friendlyError(error).message);
    }finally{setBusy(false)}
  };

  const submit=async()=>{
    if(!valid)return;
    setBusy(true);setMessage('');
    try{
      await submitFighterSignup({
        eventId,
        code:proceedWithoutCode?'':code,
        displayName:form.displayName,
        email:form.email,
        phone:form.phone,
        teamName:form.teamName,
        experienceYears:form.experienceYears.trim()?Number(form.experienceYears):undefined,
        fightingCategories:selected,
        armorStatus:form.armorStatus,
        attendanceNotes:form.attendanceNotes,
        emergencyContact:form.emergencyContact,
        additionalNotes:form.additionalNotes,
        consentAcknowledged:form.consent
      });
      setSubmitted(true);
      setMessage('Signup received. The event organizers can now review it inside BuhurtOS.');
    }catch(error){
      const friendly=friendlyError(error);
      setMessage(friendly.message);
      if(friendly.action==='use_code'){setProceedWithoutCode(false);setShowCodeEntry(true);setAccessAttempt(n=>n+1)}
    }finally{setBusy(false)}
  };

  const requestPermission=async()=>{
    setBusy(true);setMessage('');
    try{
      await requestEventRegistrationAccess(eventId,reason);
      setRequestSent(true);
      setAccess({state:'permission_requested'});
    }catch(error){
      setMessage(friendlyError(error).message);
    }finally{setBusy(false)}
  };

  const copy=describeAccess(access?.state??'code_required');
  const signedOutHint=access?.state==='code_required'&&!accessLoading;
  const codeEntry=<div className="fighter-signup-code-entry">
    <input aria-label="Event registration code" value={code} onChange={e=>{setCode(e.target.value.toUpperCase());setCodeValid(false)}} placeholder="RDR26-ABC123" autoCapitalize="characters"/>
    <button className="show-btn primary" type="button" disabled={busy||!code.trim()} onClick={verifyCode}>{busy?'Checking…':'Enter code'}</button>
  </div>;
  const AccessGate=()=><>
    <div className="fighter-signup-trust">
      <span>{copy.next==='continue'?'✓':'🔐'}</span>
      <div><b>{copy.title}</b><small>{copy.body}</small></div>
    </div>
    {copy.next==='continue'?<button className="show-btn primary" type="button" onClick={()=>setProceedWithoutCode(true)}>Continue registration</button>:null}
    {copy.next==='request_or_code'&&!requestSent?<div className="form-stack">
      <label>Why should you have access? (optional)<textarea rows={2} value={reason} onChange={e=>setReason(e.target.value)} placeholder="For example: I fight for the host team."/></label>
      <div className="header-actions"><button className="show-btn primary" type="button" disabled={busy} onClick={requestPermission}>{busy?'Sending…':'Request permission'}</button><button className="show-btn secondary" type="button" onClick={()=>setShowCodeEntry(true)}>I have a signup code</button></div>
    </div>:null}
    {copy.next==='enter_code'||showCodeEntry?codeEntry:null}
    {access?.state==='error'?<button className="show-btn secondary" type="button" onClick={()=>setAccessAttempt(n=>n+1)}>Try again</button>:null}
    {signedOutHint?<small>Have a BuhurtOS account? <Link to={'/sign-in?next='+encodeURIComponent(location.pathname+location.search)} onClick={onClose}>Sign in</Link> — if you belong to the host organization you may not need a code.</small>:null}
    {copy.next==='none'?<button className="show-btn secondary" type="button" onClick={onClose}>Return to event</button>:null}
  </>;

  return <div className="fighter-signup-backdrop" role="presentation" onMouseDown={event=>{if(event.currentTarget===event.target)onClose()}}>
    <section className="fighter-signup-modal native" role="dialog" aria-modal="true" aria-labelledby="fighter-signup-title">
      <header className="fighter-signup-hero">
        <div>
          <span className="eyebrow">FIGHTER INTEREST FORM</span>
          <h2 id="fighter-signup-title">{eventName}</h2>
          <p>Tell the organizers who you are and what you want to fight. This is preliminary interest, not a confirmed registration or a reserved place. It stays inside BuhurtOS.</p>
        </div>
        <button className="fighter-signup-close" type="button" onClick={onClose} aria-label="Close fighter interest form">×</button>
      </header>

      {submitted ? <div className="fighter-signup-success">
        <div className="fighter-signup-success-mark">✓</div>
        <h3>You're on the list.</h3>
        <p>{message}</p>
        <button className="show-btn primary" type="button" onClick={onClose}>Close</button>
      </div> : <>
        {!codeValid&&!proceedWithoutCode ? <div className="fighter-signup-code-gate">
          {accessLoading||!access?<div className="state-card" role="status">Checking your registration access…</div>:AccessGate()}
          {message&&<div className="auth-message" role="status">{message}</div>}
        </div> : <>
        <div className="fighter-signup-trust">
          <span>⚔</span>
          <div><b>Stored securely in BuhurtOS</b><small>Your signup is private to authorized event organizers and platform administrators.</small></div>
        </div>

        <div className="fighter-signup-form">
          <div className="fighter-signup-grid">
            <label>Full name<input value={form.displayName} onChange={e=>setForm(v=>({...v,displayName:e.target.value}))} placeholder="Your name"/></label>
            <label>Email<input type="email" value={form.email} onChange={e=>setForm(v=>({...v,email:e.target.value}))} placeholder="you@example.com"/></label>
            <label>Phone<input inputMode="tel" value={form.phone} onChange={e=>setForm(v=>({...v,phone:e.target.value}))} placeholder="Optional"/></label>
            <label>Team / club<input value={form.teamName} onChange={e=>setForm(v=>({...v,teamName:e.target.value}))} placeholder="Team name or independent"/></label>
            <label>Years fighting<input inputMode="decimal" value={form.experienceYears} onChange={e=>setForm(v=>({...v,experienceYears:e.target.value}))} placeholder="0"/></label>
            <label>Armor status
              <select value={form.armorStatus} onChange={e=>setForm(v=>({...v,armorStatus:e.target.value}))}>
                <option>Full kit</option><option>Mostly complete</option><option>Borrowing / loaner needed</option><option>Still building kit</option><option>Not sure yet</option>
              </select>
            </label>
          </div>

          <fieldset className="fighter-category-picker">
            <legend>What do you want to fight?</legend>
            <div>{categories.map(category=><button type="button" key={category} className={selected.includes(category)?'selected':''} onClick={()=>toggle(category)}>{category}</button>)}</div>
          </fieldset>

          <label>Attendance / travel notes<textarea rows={3} value={form.attendanceNotes} onChange={e=>setForm(v=>({...v,attendanceNotes:e.target.value}))} placeholder="Which days can you attend? Any travel or scheduling details?"/></label>
          <label>Emergency contact<textarea rows={2} value={form.emergencyContact} onChange={e=>setForm(v=>({...v,emergencyContact:e.target.value}))} placeholder="Name and phone number"/></label>
          <label>Anything else organizers should know?<textarea rows={3} value={form.additionalNotes} onChange={e=>setForm(v=>({...v,additionalNotes:e.target.value}))} placeholder="Questions, medical/logistical notes you choose to share, team details, etc."/></label>

          <label className="fighter-signup-consent"><input type="checkbox" checked={form.consent} onChange={e=>setForm(v=>({...v,consent:e.target.checked}))}/><span>I agree to submit this information to the event organizers through BuhurtOS.</span></label>

          {message&&<div className="auth-message">{message}</div>}
        </div>

        <footer className="fighter-signup-footer">
          <span>This is an event signup request, not final competition clearance or registration approval.</span>
          <button className="show-btn primary" type="button" disabled={busy||!valid} onClick={submit}>{busy?'Submitting…':'Submit fighter signup'}</button>
        </footer>
        </>}
      </>}
    </section>
  </div>;
}
