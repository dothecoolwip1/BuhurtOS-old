import {useEffect,useMemo,useState} from 'react';
import {Link} from 'react-router-dom';
import {Avatar,PageHeader,Pill} from '../components/ShowcaseUI';
import {loadPublicFighters,type PublicFighterSummary} from '../lib/publicDirectory';

const initials=(n:string)=>n.split(/\s+/).filter(Boolean).slice(0,2).map(x=>x[0]?.toUpperCase()).join('');

export function FightersPage(){
 const [query,setQuery]=useState('');
 const [fighters,setFighters]=useState<PublicFighterSummary[]>([]);
 const [loading,setLoading]=useState(true);
 useEffect(()=>{let active=true;loadPublicFighters().then(rows=>{if(active)setFighters(rows)}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[]);
 const filtered=useMemo(()=>{const q=query.trim().toLowerCase();return fighters.filter(f=>!q||[f.displayName,f.nickname??'',f.publicRegion??'',f.bio??''].some(v=>v.toLowerCase().includes(q)))},[fighters,query]);
 return <>
  <PageHeader eyebrow="PUBLIC ATHLETE DIRECTORY" title="Fighters" description="Real public BuhurtOS fighter identities only. No sample athletes or invented records." actions={<label className="show-search"><span>⌕</span><input aria-label="Search fighters" value={query} onChange={e=>setQuery(e.target.value)} placeholder="Search fighters"/></label>}/>
  {loading?<div className="state-card">Loading public fighter identities…</div>:filtered.length===0?<div className="state-card"><strong>No public fighter profiles yet.</strong><p>Source roster names can still appear on team pages. Full profiles appear here once a fighter identity is created and made public.</p></div>:<div className="show-fighter-grid">{filtered.map(f=><Link to={'/fighters/'+f.id} className="show-fighter-card" key={f.id}><div className="show-fighter-photo steel">{f.avatarPath?<img className="show-fighter-avatar-image" src={f.avatarPath} alt={f.displayName}/>:<Avatar initials={initials(f.displayName)} tone="steel" size="xl"/>}{f.verified?<span className="show-rank-badge">✓</span>:null}</div><div><span className="eyebrow">{f.publicRegion||'PUBLIC FIGHTER'}</span><h2>{f.nickname?f.displayName+' “'+f.nickname+'”':f.displayName}</h2><p>{f.bio||'Public competition profile.'}</p><div className="show-tag-row">{f.verified?<Pill tone="green">Verified identity</Pill>:<Pill>Public profile</Pill>}</div></div></Link>)}</div>}
 </>;
}