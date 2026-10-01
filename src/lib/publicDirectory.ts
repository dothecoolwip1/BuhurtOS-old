import { publicSupabase } from './supabase';
import { loadPublicTeamDirectory, type PublicDirectoryTeam } from './teamDirectory';

const CACHE_MS = 2 * 60 * 1000;
let organizationsCache: {at:number; value:PublicOrganizationSummary[]} | null = null;
let eventsCache: {at:number; value:PublicEventSummary[]} | null = null;
let fightersCache: {at:number; value:PublicFighterSummary[]} | null = null;
const eventDetailCache = new Map<string,{at:number; value:PublicEventDetails|undefined}>();

function isFresh(at:number){ return Date.now()-at < CACHE_MS; }

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
  /** Display priority only (configuration); never implies endorsement or affects permissions. */
  featured:boolean;
  featuredOrder?:number;
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
  slug?:string;
  hostTeamId?:string;
  imagePath?:string;
  /** Organizer-written description of the poster; absent when none was written. */
  imageAlt?:string;
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

/**
 * Featured organizations come from configuration (organizations.featured / featured_order) through a public RPC.
 * If that function is not available on the backend yet, fall back to the original BI then HACSA emphasis.
 */
async function loadFeaturedOrganizationOrder():Promise<Map<string,number|undefined>>{
  const result=new Map<string,number|undefined>();
  if(!publicSupabase)return result;
  const {data,error}=await publicSupabase.rpc('public_featured_organizations');
  if(error){
    const {data:rows}=await publicSupabase.rpc('public_organization_directory_summary');
    (rows??[]).forEach((row:any)=>{const i=['BI','HACSA'].indexOf(row.organization_short_name);if(i>=0)result.set(row.organization_id,i+1)});
    return result;
  }
  (data??[]).forEach((row:any)=>result.set(row.organization_id,row.featured_order??undefined));
  return result;
}

function slug(value:string){return value.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')}

export async function loadPublicOrganizations():Promise<PublicOrganizationSummary[]>{
  if(!publicSupabase)return [];
  if(organizationsCache && isFresh(organizationsCache.at)) return organizationsCache.value;
  const [{data,error},featured]=await Promise.all([publicSupabase.rpc('public_organization_directory_summary'),loadFeaturedOrganizationOrder()]);
  if(error)throw error;
  const rows:PublicOrganizationSummary[]=(data??[]).map((row:any)=>{
    const shortName=row.organization_short_name;
    const info=orgInfo[shortName];
    return {
      key:slug(shortName||row.organization_name),
      id:row.organization_id,
      shortName,
      name:info?.name??row.organization_name,
      region:row.region??(shortName==='BI'?'International':'Global'),
      kind:info?.kind??row.kind??'Buhurt organization',
      description:info?.description??row.description??'A Buhurt organization represented in the public team directory.',
      websiteUrl:info?.websiteUrl??row.website_url??undefined,
      teamCount:Number(row.team_count??0),
      rosterCount:Number(row.roster_count??0),
      countries:Number(row.country_count??0),
      featured:featured.has(row.organization_id),
      featuredOrder:featured.get(row.organization_id)
    } satisfies PublicOrganizationSummary;
  });
  rows.sort((a,b)=>{
    if(a.featured||b.featured){
      if(a.featured&&b.featured)return (a.featuredOrder??99)-(b.featuredOrder??99)||a.name.localeCompare(b.name);
      return a.featured?-1:1;
    }
    return a.name.localeCompare(b.name);
  });
  organizationsCache={at:Date.now(),value:rows};
  return rows;
}

export async function loadPublicOrganization(key:string):Promise<{organization:PublicOrganizationSummary;teams:PublicDirectoryTeam[]}|undefined>{
  const organizations=await loadPublicOrganizations();
  const organization=organizations.find(org=>org.key===key||slug(org.shortName)===key||slug(org.name)===key);
  if(!organization)return undefined;
  const teams=await loadPublicTeamDirectory({organizationShortName:organization.shortName});
  return {organization,teams};
}

const EVENT_BASE_COLUMNS='id,organization_id,name,venue,starts_at,ends_at,organizer_name,event_type,standings_mode,status,timezone,public_description,public_links,registration_open';
const EVENT_EXTENDED_COLUMNS=EVENT_BASE_COLUMNS+',slug,host_team_id,image_path';
const EVENT_ALT_COLUMNS=EVENT_EXTENDED_COLUMNS+',image_alt';
/** Newest first. A backend that lacks a newer column falls back one tier at a time, never straight to the legacy list. */
const EVENT_COLUMN_TIERS=[EVENT_ALT_COLUMNS,EVENT_EXTENDED_COLUMNS,EVENT_BASE_COLUMNS];
/** Remembered for the session so a backend without newer columns is not probed on every load. */
let eventColumnTier=0;

/**
 * Postgres 42703 / PostgREST PGRST204 mean "that column does not exist": the backend predates the general-event columns.
 * Only that case may fall back to the legacy column list; every other failure must surface as an error.
 */
export function isMissingColumnError(error:unknown):boolean{
  const e=error as {code?:string;message?:string}|null|undefined;
  if(!e)return false;
  if(e.code==='42703'||e.code==='PGRST204')return true;
  return /column .* does not exist/i.test(e.message??'');
}

function mapEventRow(row:any):PublicEventSummary{
  const links=row.public_links??{};
  const linkedHost=typeof links.host_team_id==='string'?links.host_team_id:undefined;
  return {
    id:row.id,organizationId:row.organization_id,name:row.name,venue:row.venue,startsAt:row.starts_at,endsAt:row.ends_at,
    organizerName:row.organizer_name??undefined,eventType:row.event_type,standingsMode:row.standings_mode,status:row.status,
    timezone:row.timezone,publicDescription:row.public_description??undefined,
    publicLinks:links,registrationOpen:Boolean(row.registration_open),
    slug:row.slug??undefined,hostTeamId:row.host_team_id??linkedHost,imagePath:row.image_path??undefined,imageAlt:row.image_alt??undefined
  };
}

/** Uses the general-event columns when the database has them and degrades to the legacy columns otherwise. */
export async function loadPublicEvents():Promise<PublicEventSummary[]>{
  if(!publicSupabase)return [];
  if(eventsCache && isFresh(eventsCache.at)) return eventsCache.value;
  const query=(columns:string)=>publicSupabase!.from('events')
    .select(columns)
    .in('status',['published','live','completed','cancelled'])
    .not('published_at','is',null)
    .order('starts_at',{ascending:true});
  let {data,error}=await query(EVENT_COLUMN_TIERS[eventColumnTier]);
  while(error&&eventColumnTier<EVENT_COLUMN_TIERS.length-1&&isMissingColumnError(error)){
    eventColumnTier++;
    ({data,error}=await query(EVENT_COLUMN_TIERS[eventColumnTier]));
  }
  if(error)throw error;
  const rows=((data??[]) as any[]).map(mapEventRow);
  eventsCache={at:Date.now(),value:rows};
  return rows;
}

export async function loadPublicFighters():Promise<PublicFighterSummary[]>{
  if(!publicSupabase)return [];
  if(fightersCache && isFresh(fightersCache.at)) return fightersCache.value;
  const {data,error}=await publicSupabase.from('fighter_identities')
    .select('id,display_name,nickname,avatar_path,bio,public_region,verified_at')
    .eq('profile_visibility','public')
    .order('display_name');
  if(error)throw error;
  const rows=(data??[]).map((row:any)=>({
    id:row.id,displayName:row.display_name,nickname:row.nickname??undefined,avatarPath:row.avatar_path??undefined,
    bio:row.bio??undefined,publicRegion:row.public_region??undefined,verified:Boolean(row.verified_at)
  }));
  fightersCache={at:Date.now(),value:rows};
  return rows;
}

export async function loadPublicFighter(id:string):Promise<PublicFighterSummary|undefined>{
  if(!publicSupabase)return undefined;
  const {data,error}=await publicSupabase.from('fighter_identities')
    .select('id,display_name,nickname,avatar_path,bio,public_region,verified_at')
    .eq('id',id)
    .eq('profile_visibility','public')
    .maybeSingle();
  if(error)throw error;
  if(!data)return undefined;
  return {
    id:data.id,displayName:data.display_name,nickname:data.nickname??undefined,avatarPath:data.avatar_path??undefined,
    bio:data.bio??undefined,publicRegion:data.public_region??undefined,verified:Boolean(data.verified_at)
  };
}


export type PublicEventDetails = {
  event: PublicEventSummary;
  announcements: Array<{id:string;title:string;body:string;scheduledFor?:string;createdAt:string}>;
  fields: Array<{id:string;name:string;listName:string;status:string;sortOrder:number}>;
  divisions: Array<{id:string;name:string;registrationOpen:boolean}>;
  matches: Array<{id:string;label:string;category:string;status:string;scheduledOrder:number}>;
};

const UUID_PATTERN=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** The stable public address of an event: its slug when it has one, its id otherwise (old links keep working). */
export function eventPath(event:{id:string;slug?:string}):string{
  return '/events/'+(event.slug||event.id);
}

/** Accepts either the event id or its public slug. */
export async function loadPublicEventDetails(identifier:string):Promise<PublicEventDetails|undefined>{
  if(!publicSupabase)return undefined;
  const byId=UUID_PATTERN.test(identifier);
  if(!byId&&eventColumnTier>=EVENT_COLUMN_TIERS.length-1)return undefined; // a backend without slugs cannot resolve one
  const cached=eventDetailCache.get(identifier);
  if(cached && isFresh(cached.at)) return cached.value;
  const fetchEvent=(columns:string)=>publicSupabase!.from('events')
    .select(columns)
    .eq(byId?'id':'slug',identifier)
    .in('status',['published','live','completed','cancelled'])
    .not('published_at','is',null)
    .maybeSingle();
  let eventResult:{data:any;error:any}=await fetchEvent(EVENT_COLUMN_TIERS[eventColumnTier]+',published_at');
  while(eventResult.error&&eventColumnTier<EVENT_COLUMN_TIERS.length-1&&isMissingColumnError(eventResult.error)){
    eventColumnTier++;
    eventResult=await fetchEvent(EVENT_COLUMN_TIERS[eventColumnTier]+',published_at');
  }
  const {data:eventRow,error:eventError}=eventResult;
  if(eventError)throw eventError;
  if(!eventRow){eventDetailCache.set(identifier,{at:Date.now(),value:undefined});return undefined;}
  const id:string=eventRow.id;

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

  const result:PublicEventDetails = {
    event:mapEventRow(eventRow),
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
  eventDetailCache.set(identifier,{at:Date.now(),value:result});
  return result;
}

export function clearPublicDirectoryCaches(){
  eventColumnTier=0;
  organizationsCache=null;
  eventsCache=null;
  fightersCache=null;
  eventDetailCache.clear();
}

export type PublicOrganizationLink = {
  id:string;
  direction:'parent'|'child';
  kind:string;
  otherOrganizationId:string;
  otherName:string;
  otherShortName?:string;
  startsOn?:string;
};

const relationshipLabels:Record<string,string> = {governs:'Governs',recognizes:'Recognizes',affiliate:'Affiliated with',sanctioned:'Sanctions',predecessor:'Predecessor of'};
export function relationshipLabel(link:Pick<PublicOrganizationLink,'kind'|'direction'>){
  const base=relationshipLabels[link.kind]??link.kind;
  return link.direction==='child'?(link.kind==='governs'?'Governed by':link.kind==='recognizes'?'Recognized by':link.kind==='sanctioned'?'Sanctioned by':link.kind==='predecessor'?'Successor of':base):base;
}

/** Active governing links for one organization; returns [] when none are published. */
export async function loadPublicOrganizationLinks(organizationId:string):Promise<PublicOrganizationLink[]>{
  if(!publicSupabase||!organizationId)return [];
  const {data,error}=await publicSupabase.from('organization_relationships')
    .select('id,parent_organization_id,child_organization_id,relationship_kind,starts_on,ends_on')
    .or(`parent_organization_id.eq.${organizationId},child_organization_id.eq.${organizationId}`)
    .is('ends_on',null);
  if(error)throw error;
  const rows=data??[];
  const otherIds=[...new Set(rows.map((r:any)=>r.parent_organization_id===organizationId?r.child_organization_id:r.parent_organization_id))];
  if(!otherIds.length)return [];
  // Anonymous visitors cannot read the organizations table, so names come from the public directory RPC.
  const directory=await loadPublicOrganizations();
  const names=new Map(directory.map(o=>[o.id,{name:o.name,short_name:o.shortName}]));
  return rows.filter((r:any)=>names.has(r.parent_organization_id===organizationId?r.child_organization_id:r.parent_organization_id)).map((r:any)=>{
    const direction=r.parent_organization_id===organizationId?'parent':'child';
    const otherId=direction==='parent'?r.child_organization_id:r.parent_organization_id;
    const other=names.get(otherId) as any;
    return {id:r.id,direction,kind:r.relationship_kind,otherOrganizationId:otherId,otherName:other?.name??'Organization',otherShortName:other?.short_name??undefined,startsOn:r.starts_on??undefined} satisfies PublicOrganizationLink;
  });
}

export async function loadPublicOrganizationEvents(organizationId:string|undefined):Promise<PublicEventSummary[]>{
  if(!organizationId)return [];
  const events=await loadPublicEvents();
  return events.filter(event=>event.organizationId===organizationId);
}

export type PublicScheduleSlot = { matchId: string; areaId?: string; areaName?: string; startsAt: string; endsAt: string; order: number };

/**
 * Planned bout times for a published event, read from the schedule the organizer saved with each tournament.
 * Anonymous visitors already have column-level read access to bracket metadata for public events (see the Pack 2 privilege grants),
 * so this needs no new database function. Only matches that still exist and are not cancelled are returned.
 */
export async function loadPublicEventSchedule(eventId:string):Promise<PublicScheduleSlot[]>{
  if(!publicSupabase||!eventId)return [];
  const {data,error}=await publicSupabase.from('brackets').select('id,metadata').eq('event_id',eventId);
  if(error)throw error;
  const slots:PublicScheduleSlot[]=[];
  for(const row of data??[]){
    const list=(row as any).metadata?.schedule?.slots;
    if(!Array.isArray(list))continue;
    for(const slot of list){
      if(!slot||typeof slot.matchId!=='string'||Number.isNaN(Date.parse(slot.startsAt))||Number.isNaN(Date.parse(slot.endsAt)))continue;
      slots.push({matchId:slot.matchId,areaId:slot.areaId,startsAt:slot.startsAt,endsAt:slot.endsAt,order:Number(slot.order??0)});
    }
  }
  return slots.sort((a,b)=>a.startsAt.localeCompare(b.startsAt)||a.order-b.order);
}
