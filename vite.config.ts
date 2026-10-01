import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import swPrecachePlugin from './scripts/swPrecachePlugin.mjs';

export default defineConfig(({ mode }) => ({
  // GitHub Pages serves this repo at /BuhurtOS-old/ since the rename.
  base: mode === 'github-pages' ? '/BuhurtOS-old/' : '/',
  plugins: [react(), swPrecachePlugin()],
  build: {
    target: 'es2022',
    sourcemap: false
  },
  server: { host: true }
}));
