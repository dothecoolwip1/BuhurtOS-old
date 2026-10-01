import { hacsaTeams } from '../data/hacsaTeams';
import { publicSupabase } from './supabase';

export type PublicDirectoryTeam = {
  id:string; slug:string; organizationId?:string; organizationName:string; organizationShortName:string; name:string;
  location:string; continentCode:string; continentName:string; countryCode:string; countryName:string; adminAreaCode:string; adminAreaName:string;
  email?:string; websiteUrl?:string; contactUrl?:string; latitude?:number; longitude?:number;
  logoPath?:string; description?:string; captain?:string;
  rank5v5?:number; averagePoints5v5?:number; points5v5?:number; rank12v12?:number; points12v12?:number;
  sourceKind?:'hacsa'|'bi_teams'|'bi_ranking'; sourceUrl?:string; verifiedAt?:string;
};
export type PublicRosterMember={
  identityId?:string; displayName:string; nickname?:string; avatarPath?:string; bio?:string; publicRegion?:string; role?:string;
  sourceKind?:'buhurtos'|'bi_teams'|'hacsa'|string;
};
export type PublicTeamDetail={
  teamId:string; logoPath?:string; description?:string; captain?:string; club?:string; gender?:string; conference?:string; country?:string; city?:string;
  trainingInfo?:string; trainingLocation?:any; websiteUrl?:string; email?:string;
  rank5v5?:number; averagePoints5v5?:number; points5v5?:number; rank12v12?:number; points12v12?:number;
  tournamentsJoined:any[]; eventsHistory:Record<string,any>; sourceUrl?:string; verifiedAt?:string;
};
export type TeamDirectoryFilters={organizationShortName?:string;continentCode?:string;countryCode?:string;adminAreaCode?:string;teamSlug?:string};

const CACHE_MS = 2 * 60 * 1000;
type CacheEntry<T> = { at:number; value:T };
const directoryCache = new Map<string,CacheEntry<PublicDirectoryTeam[]>>();
const rosterCache = new Map<string,CacheEntry<PublicRosterMember[]>>();
const detailCache = new Map<string,CacheEntry<PublicTeamDetail|undefined>>();
let mapCache:CacheEntry<PublicDirectoryTeam[]>|undefined;
let featuredCache:CacheEntry<PublicDirectoryTeam[]>|undefined;

function fresh<T>(entry:CacheEntry<T>|undefined):T|undefined{
  if(!entry || Date.now()-entry.at>CACHE_MS) return undefined;
  return entry.value;
}
function cacheKey(filters:TeamDirectoryFilters){
  return JSON.stringify({
    organizationShortName:filters.organizationShortName??null,
    continentCode:filters.continentCode??null,
    countryCode:filters.countryCode??null,
    adminAreaCode:filters.adminAreaCode??null,
    teamSlug:filters.teamSlug??null
  });
}

export function hacsaFallbackDirectory():PublicDirectoryTeam[]{return hacsaTeams.map(team=>({
 id:team.id,slug:team.id==='reavers'?'red-deer-reavers':team.id,organizationName:'Historical Armored Combat Sports Association',organizationShortName:'HACSA',name:team.name,location:team.location,
 continentCode:team.continentCode,continentName:team.continentName,countryCode:team.countryCode,countryName:team.countryName,adminAreaCode:team.adminAreaCode,
 adminAreaName:team.adminAreaName,email:team.email,websiteUrl:team.websiteUrl,contactUrl:team.contactUrl,sourceKind:'hacsa',sourceUrl:team.sourceUrl,verifiedAt:team.verifiedAt
}))}

function mapRow(row:any):PublicDirectoryTeam{return {
 id:row.id,slug:row.directory_slug??row.id,organizationId:row.organization_id,organizationName:row.organization_name??row.organization_short_name,
 organizationShortName:row.organization_short_name,name:row.team_name,location:row.city_or_region??'Location pending',
 continentCode:row.continent_code??'',continentName:row.continent_name??row.continent_code??'Region pending',countryCode:row.country_code??'',
 countryName:row.country_name??row.country_code??'Country pending',adminAreaCode:row.admin_area_code??'',adminAreaName:row.admin_area_name??'Region pending',
 email:row.public_contact_email??undefined,websiteUrl:row.website_url??undefined,contactUrl:row.source_contact_url??undefined,
 logoPath:row.logo_path??undefined,description:row.public_description??undefined,captain:row.captain??undefined,
 latitude:row.public_latitude??undefined,longitude:row.public_longitude??undefined,
 rank5v5:row.rank_5v5??undefined,averagePoints5v5:row.average_points_5v5??undefined,points5v5:row.points_5v5??undefined,
 rank12v12:row.rank_12v12??undefined,points12v12:row.points_12v12??undefined,
 sourceKind:row.source_kind??undefined,sourceUrl:row.source_url??undefined,verifiedAt:row.source_verified_at?String(row.source_verified_at).slice(0,10):undefined
}}

export async function loadPublicTeamDirectory(filters:TeamDirectoryFilters={}):Promise<PublicDirectoryTeam[]>{
 if(!publicSupabase){
   const rows=hacsaFallbackDirectory();
   return rows.filter(team =>
     (!filters.organizationShortName||team.organizationShortName.toLowerCase()===filters.organizationShortName.toLowerCase())&&
     (!filters.continentCode||team.continentCode===filters.continentCode)&&
     (!filters.countryCode||team.countryCode===filters.countryCode)&&
     (!filters.adminAreaCode||team.adminAreaCode===filters.adminAreaCode)&&
     (!filters.teamSlug||team.slug===filters.teamSlug||team.id===filters.teamSlug)
   );
 }
 const key=cacheKey(filters);
 const cached=fresh(directoryCache.get(key));
 if(cached) return cached;

 const {data,error}=await publicSupabase.rpc('public_team_directory_v3',{
   p_organization_short_name:filters.organizationShortName??null,
   p_continent_code:filters.continentCode??null,
   p_country_code:filters.countryCode??null,
   p_admin_area_code:filters.adminAreaCode??null,
   p_team_slug:filters.teamSlug??null
 });
 if(error)throw error;
 const rows=(data??[]).map(mapRow);
 directoryCache.set(key,{at:Date.now(),value:rows});
 return rows;
}

/** Teams BuhurtOS is emphasizing now (configuration, display priority only). Small list; never the worldwide directory. */
export async function loadFeaturedTeams():Promise<PublicDirectoryTeam[]>{
 if(!publicSupabase)return hacsaFallbackDirectory();
 const cached=fresh(featuredCache);
 if(cached)return cached;
 const {data,error}=await publicSupabase.rpc('public_featured_teams');
 if(error){
   // Backend without the prominence function yet: fall back to the small HACSA directory, not the worldwide one.
   const rows=(await publicSupabase.rpc('public_team_directory_v3',{p_organization_short_name:'HACSA',p_continent_code:null,p_country_code:null,p_admin_area_code:null,p_team_slug:null})).data;
   return (rows??[]).map(mapRow);
 }
 const rows=(data??[]).map(mapRow);
 featuredCache={at:Date.now(),value:rows};
 return rows;
}

/** The canonical team's slug for an old alias address (a reconciled duplicate), or undefined. */
export async function resolveTeamAliasSlug(slug:string):Promise<string|undefined>{
 if(!publicSupabase||!slug)return undefined;
 const {data,error}=await publicSupabase.rpc('resolve_team_alias_slug',{p_slug:slug});
 if(error)return undefined; // a backend without alias support simply has no aliases
 return typeof data==='string'&&data?data:undefined;
}

export async function loadPublicTeamMap():Promise<PublicDirectoryTeam[]>{
 if(!publicSupabase)return hacsaFallbackDirectory().filter(team=>team.latitude!=null&&team.longitude!=null);
 const cached=fresh(mapCache);
 if(cached)return cached;
 const {data,error}=await publicSupabase.rpc('public_team_map');
 if(error)throw error;
 const rows=(data??[]).map((row:any)=>({
   id:row.team_id,
   slug:row.directory_slug??row.team_id,
   organizationName:row.organization_short_name,
   organizationShortName:row.organization_short_name,
   name:row.team_name,
   location:row.city_or_region??'Location pending',
   continentCode:row.continent_code??'',
   continentName:row.continent_name??row.continent_code??'Region pending',
   countryCode:row.country_code??'',
   countryName:row.country_name??row.country_code??'Country pending',
   adminAreaCode:row.admin_area_code??'',
   adminAreaName:row.admin_area_name??'Region pending',
   latitude:row.public_latitude??undefined,
   longitude:row.public_longitude??undefined
 })) as PublicDirectoryTeam[];
 mapCache={at:Date.now(),value:rows};
 return rows;
}

export async function loadPublicTeamRoster(teamId:string):Promise<PublicRosterMember[]>{
 if(!publicSupabase)return[];
 const cached=fresh(rosterCache.get(teamId));
 if(cached)return cached;
 const {data,error}=await publicSupabase.rpc('public_team_roster',{p_team_id:teamId}); if(error)throw error;
 const rows=(data??[]).map((row:any)=>({identityId:row.identity_id??undefined,displayName:row.display_name,nickname:row.nickname??undefined,avatarPath:row.avatar_path??undefined,
  bio:row.bio??undefined,publicRegion:row.public_region??undefined,role:row.role??undefined,sourceKind:row.source_kind??undefined}));
 rosterCache.set(teamId,{at:Date.now(),value:rows});
 return rows;
}

export async function loadPublicTeamDetail(teamId:string):Promise<PublicTeamDetail|undefined>{
 if(!publicSupabase)return undefined;
 const cached=fresh(detailCache.get(teamId));
 if(cached!==undefined)return cached;
 const {data,error}=await publicSupabase.rpc('public_team_detail',{p_team_id:teamId}); if(error)throw error;
 const row=(data??[])[0]; if(!row){detailCache.set(teamId,{at:Date.now(),value:undefined});return undefined;}
 const detail={teamId:row.team_id,logoPath:row.logo_path??undefined,description:row.public_description??undefined,captain:row.captain??undefined,
  club:row.club??undefined,gender:row.gender??undefined,conference:row.conference??undefined,country:row.country??undefined,city:row.city??undefined,
  trainingInfo:row.training_info??undefined,trainingLocation:row.training_location??undefined,websiteUrl:row.website_url??undefined,email:row.public_contact_email??undefined,
  rank5v5:row.rank_5v5??undefined,averagePoints5v5:row.average_points_5v5??undefined,points5v5:row.points_5v5??undefined,
  rank12v12:row.rank_12v12??undefined,points12v12:row.points_12v12??undefined,tournamentsJoined:Array.isArray(row.tournaments_joined)?row.tournaments_joined:[],
  eventsHistory:row.events_history??{},sourceUrl:row.source_url??undefined,verifiedAt:row.source_verified_at?String(row.source_verified_at).slice(0,10):undefined};
 detailCache.set(teamId,{at:Date.now(),value:detail});
 return detail;
}

export function clearPublicTeamCaches(){
  directoryCache.clear();
  rosterCache.clear();
  detailCache.clear();
  mapCache=undefined;
  featuredCache=undefined;
}
