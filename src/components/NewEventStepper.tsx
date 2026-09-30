import { useState } from 'react';
import { eventCategoryLabels, eventCategoryOrder, isCompetitionCapable, type EventCategory } from '../lib/eventCategories';

export interface NewEventValues {
  name: string; venue: string; startsAt: string; endsAt: string; timezone: string; eventType: EventCategory;
}

const purposes: Partial<Record<EventCategory, string>> = {
  tournament: 'Fighters compete. You will set up competitions, registration, structure and marshals.',
  exhibition: 'A show for promotion, with or without points. Competition steps are available.',
  demo: 'A demonstration for the public. Competition steps are available if you want them.',
  training: 'A practice or training session. No tournament setup.',
  clinic_workshop: 'Teaching or workshop day. No tournament setup.',
  recruitment: 'Meet new people and grow your team. No tournament setup.',
  fundraiser: 'Raise money for a team or cause. No tournament setup.',
  gathering_social: 'A social event or get-together. No tournament setup.',
  meeting_agm: 'A meeting or annual general meeting. No tournament setup.',
  community_appearance: 'A public or community appearance. No tournament setup.',
  custom: 'Something else. Competition steps are available if you need them.'
};

/**
 * Creating an event in two short steps. The draft is saved when you finish step two and you land in the setup guide,
 * which owns everything after that (and works the same for events that already exist).
 */
export function NewEventStepper({ busy, initial, onCreate }: { busy: boolean; initial: NewEventValues; onCreate: (values: NewEventValues) => void }) {
  const [step, setStep] = useState<1 | 2>(1);
  const [values, setValues] = useState<NewEventValues>(initial);
  const set = (patch: Partial<NewEventValues>) => setValues(current => ({ ...current, ...patch }));

  const missing = [!values.name.trim() && 'a name', !values.venue.trim() && 'a venue', !values.startsAt && 'a start date and time', !values.endsAt && 'an end date and time'].filter(Boolean) as string[];
  const datesBackwards = Boolean(values.startsAt && values.endsAt && new Date(values.endsAt) < new Date(values.startsAt));

  return <section className="panel-card" aria-labelledby="new-event-title">
    <h2 id="new-event-title">New event</h2>
    <p className="hint">Step {step} of 2 · {step === 1 ? 'Basics' : 'What kind of event is this?'}. Your draft is saved at the end of step 2, and setup continues in the setup guide.</p>
    {step === 1 ? <div className="form-stack">
      <label>Event name<input value={values.name} onChange={e => set({ name: e.target.value })} placeholder="Red Deer Rumble" /></label>
      <label>Venue<input value={values.venue} onChange={e => set({ venue: e.target.value })} placeholder="Where it happens" /></label>
      <label>Starts<input type="datetime-local" value={values.startsAt} onChange={e => set({ startsAt: e.target.value })} /></label>
      <label>Ends<input type="datetime-local" value={values.endsAt} onChange={e => set({ endsAt: e.target.value })} /></label>
      <label>Time zone<input value={values.timezone} onChange={e => set({ timezone: e.target.value })} /></label>
      {datesBackwards ? <p className="auth-message" role="alert">The event ends before it starts. Check the dates.</p> : null}
      {missing.length ? <p className="hint">Still needed: {missing.join(', ')}.</p> : null}
      <button className="primary" type="button" disabled={missing.length > 0 || datesBackwards} onClick={() => setStep(2)}>Next: what kind of event?</button>
    </div> : <div className="form-stack">
      <fieldset>
        <legend>Purpose</legend>
        {eventCategoryOrder.map(category => <label key={category} className="fighter-signup-consent">
          <input type="radio" name="event-purpose" checked={values.eventType === category} onChange={() => set({ eventType: category })} />
          <span><b>{eventCategoryLabels[category]}</b><br /><small>{purposes[category]}</small></span>
        </label>)}
      </fieldset>
      <p className="hint">{isCompetitionCapable(values.eventType) ? 'Competition setup will appear in the setup guide.' : 'Tournament-only steps will be skipped for this kind of event.'}</p>
      <div className="header-actions">
        <button type="button" onClick={() => setStep(1)}>Back</button>
        <button className="primary" type="button" disabled={busy} onClick={() => onCreate(values)}>{busy ? 'Creating…' : 'Create draft and continue'}</button>
      </div>
    </div>}
  </section>;
}
