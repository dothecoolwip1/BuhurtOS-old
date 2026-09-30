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

export interface EventSignupCode {
  id:string;
  label:string;
  codePrefix:string;
  maxUses:number;
  uses:number;
  expiresAt?:string;
  disabledAt?:string;
  createdAt:string;
}

export async function validateFighterSignupCode(eventId:string,code:string):Promise<{valid:boolean;message?:string;label?:string;prefix?:string}>{
  if(!publicSupabase) throw new Error('BuhurtOS is not connected.');
  const {data,error}=await publicSupabase.rpc('validate_event_signup_code',{p_event:eventId,p_code:code.trim().toUpperCase()});
  if(error) throw error;
  return (data??{}) as {valid:boolean;message?:string;label?:string;prefix?:string};
}

/** Signed-in callers use their session so the signup is linked to their account; visitors use the public client. */
async function callerClient(){
  if(supabase){
    const {data}=await supabase.auth.getSession();
    if(data.session) return supabase;
  }
  return publicSupabase;
}

/** An empty code means 'register without a code'; the server allows that only when it says the caller is eligible. */
export async function submitFighterSignup(input:{
  eventId:string;
  code:string;
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
  const client=await callerClient();
  if(!client) throw new Error('BuhurtOS is not connected.');
  const {error}=await client.rpc('submit_event_fighter_signup',{
    p_event:input.eventId,
    p_code:input.code.trim()?input.code.trim().toUpperCase():null,
    p_display_name:input.displayName,
    p_email:input.email,
    p_phone:input.phone||null,
    p_team_name:input.teamName||null,
    p_experience_years:input.experienceYears??null,
    p_fighting_categories:input.fightingCategories,
    p_armor_status:input.armorStatus||null,
    p_attendance_notes:input.attendanceNotes||null,
    p_emergency_contact:input.emergencyContact||null,
    p_additional_notes:input.additionalNotes||null,
    p_consent:input.consentAcknowledged
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

export async function createEventSignupCode(input:{eventId:string;label?:string;maxUses?:number;expiresAt?:string}):Promise<string>{
  if(!supabase) throw new Error('BuhurtOS is not connected.');
  const {data,error}=await supabase.rpc('create_event_signup_code',{
    p_event:input.eventId,
    p_label:input.label?.trim()||null,
    p_max_uses:input.maxUses??1,
    p_expires_at:input.expiresAt?new Date(input.expiresAt).toISOString():null
  });
  if(error) throw error;
  return String(data??'');
}

export async function listEventSignupCodes(eventId:string):Promise<EventSignupCode[]>{
  if(!supabase) return [];
  const {data,error}=await supabase.rpc('list_event_signup_codes',{p_event:eventId});
  if(error) throw error;
  return (data??[]).map((row:any)=>({
    id:row.id,label:row.label,codePrefix:row.code_prefix,maxUses:Number(row.max_uses??1),
    uses:Number(row.uses??0),expiresAt:row.expires_at??undefined,disabledAt:row.disabled_at??undefined,
    createdAt:row.created_at
  }));
}

export async function disableEventSignupCode(id:string):Promise<void>{
  if(!supabase) throw new Error('BuhurtOS is not connected.');
  const {error}=await supabase.rpc('disable_event_signup_code',{p_code_id:id});
  if(error) throw error;
}
