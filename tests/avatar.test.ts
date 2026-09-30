import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { clearAvatarCache, getAvatarUrl } from '../src/lib/avatarUrl';
import { FighterAvatar } from '../src/components/FighterAvatar';

beforeEach(() => clearAvatarCache());

describe('public fighter photos', () => {
  it('asks the avatar function for a short-lived URL and caches it briefly', async () => {
    const load = vi.fn().mockResolvedValue('https://signed.example/a.jpg');
    let t = 1000;
    expect(await getAvatarUrl('f1', false, () => t, load)).toBe('https://signed.example/a.jpg');
    t += 10_000;
    expect(await getAvatarUrl('f1', false, () => t, load)).toBe('https://signed.example/a.jpg');
    expect(load).toHaveBeenCalledTimes(1);
    t += 60_000;
    await getAvatarUrl('f1', false, () => t, load);
    expect(load).toHaveBeenCalledTimes(2);
  });

  it('shares one in-flight request and can force a refresh', async () => {
    const load = vi.fn().mockResolvedValue('u');
    await Promise.all([getAvatarUrl('f2', false, Date.now, load), getAvatarUrl('f2', false, Date.now, load)]);
    expect(load).toHaveBeenCalledTimes(1);
    await getAvatarUrl('f2', true, Date.now, load);
    expect(load).toHaveBeenCalledTimes(2);
  });

  it('turns a failed lookup into "no photo" instead of a broken image', async () => {
    const load = vi.fn().mockRejectedValue(new Error('nope'));
    expect(await getAvatarUrl('f3', false, Date.now, load)).toBeNull();
  });

  it('renders the fallback (initials) until a URL is available and when there is no photo', () => {
    const fallback = createElement('span', { className: 'initials' }, 'GR');
    const withPhoto = renderToStaticMarkup(createElement(FighterAvatar, { identityId: 'f1', hasPhoto: true, alt: 'Garrett', fallback }));
    expect(withPhoto).toContain('initials');
    expect(withPhoto).not.toContain('<img');
    const without = renderToStaticMarkup(createElement(FighterAvatar, { identityId: 'f1', hasPhoto: false, alt: 'Garrett', fallback }));
    expect(without).toContain('initials');
  });
});
