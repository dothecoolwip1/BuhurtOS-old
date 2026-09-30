import { useEffect } from 'react';

/** Puts a specific name in the tab title (and so in bookmarks and shared links' fallback text) once a detail page has loaded. */
export function useDocumentTitle(name: string | undefined, kind?: string): void {
  useEffect(() => {
    if (!name) return;
    document.title = `${name}${kind ? ' · ' + kind : ''} · BuhurtOS`;
  }, [name, kind]);
}
