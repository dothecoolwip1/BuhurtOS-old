import {useEffect,useState} from 'react';
import {Link,useParams} from 'react-router-dom';
import {Avatar,Panel,Pill} from '../components/ShowcaseUI';
import {ListCrumbs} from '../components/chrome';
import {FighterAvatar} from '../components/FighterAvatar';
import {loadPublicFighter,type PublicFighterSummary} from '../lib/publicDirectory';

const initials=(n:string)=>n.split(/\s+/).filter(Boolean).slice(0,2).map(x=>x[0]?.toUpperCase()).join('');

export function FighterProfilePage(){
 const {fighterId=''}=useParams();
 const [fighter,setFighter]=useState<PublicFighterSummary>();
 const [loading,setLoading]=useState(true);
 const [error,setError]=useState('');
 useEffect(()=>{let active=true;loadPublicFighter(fighterId).then(row=>{if(active)setFighter(row)}).catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load this fighter profile.')}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[fighterId]);
 if(loading)return <div className="state-card">Loading fighter profile…</div>;
 if(error)return <div className="state-card"><strong>Unable to load fighter</strong><p>{error}</p><Link className="show-btn secondary" to="/fighters">Back to fighters</Link></div>;
 if(!fighter)return <div className="state-card"><h2>Fighter profile not found</h2><p>This may be a source-only roster name that has not yet been linked to a public BuhurtOS identity.</p><Link className="show-btn secondary" to="/fighters">Back to fighters</Link></div>;
 return <>
  <ListCrumbs list="/fighters" label="Fighters" current={fighter.displayName}/>
  <div className="show-profile-hero fighter steel">
   <FighterAvatar identityId={fighter.id} hasPhoto={Boolean(fighter.avatarPath)} alt={fighter.displayName} className="show-fighter-avatar-image profile" fallback={<Avatar initials={initials(fighter.displayName)} tone="steel" size="xl"/>}/>
   <div className="grow"><span className="eyebrow">PUBLIC FIGHTER PROFILE</span><h1>{fighter.nickname?fighter.displayName+' “'+fighter.nickname+'”':fighter.displayName}</h1><p>{fighter.publicRegion||'Region not published'}</p><div className="show-inline-pills">{fighter.verified?<Pill tone="green">Verified identity</Pill>:<Pill>Public profile</Pill>}</div></div>
  </div>
  <div className="show-two-col wide-left">
   <div className="show-stack">
    <Panel title="About"><p className="show-long-copy">{fighter.bio||'This fighter has not published a biography yet.'}</p></Panel>
    <Panel title="Competition history"><div className="source-empty-state"><strong>No invented stats.</strong><p>Categories, match record, podiums and ranking history will appear here only when linked to finalized public BuhurtOS results or verified source records.</p></div></Panel>
   </div>
   <div className="show-stack">
    <Panel title="Profile"><div className="show-detail-rows"><div><span>Name</span><b>{fighter.displayName}</b></div>{fighter.nickname?<div><span>Nickname</span><b>{fighter.nickname}</b></div>:null}<div><span>Region</span><b>{fighter.publicRegion||'Not published'}</b></div><div><span>Status</span><b>{fighter.verified?'Verified':'Public'}</b></div></div></Panel>
    <Panel title="What do they fight?"><div className="show-explain-card"><span>?</span><div><b>Competition categories</b><p>Weapon and melee categories such as longsword, sword & buckler, polearm, 5v5 and 12v12 will populate from verified competition history instead of being guessed.</p></div><Link to="/rules">Learn about categories</Link></div></Panel>
   </div>
  </div>
 </>;
}