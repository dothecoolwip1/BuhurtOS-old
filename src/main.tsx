import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './App';
import { PreviewModeProvider } from './features/PreviewMode';
import { UpdateBanner } from './components/UpdateBanner';
import { recoverFromStaleChunks, registerServiceWorker } from './lib/pwa';
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
      <UpdateBanner/>
    </PreviewModeProvider>
  </StrictMode>
);

recoverFromStaleChunks();
registerServiceWorker(import.meta.env.BASE_URL);
