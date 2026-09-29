import { readFile, mkdir, writeFile, rm } from 'node:fs/promises';

const input=JSON.parse(await readFile('src/data/biTeamCollection.json','utf8'));
const outDir='scripts/generated/bi-live-import';
await rm(outDir,{recursive:true,force:true}); await mkdir(outDir,{recursive:true});

const iso={
'United States':'US','USA':'US','United Kingdom':'GB','UK':'GB','Australia':'AU','Canada':'CA','New Zealand':'NZ','France':'FR','Germany':'DE','Spain':'ES','Italy':'IT','Belgium':'BE','Denmark':'DK','Czech Republic':'CZ','Czechia':'CZ','Norway':'NO','Hungary':'HU','Poland':'PL','Slovakia':'SK','Croatia':'HR','Portugal':'PT','Romania':'RO','Moldova':'MD','Switzerland':'CH','Greece':'GR','Argentina':'AR','Brazil':'BR','Mexico':'MX','Chile':'CL','Colombia':'CO','Peru':'PE','Costa Rica':'CR','Israel':'IL','Ukraine':'UA','Sweden':'SE','Finland':'FI','Netherlands':'NL','Austria':'AT','Ireland':'IE','Lithuania':'LT','Latvia':'LV','Estonia':'EE','Serbia':'RS','Slovenia':'SI','Bulgaria':'BG','Turkey':'TR','South Africa':'ZA','Japan':'JP','South Korea':'KR','Iceland':'IS'
};
const continentByCountry={
US:['NA','North America'],CA:['NA','North America'],MX:['NA','North America'],CR:['NA','North America'],
AR:['SA','South America'],BR:['SA','South America'],CL:['SA','South America'],CO:['SA','South America'],PE:['SA','South America'],
AU:['OC','Oceania'],NZ:['OC','Oceania'],
JP:['AS','Asia'],KR:['AS','Asia'],IL:['AS','Asia'],TR:['AS','Asia'],
ZA:['AF','Africa']
};
function sql(v){if(v===null||v===undefined||v==='')return 'NULL';return "'"+String(v).replaceAll("'","''")+"'";}
function jsql(v){return sql(JSON.stringify(v))+'::jsonb';}
function text(v){return String(v??'').replace(/<br\s*\/?\s*>/gi,'\n').replace(/<\/p>/gi,'\n').replace(/<[^>]+>/g,' ').replace(/&nbsp;/g,' ').replace(/&amp;/g,'&').replace(/&quot;/g,'"').replace(/&#39;/g,"'").replace(/\s+/g,' ').trim();}
function slugOf(d){const p=d['link-team-registration-correct-title'];if(typeof p==='string'&&p.startsWith('/team/'))return decodeURIComponent(p.slice(6));return null;}
function logoUrl(v){if(!v)return null;const m=String(v).match(/^wix:image:\/\/v1\/([^/]+)\//);return m?('https://static.wixstatic.com/media/'+m[1]):(/^https?:/.test(v)?v:null);}
function members(d){
 const arr=Object.entries(d).filter(([k,v])=>/^member\d+$/.test(k)&&typeof v==='string'&&v.trim()).sort((a,b)=>Number(a[0].slice(6))-Number(b[0].slice(6))).map(([,v])=>v.trim());
 const cap=(d.teamCaptainName||'').trim(); if(cap&&!arr.some(x=>x.toLowerCase()===cap.toLowerCase()))arr.unshift(cap);
 const seen=new Set(); return arr.filter(x=>{const k=x.toLowerCase();if(seen.has(k))return false;seen.add(k);return true;});
}
function geo(d){
 const cc=iso[String(d.country||'').trim()]||null;
 if(cc&&continentByCountry[cc])return {cc,continentCode:continentByCountry[cc][0],continentName:continentByCountry[cc][1]};
 if(d.conference==='North America')return {cc,continentCode:'NA',continentName:'North America'};
 if(d.conference==='Europe')return {cc,continentCode:'EU',continentName:'Europe'};
 if(d.conference==='APAC')return {cc,continentCode:(cc==='AU'||cc==='NZ')?'OC':'AS',continentName:(cc==='AU'||cc==='NZ')?'Oceania':'Asia Pacific'};
 return {cc,continentCode:null,continentName:d.conference||null};
}

const bySlug=new Map(), missingSlug=[];
for(const item of input.items||[]){
 const d=item.data||{}, slug=slugOf(d);
 if(!slug){missingSlug.push({id:item.id,teamName:d.teamName||null});continue;}
 const prior=bySlug.get(slug);
 const stamp=d._updatedDate?.$date||d._createdDate?.$date||'';
 if(!prior||stamp>(prior.data._updatedDate?.$date||prior.data._createdDate?.$date||''))bySlug.set(slug,item);
}
const records=[...bySlug.entries()].sort((a,b)=>a[0].localeCompare(b[0]));
const CHUNK=35, files=[];
for(let start=0;start<records.length;start+=CHUNK){
 const chunk=records.slice(start,start+CHUNK); const lines=['begin;'];
 for(const [slug,item] of chunk){
   const d=item.data||{}, roster=members(d), g=geo(d), logo=logoUrl(d.teamLogo);
   const payload={
     biCollectionId:item.id, teamName:d.teamName||null, club:d.club||null, gender:d.gender||null,
     captain:d.teamCaptainName||null, conference:d.conference||null, country:d.country||null, city:d.city||null,
     teamInfo:text(d.teamInfo), trainingInfo:text(d.trainingInfo), trainingLocation:d.trainingLocation||null,
     websiteFacebookUrl:d.websiteFacebookUrl||null, teamEmail:d.teamEmail||null, teamLogo:d.teamLogo||null, logoUrl:logo,
     rank5v5:d.rank5Vs5??null, averagePoints5v5:d['5Vs5AveragePoints']??null, points5v5:d.points5Vs5??null,
     rank12v12:d.rank12Vs12??null, points12v12:d['12V12Points']??null,
     tournamentsJoined:Array.isArray(d.tournamentsJoined)?d.tournamentsJoined:[], eventsHistory:d.eventsHistory||{},
     members:roster, sourceCreatedAt:d._createdDate?.$date||null, sourceUpdatedAt:d._updatedDate?.$date||null,
     sourceSnapshotAt:input.generatedAt
   };
   lines.push(`do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key=${sql(slug)} limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug=${sql('bi-'+slug)} and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),${sql(d.teamName||slug)},${sql(d.city)},true,'active','public',${sql('bi-'+slug)},${sql(g.continentCode)},${sql(g.continentName)},${sql(g.cc)},${sql(d.country)},${sql(d.teamEmail)},${sql(d.websiteFacebookUrl)},${sql(logo)},${sql(text(d.teamInfo))})
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams',${sql(slug)},${sql('https://www.buhurtinternational.com/team/'+encodeURIComponent(slug))},${sql(d.teamName||slug)},${sql(d.city)},${sql(d.teamEmail)},${sql(d.websiteFacebookUrl)},20,${jsql(payload)},now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce(${sql(d.teamName)},t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(${sql(d.city)},t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce(${sql(g.continentCode)},t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce(${sql(g.continentName)},t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce(${sql(g.cc)},t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce(${sql(d.country)},t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,${sql(d.teamEmail)}),
 website_url=coalesce(t.website_url,${sql(d.websiteFacebookUrl)}),
 logo_path=coalesce(t.logo_path,${sql(logo)}),
 public_description=coalesce(t.public_description,${sql(text(d.teamInfo))}),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
${roster.map(name=>`insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,${sql(name)},${sql((d.teamCaptainName||'').trim().toLowerCase()===name.toLowerCase()?'captain':'fighter')},'bi_teams',${sql('https://www.buhurtinternational.com/team/'+encodeURIComponent(slug))},${sql(slug)},now());`).join('\n')}
end $$;`);
 }
 lines.push('commit;');
 const file=`${outDir}/chunk-${String(files.length+1).padStart(2,'0')}.sql`; await writeFile(file,lines.join('\n')+'\n','utf8'); files.push(file);
}
const summary={generatedAt:new Date().toISOString(),sourceGeneratedAt:input.generatedAt,totalCollectionItems:(input.items||[]).length,uniqueLinkedTeams:records.length,missingSlug,chunkFiles:files,rosterEntries:records.reduce((n,[,i])=>n+members(i.data||{}).length,0),withLogo:records.filter(([,i])=>!!logoUrl(i.data?.teamLogo)).length,withCity:records.filter(([,i])=>!!i.data?.city).length,withCountry:records.filter(([,i])=>!!i.data?.country).length,withCaptain:records.filter(([,i])=>!!i.data?.teamCaptainName).length};
await writeFile(`${outDir}/summary.json`,JSON.stringify(summary,null,2)+'\n','utf8');
console.log(JSON.stringify(summary,null,2));
