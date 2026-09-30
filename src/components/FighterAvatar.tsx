import { useEffect, useState, type ReactNode } from 'react';
import { getAvatarUrl } from '../lib/avatarUrl';

/** A fighter's photo, or the fallback (initials) when there is none or it cannot be loaded. */
export function FighterAvatar({ identityId, hasPhoto, alt, className, fallback }: {
  identityId: string; hasPhoto: boolean; alt: string; className?: string; fallback: ReactNode;
}) {
  const [url, setUrl] = useState<string | null>(null);
  const [retried, setRetried] = useState(false);

  useEffect(() => {
    setUrl(null); setRetried(false);
    if (!hasPhoto) return;
    let active = true;
    getAvatarUrl(identityId).then(next => { if (active) setUrl(next); });
    return () => { active = false; };
  }, [identityId, hasPhoto]);

  if (!hasPhoto || !url) return <>{fallback}</>;
  return <img className={className} src={url} alt={alt} loading="lazy" decoding="async"
    onError={() => {
      // The short-lived link may have expired; ask once more, then fall back to initials.
      if (retried) { setUrl(null); return; }
      setRetried(true);
      getAvatarUrl(identityId, true).then(next => setUrl(next));
    }} />;
}
