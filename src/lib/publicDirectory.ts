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
  publicLinks?:Record<string,unknown>;
  registrationOpen?:boolean;
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
  return rows.sort((a,b)=>{
    const order=['BI','HACSA'];
    const ai=order.indexOf(a.shortName),bi=order.indexOf(b.shortName);
    if(ai>=0||bi>=0)return (ai<0?99:ai)-(bi<0?99:bi);
    return a.name.localeCompare(b.name);
  });
}

export async function loadPublicOrganization(key:string):Promise<{organization:PublicOrganizationSummary;teams:PublicDirectoryTeam[]}|undefined>{
  const [organizations,teams]=await Promise.all([loadPublicOrganizations(),loadPublicTeamDirectory()]);
  const organization=organizations.find(org=>org.key===key||slug(org.shortName)===key||slug(org.name)===key);
  if(!organization)return undefined;
  const matching=teams.filter(team=>team.organizationShortName===organization.shortName);
  return {organization,teams:matching};
}

export async function loadPublicEvents():Promise<PublicEventSummary[]>{
  if(!publicSupabase)return [];
  const {data,error}=await publicSupabase.from('events')
    .select('id,organization_id,name,venue,starts_at,ends_at,organizer_name,event_type,standings_mode,status,timezone,public_description,public_links,registration_open')
    .in('status',['published','live','completed','cancelled'])
    .not('published_at','is',null)
    .order('starts_at',{ascending:true});
  if(error)throw error;
  return (data??[]).map((row:any)=>({
    id:row.id,organizationId:row.organization_id,name:row.name,venue:row.venue,startsAt:row.starts_at,endsAt:row.ends_at,
    organizerName:row.organizer_name??undefined,eventType:row.event_type,standingsMode:row.standings_mode,status:row.status,
    timezone:row.timezone,publicDescription:row.public_description??undefined,
    publicLinks:row.public_links??{},registrationOpen:Boolean(row.registration_open)
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


export type PublicEventDetails = {
  event: PublicEventSummary;
  announcements: Array<{id:string;title:string;body:string;scheduledFor?:string;createdAt:string}>;
  fields: Array<{id:string;name:string;listName:string;status:string;sortOrder:number}>;
  divisions: Array<{id:string;name:string;registrationOpen:boolean}>;
  matches: Array<{id:string;label:string;category:string;status:string;scheduledOrder:number}>;
};

export async function loadPublicEventDetails(id:string):Promise<PublicEventDetails|undefined>{
  if(!publicSupabase)return undefined;
  const {data:eventRow,error:eventError}=await publicSupabase.from('events')
    .select('id,organization_id,name,venue,starts_at,ends_at,organizer_name,event_type,standings_mode,status,timezone,public_description,public_links,registration_open,published_at')
    .eq('id',id)
    .in('status',['published','live','completed','cancelled'])
    .not('published_at','is',null)
    .maybeSingle();
  if(eventError)throw eventError;
  if(!eventRow)return undefined;

  const [announcementsRes,fieldsRes,eventDivisionsRes,matchesRes]=await Promise.all([
    publicSupabase.from('announcements')
      .select('id,title,body,scheduled_for,created_at')
      .eq('event_id',id)
      .eq('is_public',true)
      .order('scheduled_for',{ascending:true,nullsFirst:false}),
    publicSupabase.from('fight_cards')
      .select('id,name,list_name,status,sort_order')
      .eq('event_id',id)
      .neq('status','archived')
      .order('sort_order'),
    publicSupabase.from('event_divisions')
      .select('id,division_id,is_registration_open')
      .eq('event_id',id),
    publicSupabase.from('matches')
      .select('id,label,category,status,scheduled_order')
      .eq('event_id',id)
      .order('scheduled_order')
  ]);

  if(announcementsRes.error)throw announcementsRes.error;
  if(fieldsRes.error)throw fieldsRes.error;
  if(eventDivisionsRes.error)throw eventDivisionsRes.error;
  if(matchesRes.error)throw matchesRes.error;

  const divisionIds=(eventDivisionsRes.data??[]).map((row:any)=>row.division_id).filter(Boolean);
  let divisionNames=new Map<string,string>();
  if(divisionIds.length){
    const {data,error}=await publicSupabase.from('competition_divisions').select('id,name').in('id',divisionIds);
    if(error)throw error;
    divisionNames=new Map((data??[]).map((row:any)=>[row.id,row.name]));
  }

  return {
    event:{
      id:eventRow.id,
      organizationId:eventRow.organization_id,
      name:eventRow.name,
      venue:eventRow.venue,
      startsAt:eventRow.starts_at,
      endsAt:eventRow.ends_at,
      organizerName:eventRow.organizer_name??undefined,
      eventType:eventRow.event_type,
      standingsMode:eventRow.standings_mode,
      status:eventRow.status,
      timezone:eventRow.timezone,
      publicDescription:eventRow.public_description??undefined,
      publicLinks:eventRow.public_links??{},
      registrationOpen:Boolean(eventRow.registration_open)
    },
    announcements:(announcementsRes.data??[]).map((row:any)=>({
      id:row.id,title:row.title,body:row.body,scheduledFor:row.scheduled_for??undefined,createdAt:row.created_at
    })),
    fields:(fieldsRes.data??[]).map((row:any)=>({
      id:row.id,name:row.name,listName:row.list_name,status:row.status,sortOrder:Number(row.sort_order??0)
    })),
    divisions:(eventDivisionsRes.data??[]).map((row:any)=>({
      id:row.id,name:divisionNames.get(row.division_id)??'Competition division',registrationOpen:Boolean(row.is_registration_open)
    })),
    matches:(matchesRes.data??[]).map((row:any)=>({
      id:row.id,label:row.label,category:row.category,status:row.status,scheduledOrder:Number(row.scheduled_order??0)
    }))
  };
}
