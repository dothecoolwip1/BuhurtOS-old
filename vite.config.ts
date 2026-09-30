import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import swPrecachePlugin from './scripts/swPrecachePlugin.mjs';

export default defineConfig(({ mode }) => ({
  base: mode === 'github-pages' ? '/BuhurtOS/' : '/',
  plugins: [react(), swPrecachePlugin()],
  build: {
    target: 'es2022',
    sourcemap: false
  },
  server: { host: true }
}));
