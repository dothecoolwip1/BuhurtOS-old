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

export function hacsaFallbackDirectory():PublicDirectoryTeam[]{return hacsaTeams.map(team=>({
 id:team.id,slug:team.id,organizationName:'Historical Armored Combat Sports Association',organizationShortName:'HACSA',name:team.name,location:team.location,
 continentCode:team.continentCode,continentName:team.continentName,countryCode:team.countryCode,countryName:team.countryName,adminAreaCode:team.adminAreaCode,
 adminAreaName:team.adminAreaName,email:team.email,websiteUrl:team.websiteUrl,contactUrl:team.contactUrl,sourceKind:'hacsa',sourceUrl:team.sourceUrl,verifiedAt:team.verifiedAt
}))}

function mapRow(row:any):PublicDirectoryTeam{return {
 id:row.id,slug:row.directory_slug,organizationId:row.organization_id,organizationName:row.organization_name??row.organization_short_name,
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
 if(!publicSupabase)return hacsaFallbackDirectory();
 const {data,error}=await publicSupabase.rpc('public_team_directory_v2'); if(error)throw error;
 return (data??[]).map(mapRow).filter((team:PublicDirectoryTeam)=>
  (!filters.organizationShortName||team.organizationShortName.toLowerCase()===filters.organizationShortName.toLowerCase())&&
  (!filters.continentCode||team.continentCode===filters.continentCode)&&(!filters.countryCode||team.countryCode===filters.countryCode)&&
  (!filters.adminAreaCode||team.adminAreaCode===filters.adminAreaCode)&&(!filters.teamSlug||team.slug===filters.teamSlug));
}

export async function loadPublicTeamRoster(teamId:string):Promise<PublicRosterMember[]>{
 if(!publicSupabase)return[];
 const {data,error}=await publicSupabase.rpc('public_team_roster',{p_team_id:teamId}); if(error)throw error;
 return (data??[]).map((row:any)=>({identityId:row.identity_id??undefined,displayName:row.display_name,nickname:row.nickname??undefined,avatarPath:row.avatar_path??undefined,
  bio:row.bio??undefined,publicRegion:row.public_region??undefined,role:row.role??undefined,sourceKind:row.source_kind??undefined}));
}

export async function loadPublicTeamDetail(teamId:string):Promise<PublicTeamDetail|undefined>{
 if(!publicSupabase)return undefined;
 const {data,error}=await publicSupabase.rpc('public_team_detail',{p_team_id:teamId}); if(error)throw error;
 const row=(data??[])[0]; if(!row)return undefined;
 return {teamId:row.team_id,logoPath:row.logo_path??undefined,description:row.public_description??undefined,captain:row.captain??undefined,
  club:row.club??undefined,gender:row.gender??undefined,conference:row.conference??undefined,country:row.country??undefined,city:row.city??undefined,
  trainingInfo:row.training_info??undefined,trainingLocation:row.training_location??undefined,websiteUrl:row.website_url??undefined,email:row.public_contact_email??undefined,
  rank5v5:row.rank_5v5??undefined,averagePoints5v5:row.average_points_5v5??undefined,points5v5:row.points_5v5??undefined,
  rank12v12:row.rank_12v12??undefined,points12v12:row.points_12v12??undefined,tournamentsJoined:Array.isArray(row.tournaments_joined)?row.tournaments_joined:[],
  eventsHistory:row.events_history??{},sourceUrl:row.source_url??undefined,verifiedAt:row.source_verified_at?String(row.source_verified_at).slice(0,10):undefined};
}
