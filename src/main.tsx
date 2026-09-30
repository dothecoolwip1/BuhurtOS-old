import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './App';
import { PreviewModeProvider } from './features/PreviewMode';
import './styles.css';

const params = new URLSearchParams(window.location.search);
const requestedRoute = params.get('go');
if (requestedRoute) {
  const cleanRoute = requestedRoute.startsWith('/') ? requestedRoute : '/' + requestedRoute;
  const passthrough = new URLSearchParams(params);
  passthrough.delete('go');
  const query = passthrough.toString();
  window.history.replaceState(null, '', window.location.pathname + (query ? '?' + query : '') + '#' + cleanRoute);
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <PreviewModeProvider>
      <App/>
    </PreviewModeProvider>
  </StrictMode>
);

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register(import.meta.env.BASE_URL + 'sw.js').catch(() => undefined);
  });
}
