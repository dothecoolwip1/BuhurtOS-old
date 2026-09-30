import { publicSupabase, supabase } from './supabase';

export type FighterSignupStatus = 'new'|'contacted'|'confirmed'|'declined'|'archived';

export interface FighterEventSignup {
  id:string;
  eventId:string;
  displayName:string;
  email:string;
  phone?:string;
  teamName?:string;
  experienceYears?:number;
  fightingCategories:string[];
  armorStatus?:string;
  attendanceNotes?:string;
  emergencyContact?:string;
  additionalNotes?:string;
  consentAcknowledged:boolean;
  status:FighterSignupStatus;
  organizerNotes?:string;
  createdAt:string;
  updatedAt:string;
}

export async function submitFighterSignup(input:{
  eventId:string;
  displayName:string;
  email:string;
  phone?:string;
  teamName?:string;
  experienceYears?:number;
  fightingCategories:string[];
  armorStatus?:string;
  attendanceNotes?:string;
  emergencyContact?:string;
  additionalNotes?:string;
  consentAcknowledged:boolean;
}):Promise<void>{
  if(!publicSupabase) throw new Error('BuhurtOS is not connected.');
  const {error}=await publicSupabase.from('fighter_event_signups').insert({
    event_id:input.eventId,
    display_name:input.displayName.trim(),
    email:input.email.trim().toLowerCase(),
    phone:input.phone?.trim()||null,
    team_name:input.teamName?.trim()||null,
    experience_years:input.experienceYears ?? null,
    fighting_categories:input.fightingCategories,
    armor_status:input.armorStatus?.trim()||null,
    attendance_notes:input.attendanceNotes?.trim()||null,
    emergency_contact:input.emergencyContact?.trim()||null,
    additional_notes:input.additionalNotes?.trim()||null,
    consent_acknowledged:input.consentAcknowledged
  });
  if(error) throw error;
}

export async function listFighterSignups(eventId:string):Promise<FighterEventSignup[]>{
  if(!supabase) return [];
  const {data,error}=await supabase.from('fighter_event_signups')
    .select('*')
    .eq('event_id',eventId)
    .order('created_at',{ascending:false});
  if(error) throw error;
  return (data??[]).map((row:any)=>({
    id:row.id,eventId:row.event_id,displayName:row.display_name,email:row.email,
    phone:row.phone??undefined,teamName:row.team_name??undefined,
    experienceYears:row.experience_years==null?undefined:Number(row.experience_years),
    fightingCategories:row.fighting_categories??[],armorStatus:row.armor_status??undefined,
    attendanceNotes:row.attendance_notes??undefined,emergencyContact:row.emergency_contact??undefined,
    additionalNotes:row.additional_notes??undefined,consentAcknowledged:Boolean(row.consent_acknowledged),
    status:row.status,organizerNotes:row.organizer_notes??undefined,
    createdAt:row.created_at,updatedAt:row.updated_at
  }));
}

export async function updateFighterSignup(id:string,status:FighterSignupStatus,organizerNotes:string):Promise<void>{
  if(!supabase) throw new Error('BuhurtOS is not connected.');
  const {error}=await supabase.from('fighter_event_signups').update({
    status,organizer_notes:organizerNotes.trim()||null,reviewed_at:new Date().toISOString()
  }).eq('id',id);
  if(error) throw error;
}
