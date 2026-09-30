import { useEffect, useState } from 'react';
import { applyServiceWorkerUpdate, UPDATE_READY_EVENT } from '../lib/pwa';

/** Small, dismissible "new version" bar. Reloading is always the visitor's choice. */
export function UpdateBanner() {
  const [registration, setRegistration] = useState<ServiceWorkerRegistration>();
  useEffect(() => {
    const onReady = (event: Event) => setRegistration((event as CustomEvent<{ registration: ServiceWorkerRegistration }>).detail.registration);
    window.addEventListener(UPDATE_READY_EVENT, onReady);
    return () => window.removeEventListener(UPDATE_READY_EVENT, onReady);
  }, []);
  if (!registration) return null;
  return <div className="update-banner" role="status">
    <span>A new version of BuhurtOS is ready.</span>
    <button type="button" onClick={() => applyServiceWorkerUpdate(registration)}>Reload to update</button>
    <button type="button" className="quiet" aria-label="Dismiss update notice" onClick={() => setRegistration(undefined)}>Later</button>
  </div>;
}
