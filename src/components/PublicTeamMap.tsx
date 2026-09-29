import {useEffect,useRef,useState} from 'react';
import type {PublicDirectoryTeam} from '../lib/teamDirectory';

type Props={teams:PublicDirectoryTeam[]};

function escapeHtml(value:string){
 return value.replace(/[&<>"']/g,ch=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch]||ch));
}

let leafletPromise:Promise<any>|null=null;
function loadLeaflet(){
 if((window as any).L)return Promise.resolve((window as any).L);
 if(leafletPromise)return leafletPromise;
 leafletPromise=new Promise((resolve,reject)=>{
   if(!document.querySelector('link[data-buhurtos-leaflet]')){
     const link=document.createElement('link');link.rel='stylesheet';link.href='https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';link.dataset.buhurtosLeaflet='true';document.head.appendChild(link);
   }
   const existing=document.querySelector('script[data-buhurtos-leaflet]') as HTMLScriptElement|null;
   if(existing){
     existing.addEventListener('load',()=>resolve((window as any).L),{once:true});
     existing.addEventListener('error',reject,{once:true});
     return;
   }
   const script=document.createElement('script');script.src='https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';script.async=true;script.dataset.buhurtosLeaflet='true';
   script.onload=()=>resolve((window as any).L);script.onerror=reject;document.head.appendChild(script);
 });
 return leafletPromise;
}

export function PublicTeamMap({teams}:Props){
 const host=useRef<HTMLDivElement|null>(null);const [failed,setFailed]=useState(false);
 useEffect(()=>{
   let disposed=false;let map:any;
   loadLeaflet().then(L=>{
     if(disposed||!host.current)return;
     map=L.map(host.current,{worldCopyJump:true,minZoom:2}).setView([25,0],2);
     L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{
       maxZoom:18,attribution:'&copy; OpenStreetMap contributors'
     }).addTo(map);
     const bounds:any[]=[];
     for(const team of teams){
       if(team.latitude==null||team.longitude==null)continue;
       const marker=L.circleMarker([team.latitude,team.longitude],{
         radius:7,weight:2,color:'#0b1015',fillColor:'#ff8a1f',fillOpacity:.95
       }).addTo(map);
       const location=[team.location,team.adminAreaName,team.countryName].filter(x=>x&&!x.includes('pending')).join(' · ');
       marker.bindPopup('<div class="buhurt-map-popup"><strong>'+escapeHtml(team.name)+'</strong><span>'+escapeHtml(location)+'</span><a href="#/teams/'+encodeURIComponent(team.slug)+'">Open team profile →</a></div>');
       bounds.push([team.latitude,team.longitude]);
     }
     if(bounds.length>1)map.fitBounds(bounds,{padding:[26,26],maxZoom:5});
     else if(bounds.length===1)map.setView(bounds[0],6);
     setTimeout(()=>map?.invalidateSize(),0);
   }).catch(()=>{if(!disposed)setFailed(true)});
   return()=>{disposed=true;if(map)map.remove()};
 },[teams]);
 if(failed)return <div className="state-card">The interactive map could not load. Team locations are still available in the directory.</div>;
 return <div className="team-leaflet-map" ref={host} aria-label="Interactive world map of public Buhurt teams"/>;
}
