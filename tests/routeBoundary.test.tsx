import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it } from 'vitest';
import { NotFoundPage, RouteBoundary } from '../src/components/RouteBoundary';
import chromeSource from '../src/components/chrome.tsx?raw';
import appSource from '../src/App.tsx?raw';

describe('404 page', () => {
  it('explains the dead end and offers ways on instead of redirecting', () => {
    const html = renderToStaticMarkup(createElement(MemoryRouter, { initialEntries: ['/nope/nothing'] }, createElement(NotFoundPage)));
    expect(html).toContain('nothing at this address');
    expect(html).toContain('/nope/nothing');
    expect(html).toContain('Browse events');
  });
  it('is what unknown routes render, at the top level and inside administration', () => {
    expect(appSource.match(/path="\*" element=\{<NotFoundPage\/>\}/g)?.length).toBe(2);
  });
});

describe('route error boundary', () => {
  it('wraps every route and passes healthy pages through unchanged', () => {
    expect(appSource).toContain('<RouteBoundary>');
    const ok = renderToStaticMarkup(createElement(MemoryRouter, null, createElement(RouteBoundary, null, createElement('p', null, 'fine'))));
    expect(ok).toContain('fine');
  });
});

describe('menu sheet accessibility', () => {
  it('makes the page behind an open sheet inert and traps Tab inside it', () => {
    expect(chromeSource.match(/inert=\{menuOpen\}/g)?.length).toBe(3);
    expect(chromeSource).toContain("event.key !== 'Tab'");
    expect(chromeSource).toContain('aria-modal="true"');
  });
});
