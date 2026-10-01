import { useEffect, useRef, useState } from 'react';
import { supabase } from '../lib/supabase';
import { EVENT_IMAGE_ALT_MAX, eventImageThumbUrl, eventImageUrl, fallbackToOriginalImage, removeEventImage, setEventImageAlt, uploadEventImage } from '../lib/eventMedia';
import { friendlyError } from '../lib/friendlyError';
import { isMissingColumnError } from '../lib/publicDirectory';

/** Organizer tool: upload, replace or remove the public event poster, and describe it for people who cannot see it. */
export function EventMediaPanel({ eventId, eventName }: { eventId: string; eventName?: string }) {
  const [path, setPath] = useState<string>();
  const [alt, setAlt] = useState('');
  const [savedAlt, setSavedAlt] = useState('');
  const [altSupported, setAltSupported] = useState(true);
  const [available, setAvailable] = useState(true);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const input = useRef<HTMLInputElement>(null);

  useEffect(() => {
    let active = true;
    if (!supabase) { setAvailable(false); return; }
    (async () => {
      let { data, error } = await supabase!.from('events').select('image_path,image_alt').eq('id', eventId).maybeSingle();
      let hasAlt = true;
      if (error && isMissingColumnError(error)) {
        hasAlt = false;
        ({ data, error } = await supabase!.from('events').select('image_path').eq('id', eventId).maybeSingle());
      }
      if (!active) return;
      if (error) { setAvailable(false); return; }
      const row = data as { image_path?: string | null; image_alt?: string | null } | null;
      setPath(row?.image_path ?? undefined);
      setAltSupported(hasAlt);
      setAlt(row?.image_alt ?? ''); setSavedAlt(row?.image_alt ?? '');
    })();
    return () => { active = false; };
  }, [eventId]);

  async function onFile(file: File | undefined) {
    if (!file) return;
    setBusy(true); setMessage('');
    try {
      setPath(await uploadEventImage(eventId, file, path));
      setMessage('Poster saved. It now appears on the public event page. Add a description below so everyone can follow it.');
    } catch (err) {
      setMessage(friendlyError(err).message);
    } finally {
      setBusy(false);
      if (input.current) input.current.value = '';
    }
  }

  async function onRemove() {
    if (!path || !window.confirm('Remove the event poster?')) return;
    setBusy(true); setMessage('');
    try { await removeEventImage(eventId, path); setPath(undefined); setAlt(''); setSavedAlt(''); setMessage('Poster removed.'); }
    catch (err) { setMessage(friendlyError(err).message); }
    finally { setBusy(false); }
  }

  async function onSaveAlt() {
    setBusy(true); setMessage('');
    try { await setEventImageAlt(eventId, alt); setSavedAlt(alt.trim()); setAlt(alt.trim()); setMessage(alt.trim() ? 'Description saved.' : 'Description cleared. The poster will be announced as “' + (eventName ?? 'Event') + ' poster”.'); }
    catch (err) { setMessage(friendlyError(err).message); }
    finally { setBusy(false); }
  }

  return <section className="panel-card">
    <h2>Event poster</h2>
    {!available
      ? <p className="hint">Event media is not available on this backend yet.</p>
      : <div className="form-stack">
        {path ? <img className="event-media-preview" src={eventImageThumbUrl(path, 640) ?? eventImageUrl(path)} onError={fallbackToOriginalImage(path)} alt={savedAlt || (eventName ? eventName + ' poster' : 'Current event poster')} loading="lazy" /> : <p className="hint">No poster yet. Upload a JPG, PNG or WebP image; it is resized and optimized automatically.</p>}
        <input ref={input} type="file" accept="image/jpeg,image/png,image/webp" hidden onChange={e => onFile(e.target.files?.[0])} />
        <div className="header-actions">
          <button className="primary" type="button" disabled={busy} onClick={() => input.current?.click()}>{busy ? 'Working…' : path ? 'Replace poster' : 'Upload poster'}</button>
          {path ? <button type="button" disabled={busy} onClick={onRemove}>Remove</button> : null}
        </div>
        {path && altSupported ? <div className="form-stack">
          <label>Poster description (for people who cannot see the image)
            <textarea rows={2} maxLength={EVENT_IMAGE_ALT_MAX} value={alt} onChange={e => setAlt(e.target.value)} placeholder="For example: Red Deer Rumble poster, two armored teams meeting at a ranch in November" />
          </label>
          <small className="hint">{alt.length}/{EVENT_IMAGE_ALT_MAX}. Leave empty to use “{eventName ?? 'the event name'} poster”.</small>
          <div className="header-actions"><button type="button" disabled={busy || alt.trim() === savedAlt} onClick={onSaveAlt}>Save description</button></div>
        </div> : null}
        {path && !altSupported ? <p className="hint">Poster descriptions are not available on this backend yet.</p> : null}
        {message ? <p className="hint" role="status">{message}</p> : null}
      </div>}
  </section>;
}
