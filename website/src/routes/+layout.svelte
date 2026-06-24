<!-- ============================================================
  +layout.svelte
  Root layout — wraps every page with the Navbar, main content
  area, and Footer. Also imports the global CSS design system.
  ============================================================ -->
<script lang="ts">
  // Global design tokens and base styles
  import '../app.css';

  // Shared layout components
  import Navbar from '$lib/components/Navbar.svelte';
  import Footer from '$lib/components/Footer.svelte';

  // Svelte 5 runes mode: `children` is the snippet that renders
  // the current page's content (replaces the legacy <slot /> API)
  import type { Snippet } from 'svelte';
  const { children }: { children: Snippet } = $props();
</script>

<!-- Skip-to-content link for keyboard / screen-reader users -->
<a href="#main-content" class="skip-link">Skip to main content</a>

<!-- Sticky top navigation -->
<Navbar />

<!-- Page content slot — each route's +page.svelte renders here -->
<main id="main-content" tabindex="-1">
  <!-- {@render children()} is the Svelte 5 replacement for <slot /> -->
  {@render children()}
</main>

<!-- Site-wide footer -->
<Footer />

<style>
  /* ── Skip link (accessibility) ────────────────────────────
     Hidden until focused via keyboard Tab key            */
  .skip-link {
    position: absolute;
    top: -100%;
    left: var(--space-4);
    z-index: 9999;
    padding: var(--space-2) var(--space-4);
    background: var(--color-primary);
    color: #fff;
    font-weight: 600;
    border-radius: 0 0 var(--radius-sm) var(--radius-sm);
    transition: top var(--transition-fast);
    text-decoration: none;
  }

  .skip-link:focus {
    /* Bring into view when focused */
    top: 0;
  }

  /* ── Main content area ────────────────────────────────────
     `outline: none` prevents a focus ring on the element
     when skip link is used, while keeping it focusable.  */
  main {
    outline: none;
    min-height: 100vh;
  }
</style>
