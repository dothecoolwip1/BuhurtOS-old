/**
 * One place that turns any thrown value (PostgREST, RLS, network, application messages) into something a person can
 * act on. Raw detail is logged for developers and never shown.
 */
export type ErrorAction = 'retry' | 'sign_in' | 'contact_organizer' | 'return_to_event' | 'use_code';

export interface FriendlyError {
  message: string;
  action: ErrorAction;
}

type ErrorLike = { message?: unknown; code?: unknown; status?: unknown; details?: unknown; hint?: unknown };

function asLike(error: unknown): ErrorLike {
  return error && typeof error === 'object' ? (error as ErrorLike) : { message: typeof error === 'string' ? error : undefined };
}

/** Messages raised deliberately by BuhurtOS database functions are written for people; everything else is not. */
const APPLICATION_ERROR_CODE = 'P0001';

export function friendlyError(error: unknown, options: { log?: boolean } = {}): FriendlyError {
  const { message, code, status } = asLike(error);
  const text = typeof message === 'string' ? message : '';
  const codeText = typeof code === 'string' ? code : '';
  if (options.log !== false) console.error('[BuhurtOS]', error);

  if (codeText === APPLICATION_ERROR_CODE && text) {
    if (/signup code|code not recognized|code has|code is/i.test(text)) return { message: text, action: 'use_code' };
    return { message: text, action: 'contact_organizer' };
  }
  if (/jwt|not authenticated|sign in|authentication required/i.test(text) || status === 401) {
    return { message: 'Please sign in to continue.', action: 'sign_in' };
  }
  if (codeText === '42501' || /permission denied|row-level security|not allowed/i.test(text) || status === 403) {
    return { message: 'Your account does not have access to do that. If you think it should, contact the organizer.', action: 'contact_organizer' };
  }
  if (/failed to fetch|networkerror|network request failed|load failed/i.test(text)) {
    return { message: 'We could not reach BuhurtOS. Check your connection and try again.', action: 'retry' };
  }
  if (/schema cache|could not find the function|PGRST20\d|42883/i.test(text + codeText)) {
    return { message: 'This feature is not available yet on this server. Please try again later or contact the organizer.', action: 'contact_organizer' };
  }
  return { message: 'Something went wrong on our side. Please try again.', action: 'retry' };
}
