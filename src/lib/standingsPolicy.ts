import { useEffect, useState } from 'react';
import { listEventCompetitions } from './eventCompetitions';
import { loadTiebreakPolicy, type TiebreakPolicy } from './tiebreak';

/**
 * Which tiebreak policy governs an event's standings. The organizer's competitions decide it: a competition under an
 * authority (BI) uses that authority's stored policy at the document version recorded in its format selection, or the
 * newest stored version when none was recorded. With no competitions, or an authority that has no stored policy, there
 * is no policy and the standings say so.
 */
export async function loadEventTiebreakPolicy(eventId: string): Promise<TiebreakPolicy | undefined> {
  const competitions = await listEventCompetitions(eventId, false);
  const governed = competitions.find(c => c.authority && c.authority !== 'custom');
  if (!governed) return undefined;
  return loadTiebreakPolicy(governed.authority, governed.formatSelection.rulesVersion);
}

/** The policy for the current event; `ready` is false until it has been looked up so boards do not flash the wrong order. */
export function useEventTiebreakPolicy(eventId: string | undefined): { policy?: TiebreakPolicy; ready: boolean } {
  const [state, setState] = useState<{ eventId?: string; policy?: TiebreakPolicy }>();
  useEffect(() => {
    if (!eventId) return;
    let active = true;
    loadEventTiebreakPolicy(eventId)
      .then(policy => { if (active) setState({ eventId, policy }); })
      // A failed lookup must not hide the standings: they fall back to the stated legacy order.
      .catch(() => { if (active) setState({ eventId, policy: undefined }); });
    return () => { active = false; };
  }, [eventId]);
  return { policy: state?.eventId === eventId ? state?.policy : undefined, ready: !eventId || state?.eventId === eventId };
}
