import { svelte } from '@sveltejs/vite-plugin-svelte';
import resolve from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import polyfillNode from 'rollup-plugin-polyfill-node';
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  define: {
    global: 'globalThis',
    'process.env.NODE_DEBUG': false,
    'process.env.LINK_API_URL': false,
    'process.env.SDK_VERSION': "'unknown'",
  },
  plugins: [svelte(), resolve(),
  commonjs(), polyfillNode()],
});
