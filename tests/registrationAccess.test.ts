import { describe, expect, it, vi } from 'vitest';
import { describeAccess, scopeLabels, snapshotNote, type RegistrationAccessState } from '../src/lib/registrationAccess';
import { friendlyError } from '../src/lib/friendlyError';

const states: RegistrationAccessState[] = ['eligible', 'code_required', 'permission_requested', 'permission_granted', 'denied', 'already_registered', 'registration_closed', 'membership_unverified', 'error'];

describe('registration access copy', () => {
  it('has plain copy and a next step for every server-decided state', () => {
    for (const state of states) {
      const copy = describeAccess(state);
      expect(copy.title.length).toBeGreaterThan(10);
      expect(copy.body.length).toBeGreaterThan(10);
      expect(copy.title + copy.body).not.toMatch(/sql|rls|postgrest|violates|constraint/i);
    }
  });
  it('lets eligible and granted fighters continue without a code', () => {
    expect(describeAccess('eligible').next).toBe('continue');
    expect(describeAccess('permission_granted').next).toBe('continue');
  });
  it('offers permission request plus code when access cannot be verified', () => {
    expect(describeAccess('membership_unverified').next).toBe('request_or_code');
  });
  it('keeps the code flow for external, denied and errored callers', () => {
    for (const state of ['code_required', 'denied', 'permission_requested', 'error'] as const) expect(describeAccess(state).next).toBe('enter_code');
  });
  it('never dead-ends: closed and already-registered explain what happens next', () => {
    expect(describeAccess('registration_closed').body).toMatch(/event page|organizer/i);
    expect(describeAccess('already_registered').body).toMatch(/follow up/i);
  });
  it('describes every access scope', () => {
    for (const key of ['invite_only', 'host_team', 'organization', 'organization_tree', 'open'] as const) expect(scopeLabels[key].help.length).toBeGreaterThan(10);
  });
  it('explains why a request was needed from its snapshot', () => {
    expect(snapshotNote({ state: 'membership_unverified' })).toMatch(/no active team membership/i);
    expect(snapshotNote(undefined)).toMatch(/no eligibility details/i);
  });
});

describe('friendlyError', () => {
  const quiet = { log: false };
  it('passes through deliberate application messages and points to the code flow', () => {
    const e = friendlyError({ code: 'P0001', message: 'A signup code is required for this event' }, quiet);
    expect(e.message).toBe('A signup code is required for this event');
    expect(e.action).toBe('use_code');
  });
  it('never shows raw database or API wording', () => {
    const e = friendlyError({ code: '23505', message: 'duplicate key value violates unique constraint "x_idx"' }, quiet);
    expect(e.message).not.toMatch(/duplicate|constraint|violates/i);
    expect(e.action).toBe('retry');
  });
  it('maps permission, sign-in and network failures to recovery actions', () => {
    expect(friendlyError({ code: '42501', message: 'permission denied for table x' }, quiet).action).toBe('contact_organizer');
    expect(friendlyError({ message: 'JWT expired' }, quiet).action).toBe('sign_in');
    expect(friendlyError(new TypeError('Failed to fetch'), quiet).action).toBe('retry');
  });
  it('explains demo mode instead of blaming the server', () => {
    expect(friendlyError(new Error('BuhurtOS is not connected.'), quiet).message).toMatch(/demo mode/i);
  });
  it('logs the raw error for developers', () => {
    const spy = vi.spyOn(console, 'error').mockImplementation(() => undefined);
    friendlyError(new Error('boom'));
    expect(spy).toHaveBeenCalled();
    spy.mockRestore();
  });
});
