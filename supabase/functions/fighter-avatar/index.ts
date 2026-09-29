import { createClient } from 'npm:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

const extensions = new Map([
  ['image/jpeg', 'jpg'],
  ['image/png', 'png'],
  ['image/webp', 'webp']
]);

const uuid = (value: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);

function response(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }
  });
}

function safePath(identityId: string, path: string | null) {
  return Boolean(path && path.startsWith(`${identityId}/`));
}

Deno.serve(async request => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (request.method !== 'POST') return response(405, { error: 'Method not allowed.' });

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !serviceRoleKey) return response(503, { error: 'Avatar storage is not configured.' });

  const authorization = request.headers.get('authorization') || '';
  const token = authorization.replace(/^Bearer\s+/i, '').trim();
  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false }
  });

  let actorId: string | null = null;
  if (token) {
    const { data } = await admin.auth.getUser(token);
    actorId = data.user?.id || null;
  }

  let form: FormData;
  try {
    form = await request.formData();
  } catch {
    return response(400, { error: 'Invalid multipart form.' });
  }

  const action = String(form.get('action') || '').trim();
  const identityId = String(form.get('identityId') || '').trim();
  if (!uuid(identityId)) return response(400, { error: 'Invalid fighter identity.' });

  const { data: identity, error: identityError } = await admin
    .from('fighter_identities')
    .select('id,avatar_path,profile_visibility,deleted_at,merged_into_identity_id')
    .eq('id', identityId)
    .maybeSingle();
  if (identityError) return response(500, { error: 'Unable to verify fighter identity.' });
  if (!identity || identity.deleted_at || identity.merged_into_identity_id) return response(404, { error: 'Active fighter identity not found.' });

  const controlsIdentity = async () => {
    if (!actorId) return false;
    const { data } = await admin
      .from('fighter_identity_accounts')
      .select('identity_id')
      .eq('identity_id', identityId)
      .eq('user_id', actorId)
      .is('revoked_at', null)
      .maybeSingle();
    return Boolean(data);
  };

  if (action === 'signed-url') {
    const allowed = identity.profile_visibility === 'public' || await controlsIdentity();
    if (!allowed || !safePath(identityId, identity.avatar_path)) return response(404, { error: 'Avatar not available.' });
    const { data, error } = await admin.storage.from('fighter-avatars').createSignedUrl(identity.avatar_path, 60);
    if (error || !data?.signedUrl) return response(500, { error: 'Unable to create avatar URL.' });
    return response(200, { url: data.signedUrl });
  }

  if (!(await controlsIdentity())) return response(403, { error: 'You do not control this fighter identity.' });

  if (action === 'remove') {
    const previousPath = identity.avatar_path as string | null;
    const { error: updateError } = await admin
      .from('fighter_identities')
      .update({ avatar_path: null, last_edited_by: actorId })
      .eq('id', identityId);
    if (updateError) return response(500, { error: 'Unable to remove avatar.' });
    if (safePath(identityId, previousPath)) await admin.storage.from('fighter-avatars').remove([previousPath!]);
    await admin.from('audit_log').insert({ actor_user_id: actorId, table_name: 'fighter_identities', record_id: identityId, action: 'remove_fighter_avatar', payload: {} });
    return response(200, { removed: true });
  }

  if (action !== 'upload') return response(400, { error: 'Unknown avatar action.' });
  const file = form.get('file');
  if (!(file instanceof File)) return response(400, { error: 'An image file is required.' });
  if (file.size < 1 || file.size > 5 * 1024 * 1024) return response(400, { error: 'Avatar image must be between 1 byte and 5 MB.' });
  const extension = extensions.get(file.type);
  if (!extension) return response(400, { error: 'Avatar must be a JPEG, PNG, or WebP image.' });

  const path = `${identityId}/${crypto.randomUUID()}.${extension}`;
  const { error: uploadError } = await admin.storage.from('fighter-avatars').upload(path, new Uint8Array(await file.arrayBuffer()), {
    contentType: file.type,
    cacheControl: '3600',
    upsert: false
  });
  if (uploadError) return response(500, { error: 'Unable to store avatar image.' });

  const previousPath = identity.avatar_path as string | null;
  const { error: updateError } = await admin
    .from('fighter_identities')
    .update({ avatar_path: path, last_edited_by: actorId })
    .eq('id', identityId);
  if (updateError) {
    await admin.storage.from('fighter-avatars').remove([path]);
    return response(500, { error: 'Unable to attach avatar to fighter identity.' });
  }
  if (safePath(identityId, previousPath)) await admin.storage.from('fighter-avatars').remove([previousPath!]);
  await admin.from('audit_log').insert({
    actor_user_id: actorId,
    table_name: 'fighter_identities',
    record_id: identityId,
    action: 'upload_fighter_avatar',
    payload: { mimeType: file.type, size: file.size, replacedExisting: Boolean(previousPath) }
  });
  return response(200, { uploaded: true });
});
