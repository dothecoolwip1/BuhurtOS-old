import { publicSupabase } from './supabase';
import { loadPublicTeamDirectory, type PublicDirectoryTeam } from './teamDirectory';

export type PublicOrganizationSummary = {
  key:string;
  id?:string;
  shortName:string;
  name:string;
  region:string;
  kind:string;
  description:string;
  websiteUrl?:string;
  teamCount:number;
  rosterCount:number;
  countries:number;
};

export type PublicEventSummary = {
  id:string;
  organizationId:string;
  name:string;
  venue:string;
  startsAt:string;
  endsAt:string;
  organizerName?:string;
  eventType:string;
  standingsMode:string;
  status:string;
  timezone:string;
  publicDescription?:string;
};

export type PublicFighterSummary = {
  id:string;
  displayName:string;
  nickname?:string;
  avatarPath?:string;
  bio?:string;
  publicRegion?:string;
  verified:boolean;
};

const orgInfo:Record<string,{name:string;description:string;websiteUrl?:string;kind:string}> = {
  BI:{
    name:'Buhurt International',
    kind:'International federation',
    websiteUrl:'https://www.buhurtinternational.com/',
    description:'An international Buhurt organization supporting tournaments, official scoring, rules and policies, teams, rankings and the continued development of the sport.'
  },
  HACSA:{
    name:'Historical Armored Combat Sports Association',
    kind:'National organization',
    websiteUrl:'https://www.hacsacanada.com/',
    description:'A Canadian armoured combat league that supports teams, standardized rulesets, tournaments, demonstrations, insurance and international participation.'
  },
  Reavers:{
    name:'Red Deer Reavers',
    kind:'Local organization / team',
    description:'A Central Alberta armored combat team based around Red Deer, building the local Buhurt community through training, competition, demonstrations and newcomer development.'
  }
};

function slug(value:string){return value.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')}

export async function loadPublicOrganizations():Promise<PublicOrganizationSummary[]>{
  const teams=await loadPublicTeamDirectory();
  const grouped=new Map<string,PublicDirectoryTeam[]>();
  for(const team of teams){
    const key=team.organizationShortName||team.organizationName;
    grouped.set(key,[...(grouped.get(key)??[]),team]);
  }
  const rows:PublicOrganizationSummary[]=[];
  for(const [shortName,orgTeams] of grouped){
    const info=orgInfo[shortName];
    const rosterCounts=await Promise.all(orgTeams.slice(0,80).map(async team=>{
      try{
        if(!publicSupabase)return 0;
        const {data,error}=await publicSupabase.rpc('public_team_roster',{p_team_id:team.id});
        if(error)return 0;
        return (data??[]).length;
      }catch{return 0}
    }));
    rows.push({
      key:slug(shortName),
      id:orgTeams[0]?.organizationId,
      shortName,
      name:info?.name??orgTeams[0]?.organizationName??shortName,
      region:orgTeams[0]?.organizationShortName==='BI'?'International':(orgTeams[0]?.countryName??'Global'),
      kind:info?.kind??'Buhurt organization',
      description:info?.description??'A Buhurt organization represented in the public team directory.',
      websiteUrl:info?.websiteUrl,
      teamCount:orgTeams.length,
      rosterCount:rosterCounts.reduce((a,b)=>a+b,0),
      countries:new Set(orgTeams.map(t=>t.countryCode).filter(Boolean)).size
    });
  }
  if(!rows.some(row=>row.shortName==='Reavers')){
    rows.push({key:'reavers',shortName:'Reavers',name:orgInfo.Reavers.name,region:'Red Deer, Alberta, Canada',kind:orgInfo.Reavers.kind,description:orgInfo.Reavers.description,teamCount:1,rosterCount:0,countries:1});
  }
  return rows.sort((a,b)=>{
    const order=['BI','HACSA','Reavers'];
    const ai=order.indexOf(a.shortName),bi=order.indexOf(b.shortName);
    if(ai>=0||bi>=0)return (ai<0?99:ai)-(bi<0?99:bi);
    return a.name.localeCompare(b.name);
  });
}

export async function loadPublicOrganization(key:string):Promise<{organization:PublicOrganizationSummary;teams:PublicDirectoryTeam[]}|undefined>{
  const [organizations,teams]=await Promise.all([loadPublicOrganizations(),loadPublicTeamDirectory()]);
  const organization=organizations.find(org=>org.key===key||slug(org.shortName)===key||slug(org.name)===key);
  if(!organization)return undefined;
  const matching=teams.filter(team=>team.organizationShortName===organization.shortName || (organization.shortName==='Reavers'&&team.name==='Red Deer Reavers'));
  return {organization,teams:matching};
}

export async function loadPublicEvents():Promise<PublicEventSummary[]>{
  if(!publicSupabase)return [];
  const {data,error}=await publicSupabase.from('events')
    .select('id,organization_id,name,venue,starts_at,ends_at,organizer_name,event_type,standings_mode,status,timezone,public_description')
    .in('status',['published','live','completed','cancelled'])
    .not('published_at','is',null)
    .order('starts_at',{ascending:true});
  if(error)throw error;
  return (data??[]).map((row:any)=>({
    id:row.id,organizationId:row.organization_id,name:row.name,venue:row.venue,startsAt:row.starts_at,endsAt:row.ends_at,
    organizerName:row.organizer_name??undefined,eventType:row.event_type,standingsMode:row.standings_mode,status:row.status,
    timezone:row.timezone,publicDescription:row.public_description??undefined
  }));
}

export async function loadPublicFighters():Promise<PublicFighterSummary[]>{
  if(!publicSupabase)return [];
  const {data,error}=await publicSupabase.from('fighter_identities')
    .select('id,display_name,nickname,avatar_path,bio,public_region,verified_at')
    .eq('profile_visibility','public')
    .is('deleted_at',null)
    .is('merged_into_identity_id',null)
    .order('display_name');
  if(error)throw error;
  return (data??[]).map((row:any)=>({
    id:row.id,displayName:row.display_name,nickname:row.nickname??undefined,avatarPath:row.avatar_path??undefined,
    bio:row.bio??undefined,publicRegion:row.public_region??undefined,verified:Boolean(row.verified_at)
  }));
}

export async function loadPublicFighter(id:string):Promise<PublicFighterSummary|undefined>{
  const rows=await loadPublicFighters();
  return rows.find(row=>row.id===id);
}
