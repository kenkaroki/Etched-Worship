// ============================================================
//  src/routes/+layout.ts
//  Root layout server-side options.
//
//  `prerender = true` tells adapter-static to pre-render every
//  page in the app into a static HTML file at build time.
//
//  `trailingSlash = 'always'` ensures GitHub Pages serves
//  `/download/` correctly (GH Pages needs trailing slashes for
//  directory-based routing to work without a custom 404 fallback).
// ============================================================

export const prerender = true;
export const trailingSlash = 'always';
