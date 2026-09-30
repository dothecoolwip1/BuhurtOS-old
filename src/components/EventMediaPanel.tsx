import { useEffect, useRef, useState } from 'react';
import { supabase } from '../lib/supabase';
import { eventImageThumbUrl, eventImageUrl, removeEventImage, uploadEventImage } from '../lib/eventMedia';

/** Organizer tool: upload, replace or remove the public event poster. */
export function EventMediaPanel({ eventId }: { eventId: string }) {
  const [path, setPath] = useState<string>();
  const [available, setAvailable] = useState(true);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const input = useRef<HTMLInputElement>(null);

  useEffect(() => {
    let active = true;
    if (!supabase) { setAvailable(false); return; }
    supabase.from('events').select('image_path').eq('id', eventId).maybeSingle().then(({ data, error }) => {
      if (!active) return;
      if (error) { setAvailable(false); return; }
      setPath((data as { image_path?: string | null } | null)?.image_path ?? undefined);
    });
    return () => { active = false; };
  }, [eventId]);

  async function onFile(file: File | undefined) {
    if (!file) return;
    setBusy(true); setMessage('');
    try {
      setPath(await uploadEventImage(eventId, file, path));
      setMessage('Poster saved. It now appears on the public event page.');
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Upload failed.');
    } finally {
      setBusy(false);
      if (input.current) input.current.value = '';
    }
  }

  async function onRemove() {
    if (!path || !window.confirm('Remove the event poster?')) return;
    setBusy(true); setMessage('');
    try { await removeEventImage(eventId, path); setPath(undefined); setMessage('Poster removed.'); }
    catch (err) { setMessage(err instanceof Error ? err.message : 'Could not remove the poster.'); }
    finally { setBusy(false); }
  }

  return <section className="panel-card">
    <h2>Event poster</h2>
    {!available
      ? <p className="hint">Event media is not available on this backend yet.</p>
      : <div className="form-stack">
        {path ? <img className="event-media-preview" src={eventImageThumbUrl(path, 640) ?? eventImageUrl(path)} onError={e => { const url = eventImageUrl(path); if (url && e.currentTarget.src !== url) e.currentTarget.src = url; }} alt="Current event poster" loading="lazy" /> : <p className="hint">No poster yet. Upload a JPG, PNG or WebP image; it is resized and optimized automatically.</p>}
        <input ref={input} type="file" accept="image/jpeg,image/png,image/webp" hidden onChange={e => onFile(e.target.files?.[0])} />
        <div className="header-actions">
          <button className="primary" type="button" disabled={busy} onClick={() => input.current?.click()}>{busy ? 'Working…' : path ? 'Replace poster' : 'Upload poster'}</button>
          {path ? <button type="button" disabled={busy} onClick={onRemove}>Remove</button> : null}
        </div>
        {message ? <p className="hint" role="status">{message}</p> : null}
      </div>}
  </section>;
}
