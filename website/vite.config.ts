// ============================================================
//  vite.config.ts
//  Vite + SvelteKit configuration for the Etched Worship website.
//  Uses adapter-static so the site can be deployed as a plain
//  set of HTML/CSS/JS files (e.g. to GitHub Pages).
// ============================================================

import adapter from "@sveltejs/adapter-static";
import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";

const base = "/Etched-Worship";

export default defineConfig({
  base,

  plugins: [
    sveltekit({
      compilerOptions: {
        // Force runes mode for the entire project (except node_modules).
        // This can be removed once Svelte 6 is stable.
        runes: ({ filename }) =>
          filename.split(/[/\\]/).includes("node_modules") ? undefined : true,
      },

      paths: {
        base,
      },

      // ── Static adapter ──────────────────────────────────────
      // Produces a fully pre-rendered static site in the `build/`
      // directory that can be served from any static host.
      //
      // `fallback: '404.html'` enables client-side routing on
      // GitHub Pages: GH Pages serves 404.html for unknown URLs,
      // which SvelteKit then uses as its SPA shell to handle the
      // route on the client side.
      adapter: adapter({
        pages: "build",
        assets: "build",
        fallback: "404.html",
        precompress: false,
        strict: true,
      }),
    }),
  ],
});
