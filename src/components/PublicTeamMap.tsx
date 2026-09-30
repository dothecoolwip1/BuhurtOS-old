import {useEffect,useRef,useState} from 'react';
import type {PublicDirectoryTeam} from '../lib/teamDirectory';

type Props={teams:PublicDirectoryTeam[]};

function escapeHtml(value:string){
 return value.replace(/[&<>"']/g,ch=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch]||ch));
}

let leafletPromise:Promise<any>|null=null;
let clusterPromise:Promise<any>|null=null;

function loadLeaflet(){
 if((window as any).L)return Promise.resolve((window as any).L);
 if(leafletPromise)return leafletPromise;
 leafletPromise=new Promise((resolve,reject)=>{
   if(!document.querySelector('link[data-buhurtos-leaflet]')){
     const link=document.createElement('link');link.rel='stylesheet';link.href='https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';link.dataset.buhurtosLeaflet='true';document.head.appendChild(link);
   }
   const existing=document.querySelector('script[data-buhurtos-leaflet]') as HTMLScriptElement|null;
   if(existing){
     if((window as any).L){resolve((window as any).L);return;}
     existing.addEventListener('load',()=>resolve((window as any).L),{once:true});
     existing.addEventListener('error',reject,{once:true});
     return;
   }
   const script=document.createElement('script');script.src='https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';script.async=true;script.dataset.buhurtosLeaflet='true';
   script.onload=()=>resolve((window as any).L);script.onerror=reject;document.head.appendChild(script);
 });
 return leafletPromise;
}

async function loadMarkerCluster(){
 const L=await loadLeaflet();
 if(L.markerClusterGroup)return L;
 if(clusterPromise)return clusterPromise;
 clusterPromise=new Promise((resolve,reject)=>{
   for(const [href,key] of [
     ['https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.css','cluster'],
     ['https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.Default.css','cluster-default']
   ]){
     if(!document.querySelector('link[data-buhurtos-'+key+']')){
       const link=document.createElement('link');link.rel='stylesheet';link.href=href;link.setAttribute('data-buhurtos-'+key,'true');document.head.appendChild(link);
     }
   }
   const existing=document.querySelector('script[data-buhurtos-cluster]') as HTMLScriptElement|null;
   if(existing){
     if(L.markerClusterGroup){resolve(L);return;}
     existing.addEventListener('load',()=>resolve((window as any).L),{once:true});
     existing.addEventListener('error',reject,{once:true});
     return;
   }
   const script=document.createElement('script');script.src='https://unpkg.com/leaflet.markercluster@1.5.3/dist/leaflet.markercluster.js';script.async=true;script.dataset.buhurtosCluster='true';
   script.onload=()=>resolve((window as any).L);script.onerror=reject;document.head.appendChild(script);
 });
 return clusterPromise;
}

export function PublicTeamMap({teams}:Props){
 const host=useRef<HTMLDivElement|null>(null);const [failed,setFailed]=useState(false);const [ready,setReady]=useState(false);
 useEffect(()=>{
   if(!host.current)return;
   if(!('IntersectionObserver' in window)){setReady(true);return;}
   const observer=new IntersectionObserver(entries=>{
     if(entries.some(entry=>entry.isIntersecting)){setReady(true);observer.disconnect();}
   },{rootMargin:'300px'});
   observer.observe(host.current);
   return()=>observer.disconnect();
 },[]);
 useEffect(()=>{
   if(!ready)return;
   let disposed=false;let map:any;
   setFailed(false);
   loadMarkerCluster().then(L=>{
     if(disposed||!host.current)return;
     map=L.map(host.current,{worldCopyJump:true,minZoom:2,maxZoom:18,zoomControl:true}).setView([25,0],2);
     L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{
       maxZoom:18,attribution:'&copy; OpenStreetMap contributors'
     }).addTo(map);

     const clusters=L.markerClusterGroup({
       showCoverageOnHover:false,
       zoomToBoundsOnClick:true,
       spiderfyOnMaxZoom:true,
       removeOutsideVisibleBounds:true,
       chunkedLoading:true,
       maxClusterRadius:56,
       disableClusteringAtZoom:12,
       iconCreateFunction:(cluster:any)=>{
         const count=cluster.getChildCount();
         const size=count<10?36:count<50?44:52;
         return L.divIcon({
           html:'<span>'+count+'</span>',
           className:'buhurt-cluster-icon',
           iconSize:L.point(size,size)
         });
       }
     });

     const bounds:any[]=[];
     for(const team of teams){
       if(team.latitude==null||team.longitude==null)continue;
       const marker=L.marker([team.latitude,team.longitude],{
         title:team.name,
         icon:L.divIcon({
           className:'buhurt-team-marker',
           html:'<span aria-hidden="true"></span>',
           iconSize:L.point(20,20),
           iconAnchor:L.point(10,10),
           popupAnchor:L.point(0,-8)
         })
       });
       const location=[team.location,team.adminAreaName,team.countryName].filter(x=>x&&!x.includes('pending')).join(' · ');
       const teamUrl=window.location.pathname+'?go='+encodeURIComponent('/teams/'+team.slug);\n       marker.bindPopup('<div class="buhurt-map-popup"><strong>'+escapeHtml(team.name)+'</strong><span>'+escapeHtml(location)+'</span><a href="'+escapeHtml(teamUrl)+'">Open team profile →</a></div>');
       clusters.addLayer(marker);
       bounds.push([team.latitude,team.longitude]);
     }
     map.addLayer(clusters);

     if(bounds.length>1)map.fitBounds(bounds,{padding:[26,26],maxZoom:5});
     else if(bounds.length===1)map.setView(bounds[0],6);
     setTimeout(()=>map?.invalidateSize(),0);
   }).catch(()=>{if(!disposed)setFailed(true)});
   return()=>{disposed=true;if(map)map.remove()};
 },[teams,ready]);

 if(failed)return <div className="state-card">The interactive map could not load. Team locations are still available in the directory.</div>;
 return <div className="team-leaflet-map" ref={host} aria-label="Interactive world map of public Buhurt teams with clustered markers">{!ready&&<div className="map-load-placeholder">Map loads when visible</div>}</div>;
}
