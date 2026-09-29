import { describe, expect, it } from 'vitest';
import { validateFighterAvatar } from '../src/lib/fighterIdentity';

describe('fighter avatar validation', () => {
  it('accepts bounded JPEG, PNG, and WebP images', () => {
    expect(validateFighterAvatar({ type: 'image/jpeg', size: 1 })).toEqual([]);
    expect(validateFighterAvatar({ type: 'image/png', size: 5 * 1024 * 1024 })).toEqual([]);
    expect(validateFighterAvatar({ type: 'image/webp', size: 512 })).toEqual([]);
  });

  it('rejects unsupported or oversized files before upload', () => {
    expect(validateFighterAvatar({ type: 'image/gif', size: 20 })).toContain('Avatar must be a JPEG, PNG, or WebP image.');
    expect(validateFighterAvatar({ type: 'image/png', size: 5 * 1024 * 1024 + 1 })).toContain('Avatar image must be between 1 byte and 5 MB.');
  });
});
