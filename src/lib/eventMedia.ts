import { supabase } from './supabase';

export const EVENT_MEDIA_BUCKET = 'event-media';
export const EVENT_MEDIA_MAX_BYTES = 5 * 1024 * 1024;
export const EVENT_MEDIA_TYPES = ['image/jpeg', 'image/png', 'image/webp'] as const;
const MAX_EDGE = 1600;

const baseUrl = (import.meta.env.VITE_SUPABASE_URL as string | undefined)?.replace(/\/$/, '');

/** Public URL for a stored poster path, or undefined when storage is not configured. */
export function eventImageUrl(path: string | undefined | null): string | undefined {
  if (!path || !baseUrl) return undefined;
  return `${baseUrl}/storage/v1/object/public/${EVENT_MEDIA_BUCKET}/${path.split('/').map(encodeURIComponent).join('/')}`;
}

/**
 * Smaller renditions via Supabase image transformation. The hosted project does not have transformations
 * enabled (the render endpoint answers 403 FeatureNotEnabled), so this returns the original object URL
 * unless VITE_SUPABASE_IMAGE_TRANSFORMS is "true".
 */
export function eventImageThumbUrl(path: string | undefined | null, width = 480): string | undefined {
  if (!path || !baseUrl) return undefined;
  if (import.meta.env.VITE_SUPABASE_IMAGE_TRANSFORMS !== 'true') return eventImageUrl(path);
  return `${baseUrl}/storage/v1/render/image/public/${EVENT_MEDIA_BUCKET}/${path.split('/').map(encodeURIComponent).join('/')}?width=${width}&quality=75&resize=contain`;
}

/** onError handler: fall back to the original object when a rendition fails to load. */
export function fallbackToOriginalImage(path: string | undefined | null) {
  return (e: { currentTarget: HTMLImageElement }) => {
    const url = eventImageUrl(path);
    if (url && e.currentTarget.src !== url) e.currentTarget.src = url;
  };
}

export function validateEventMediaFile(file: { type: string; size: number }): string | undefined {
  if (!(EVENT_MEDIA_TYPES as readonly string[]).includes(file.type)) return 'Use a JPG, PNG or WebP image.';
  if (file.size > EVENT_MEDIA_MAX_BYTES * 4) return 'That image is too large. Choose one under 20 MB.';
  return undefined;
}

export function scaleToFit(width: number, height: number, maxEdge = MAX_EDGE): { width: number; height: number } {
  const longest = Math.max(width, height);
  if (longest <= maxEdge) return { width, height };
  const ratio = maxEdge / longest;
  return { width: Math.round(width * ratio), height: Math.round(height * ratio) };
}

/** Client-side optimization: downscale to 1600px on the long edge and re-encode as WebP. */
export async function optimizeEventImage(file: File): Promise<{ blob: Blob; ext: 'webp' | 'jpg' | 'png'; type: string }> {
  const bitmap = await createImageBitmap(file);
  const { width, height } = scaleToFit(bitmap.width, bitmap.height);
  const canvas = document.createElement('canvas');
  canvas.width = width;
  canvas.height = height;
  const ctx = canvas.getContext('2d');
  if (!ctx) throw new Error('Image processing is not available in this browser.');
  ctx.drawImage(bitmap, 0, 0, width, height);
  const blob: Blob | null = await new Promise(resolve => canvas.toBlob(resolve, 'image/webp', 0.85));
  if (blob && blob.size <= EVENT_MEDIA_MAX_BYTES) return { blob, ext: 'webp', type: 'image/webp' };
  if (file.size <= EVENT_MEDIA_MAX_BYTES) {
    return { blob: file, ext: file.type === 'image/png' ? 'png' : 'jpg', type: file.type };
  }
  throw new Error('That image is still over 5 MB after optimization. Choose a smaller image.');
}

export async function uploadEventImage(eventId: string, file: File, previousPath?: string): Promise<string> {
  if (!supabase) throw new Error('Event media needs a connected BuhurtOS backend.');
  const problem = validateEventMediaFile(file);
  if (problem) throw new Error(problem);
  const { blob, ext, type } = await optimizeEventImage(file);
  const path = `${eventId}/poster-${Date.now()}.${ext}`;
  const { error: uploadError } = await supabase.storage.from(EVENT_MEDIA_BUCKET).upload(path, blob, { contentType: type, cacheControl: '31536000', upsert: false });
  if (uploadError) throw uploadError;
  const { error: rpcError } = await supabase.rpc('set_event_image', { p_event: eventId, p_path: path });
  if (rpcError) {
    await supabase.storage.from(EVENT_MEDIA_BUCKET).remove([path]);
    throw rpcError;
  }
  if (previousPath && previousPath !== path) await supabase.storage.from(EVENT_MEDIA_BUCKET).remove([previousPath]);
  return path;
}

export async function removeEventImage(eventId: string, path: string): Promise<void> {
  if (!supabase) throw new Error('Event media needs a connected BuhurtOS backend.');
  const { error: rpcError } = await supabase.rpc('set_event_image', { p_event: eventId, p_path: null });
  if (rpcError) throw rpcError;
  await supabase.storage.from(EVENT_MEDIA_BUCKET).remove([path]);
}
