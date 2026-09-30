import { beforeEach, describe, expect, it, vi } from 'vitest';
const auth = vi.hoisted(() => ({ signOut: vi.fn() }));
vi.mock('../src/lib/supabase', () => ({ supabase: { auth } }));
import { signOut } from '../src/lib/auth';
const values = new Map<string, string>();
beforeEach(() => {
  values.clear();
  vi.stubGlobal('sessionStorage', {
    setItem: (key: string, value: string) => values.set(key, value),
    removeItem: (key: string) => values.delete(key)
  });
  auth.signOut.mockReset();
});
describe('sign out', () => {
  it('ends this session without ending sessions on other devices', async () => {
    auth.signOut.mockResolvedValue({ error: null });
    await signOut();
    expect(auth.signOut).toHaveBeenCalledWith({ scope: 'local' });
    expect(values.get('buhurtos:intentional-signout')).toBe('1');
  });
  it('reports failure and removes the intentional signout marker', async () => {
    auth.signOut.mockResolvedValue({ error: new Error('Network unavailable') });
    await expect(signOut()).rejects.toThrow('Network unavailable');
    expect(values.has('buhurtos:intentional-signout')).toBe(false);
  });
});
