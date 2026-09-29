import { hacsaTeams } from '../data/hacsaTeams';
import { publicSupabase } from './supabase';

export type PublicDirectoryTeam = {
  id:string; slug:string; organizationId?:string; organizationName:string; organizationShortName:string; name:string;
  location:string; continentCode:string; continentName:string; countryCode:string; countryName:string; adminAreaCode:string; adminAreaName:string;
  email?:string; websiteUrl?:string; contactUrl?:string; latitude?:number; longitude?:number;
  sourceKind?:'hacsa'|'bi_teams'|'bi_ranking'; sourceUrl?:string; verifiedAt?:string;
};
export type PublicRosterMember={
  identityId?:string; displayName:string; nickname?:string; avatarPath?:string; bio?:string; publicRegion?:string; role?:string;
  sourceKind?:'buhurtos'|'bi_teams'|'hacsa'|string;
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
 latitude:row.public_latitude??undefined,longitude:row.public_longitude??undefined,sourceKind:row.source_kind??undefined,sourceUrl:row.source_url??undefined,
 verifiedAt:row.source_verified_at?String(row.source_verified_at).slice(0,10):undefined
}}

export async function loadPublicTeamDirectory(filters:TeamDirectoryFilters={}):Promise<PublicDirectoryTeam[]>{
 if(!publicSupabase)return hacsaFallbackDirectory();
 const {data,error}=await publicSupabase.rpc('public_team_directory_all'); if(error)throw error;
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
