import { readFile, writeFile, mkdir, access, rm } from 'node:fs/promises';

const source=JSON.parse(await readFile('src/data/biTeamCollection.json','utf8'));
const cachePath='src/data/biTeamGeocodes.json';
let cache={generatedAt:null,records:{}};
try{await access(cachePath);cache=JSON.parse(await readFile(cachePath,'utf8'));}catch{}
cache.records=cache.records||{};

const sleep=ms=>new Promise(r=>setTimeout(r,ms));
function slugOf(d){const p=d['link-team-registration-correct-title'];return typeof p==='string'&&p.startsWith('/team/')?decodeURIComponent(p.slice(6)):null;}
function sql(v){if(v===null||v===undefined||v==='')return 'NULL';return "'"+String(v).replaceAll("'","''")+"'";}
const seen=new Set(), todo=[];
for(const item of source.items||[]){
 const d=item.data||{},slug=slugOf(d),city=String(d.city||'').trim(),country=String(d.country||'').trim();
 if(!slug||!city||!country)continue;
 const key=(city+'|'+country).toLowerCase();
 if(seen.has(key))continue;seen.add(key);
 if(!cache.records[key])todo.push({key,city,country});
}
console.log('Unique BI locations:',seen.size,'to geocode:',todo.length);
let done=0;
for(const x of todo){
 const q=encodeURIComponent(x.city+', '+x.country);
 try{
   const res=await fetch('https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&addressdetails=1&q='+q,{
     headers:{'User-Agent':'BuhurtOS/1.0 (+https://dothecoolwip1.github.io/BuhurtOS/)','Accept':'application/json'}
   });
   const rows=await res.json(); const hit=rows[0];
   if(hit){
     const a=hit.address||{};
     const admin=a.state||a.region||a.province||a.state_district||a.county||null;
     const isoKey=Object.keys(a).find(k=>/^ISO3166-2-lvl/i.test(k));
     cache.records[x.key]={query:x.city+', '+x.country,lat:Number(hit.lat),lon:Number(hit.lon),displayName:hit.display_name,
       adminArea:admin,adminCode:isoKey?a[isoKey]:null,countryCode:a.country_code?String(a.country_code).toUpperCase():null,verifiedAt:new Date().toISOString()};
   }else cache.records[x.key]={query:x.city+', '+x.country,notFound:true,verifiedAt:new Date().toISOString()};
 }catch(e){cache.records[x.key]={query:x.city+', '+x.country,error:String(e),verifiedAt:new Date().toISOString()};}
 done++; if(done%25===0)console.log('Geocoded',done,'of',todo.length);
 await sleep(1100);
}
cache.generatedAt=new Date().toISOString();
await writeFile(cachePath,JSON.stringify(cache,null,2)+'\n','utf8');

const updates=[];
for(const item of source.items||[]){
 const d=item.data||{},slug=slugOf(d),city=String(d.city||'').trim(),country=String(d.country||'').trim(); if(!slug||!city||!country)continue;
 const g=cache.records[(city+'|'+country).toLowerCase()]; if(!g||g.notFound||g.error||!Number.isFinite(g.lat)||!Number.isFinite(g.lon))continue;
 updates.push({slug,lat:g.lat,lon:g.lon,adminArea:g.adminArea,adminCode:g.adminCode,countryCode:g.countryCode});
}
const out='scripts/generated/bi-geocodes';await rm(out,{recursive:true,force:true});await mkdir(out,{recursive:true});
const CHUNK=60,files=[];
for(let i=0;i<updates.length;i+=CHUNK){
 const rows=updates.slice(i,i+CHUNK), lines=['begin;'];
 for(const u of rows)lines.push(`update public.teams t set
 public_latitude=coalesce(t.public_latitude,${u.lat}),
 public_longitude=coalesce(t.public_longitude,${u.lon}),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),${sql(u.adminArea)}),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),${sql(u.adminCode)}),
 country_code=coalesce(nullif(t.country_code,''),${sql(u.countryCode)}),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key=${sql(u.slug)} limit 1);\n`);
 lines.push('commit;'); const file=`${out}/chunk-${String(files.length+1).padStart(2,'0')}.sql`;await writeFile(file,lines.join('\n'),'utf8');files.push(file);
}
const summary={generatedAt:cache.generatedAt,uniqueLocations:seen.size,successfulLocations:Object.values(cache.records).filter(x=>!x.notFound&&!x.error&&Number.isFinite(x.lat)).length,
notFound:Object.values(cache.records).filter(x=>x.notFound).length,errors:Object.values(cache.records).filter(x=>x.error).length,teamCoordinateUpdates:updates.length,chunkFiles:files};
await writeFile(out+'/summary.json',JSON.stringify(summary,null,2)+'\n','utf8');
console.log(JSON.stringify(summary,null,2));
