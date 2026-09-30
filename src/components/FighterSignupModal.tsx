import {useEffect} from 'react';

const FORM_URL='https://docs.google.com/forms/d/e/1FAIpQLSdzQhr-IxnHiCW3GPysMn2Vj4TrayXsuSc1ucusJwe2w3tJtg/viewform';
const EMBED_URL=FORM_URL+'?embedded=true';

export function FighterSignupModal({open,onClose,eventName}:{open:boolean;onClose:()=>void;eventName:string}){
  useEffect(()=>{
    if(!open)return;
    const onKey=(event:KeyboardEvent)=>{if(event.key==='Escape')onClose()};
    document.addEventListener('keydown',onKey);
    const previous=document.body.style.overflow;
    document.body.style.overflow='hidden';
    return()=>{document.removeEventListener('keydown',onKey);document.body.style.overflow=previous};
  },[open,onClose]);

  if(!open)return null;

  return <div className="fighter-signup-backdrop" role="presentation" onMouseDown={event=>{if(event.currentTarget===event.target)onClose()}}>
    <section className="fighter-signup-modal" role="dialog" aria-modal="true" aria-labelledby="fighter-signup-title">
      <header className="fighter-signup-hero">
        <div>
          <span className="eyebrow">FIGHTER REGISTRATION</span>
          <h2 id="fighter-signup-title">Sign up for {eventName}</h2>
          <p>Complete the official fighter registration form without leaving BuhurtOS.</p>
        </div>
        <button className="fighter-signup-close" type="button" onClick={onClose} aria-label="Close fighter signup">×</button>
      </header>

      <div className="fighter-signup-trust">
        <span>⚔</span>
        <div><b>Official signup form</b><small>Your response is submitted through the organizers' existing Google Form.</small></div>
      </div>

      <div className="fighter-signup-frame">
        <iframe
          src={EMBED_URL}
          title={eventName+' fighter signup'}
          loading="lazy"
          referrerPolicy="strict-origin-when-cross-origin"
        />
      </div>

      <footer className="fighter-signup-footer">
        <span>If the form does not load inside the popup, open the original form directly.</span>
        <a className="show-btn secondary" href={FORM_URL} target="_blank" rel="noopener noreferrer">Open form ↗</a>
      </footer>
    </section>
  </div>;
}
