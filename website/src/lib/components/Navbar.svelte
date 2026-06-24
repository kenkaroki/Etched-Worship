<!-- ============================================================
  Navbar.svelte
  Top navigation bar with the Etched Worship brand, nav links,
  and a sticky/scroll-aware glassmorphism effect.
  ============================================================ -->
<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { base } from '$app/paths';


  // Track scroll position to apply backdrop blur when user scrolls down
  // $state() makes the variable reactive in Svelte 5 runes mode
  let scrolled = $state(false);

  // Whether the mobile menu is open
  let menuOpen = $state(false);

  onMount(() => {
    const handleScroll = () => {
      scrolled = window.scrollY > 20;
    };
    window.addEventListener('scroll', handleScroll, { passive: true });
    // Cleanup on component destroy
    return () => window.removeEventListener('scroll', handleScroll);
  });

  // Navigation links definition — easy to extend
  const navLinks = [
    { href: `${base}/`,         label: 'Home'     },
    { href: `${base}/#features`,label: 'Features' },
    { href: `${base}/#open-source`, label: 'Open Source' },
    { href: `${base}/download`, label: 'Download' },
  ] as const;

  // Close mobile menu when route changes.
  // $effect() is the Svelte 5 runes-mode replacement for $: reactive statements.
  $effect(() => {
    if ($page.url.pathname) menuOpen = false;
  });
</script>

<nav
  class="navbar"
  class:navbar--scrolled={scrolled}
  role="navigation"
  aria-label="Main navigation"
>
  <div class="container navbar__inner">
    <!-- Brand logo / wordmark -->
    <a href="{base}/" class="navbar__brand" aria-label="Etched Worship — home">
      <!-- Cross / worship icon -->
      <span class="navbar__icon" aria-hidden="true">✝</span>
      <span class="navbar__wordmark">
        <span class="navbar__wordmark-etched">Etched</span>
        <span class="navbar__wordmark-worship">Worship</span>
      </span>
    </a>

    <!-- Desktop navigation links -->
    <ul class="navbar__links" role="list">
      {#each navLinks as link}
        <li>
          <a
            href={link.href}
            class="navbar__link"
            class:navbar__link--active={$page.url.pathname === link.href}
            aria-current={$page.url.pathname === link.href ? 'page' : undefined}
          >
            {link.label}
          </a>
        </li>
      {/each}
    </ul>

    <!-- Download CTA (desktop) -->
    <!-- <a href="/download" class="btn btn-primary navbar__cta" id="nav-download-btn">
      Download
    </a> -->

    <!-- Mobile hamburger toggle -->
    <button
      class="navbar__hamburger"
      aria-label={menuOpen ? 'Close menu' : 'Open menu'}
      aria-expanded={menuOpen}
      aria-controls="mobile-menu"
      on:click={() => (menuOpen = !menuOpen)}
    >
      <span class="navbar__bar" class:navbar__bar--top-open={menuOpen}></span>
      <span class="navbar__bar" class:navbar__bar--mid-open={menuOpen}></span>
      <span class="navbar__bar" class:navbar__bar--bot-open={menuOpen}></span>
    </button>
  </div>

  <!-- Mobile dropdown menu -->
  <div
    id="mobile-menu"
    class="navbar__mobile"
    class:navbar__mobile--open={menuOpen}
    aria-hidden={!menuOpen}
  >
    <ul role="list">
      {#each navLinks as link}
        <li>
          <a href={link.href} class="navbar__mobile-link">{link.label}</a>
        </li>
      {/each}
      <li>
        <a href="{base}/download" class="btn btn-primary" style="width:100%;justify-content:center;">
          Download
        </a>
      </li>
    </ul>
  </div>
</nav>

<style>
  /* ── Navbar base ─────────────────────────────────────────── */
  .navbar {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 100;
    /* Start transparent; transitions to frosted glass on scroll */
    background: transparent;
    transition:
      background var(--transition-normal),
      border-color var(--transition-normal),
      box-shadow var(--transition-normal);
    border-bottom: 1px solid transparent;
  }

  /* Frosted-glass effect when user has scrolled */
  .navbar--scrolled {
    background: rgba(15, 26, 15, 0.85);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border-bottom-color: var(--color-outline);
    box-shadow: 0 4px 24px rgba(0,0,0,0.4);
  }

  /* ── Inner layout ────────────────────────────────────────── */
  .navbar__inner {
    display: flex;
    align-items: center;
    gap: var(--space-8);
    height: 64px;
  }

  /* ── Brand ───────────────────────────────────────────────── */
  .navbar__brand {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    text-decoration: none;
    flex-shrink: 0;
  }

  .navbar__icon {
    font-size: 1.5rem;
    color: var(--color-primary);
    /* Subtle pulse animation */
    animation: iconPulse 3s ease-in-out infinite;
  }

  @keyframes iconPulse {
    0%, 100% { text-shadow: 0 0 8px rgba(76,175,80,0.4); }
    50%       { text-shadow: 0 0 20px rgba(76,175,80,0.8); }
  }

  .navbar__wordmark {
    display: flex;
    flex-direction: column;
    line-height: 1.1;
  }

  .navbar__wordmark-etched {
    font-size: 0.7rem;
    font-weight: 600;
    letter-spacing: 0.15em;
    text-transform: uppercase;
    color: var(--color-primary);
  }

  .navbar__wordmark-worship {
    font-size: 1rem;
    font-weight: 800;
    color: var(--color-text);
  }

  /* ── Desktop links ───────────────────────────────────────── */
  .navbar__links {
    display: flex;
    list-style: none;
    gap: var(--space-1);
    margin-left: auto; /* Push to right of brand */
  }

  .navbar__link {
    padding: var(--space-2) var(--space-4);
    border-radius: var(--radius-sm);
    font-size: 0.9375rem;
    font-weight: 500;
    color: var(--color-text-muted);
    text-decoration: none;
    transition: color var(--transition-fast), background var(--transition-fast);
  }

  .navbar__link:hover {
    color: var(--color-text);
    background: rgba(76,175,80,0.08);
  }

  .navbar__link--active {
    color: var(--color-primary-light);
    background: rgba(76,175,80,0.12);
  }

  /* ── Desktop CTA button ──────────────────────────────────── */
  .navbar__cta {
    flex-shrink: 0;
    font-size: 0.875rem;
    padding: var(--space-2) var(--space-5);
  }

  /* ── Hamburger (mobile) ──────────────────────────────────── */
  .navbar__hamburger {
    display: none; /* Hidden on desktop */
    flex-direction: column;
    justify-content: center;
    gap: 5px;
    width: 36px;
    height: 36px;
    background: none;
    border: none;
    cursor: pointer;
    padding: 4px;
    border-radius: var(--radius-sm);
    margin-left: auto;
  }

  .navbar__hamburger:hover {
    background: rgba(76,175,80,0.1);
  }

  .navbar__bar {
    display: block;
    width: 22px;
    height: 2px;
    background: var(--color-text);
    border-radius: 2px;
    transition: transform var(--transition-fast), opacity var(--transition-fast);
  }

  /* Animate bars into an X when open */
  .navbar__bar--top-open { transform: translateY(7px) rotate(45deg); }
  .navbar__bar--mid-open { opacity: 0; }
  .navbar__bar--bot-open { transform: translateY(-7px) rotate(-45deg); }

  /* ── Mobile menu dropdown ────────────────────────────────── */
  .navbar__mobile {
    display: none; /* Shown only on mobile */
    overflow: hidden;
    max-height: 0;
    transition: max-height var(--transition-normal);
    background: rgba(15, 26, 15, 0.97);
    border-top: 1px solid var(--color-outline);
    backdrop-filter: blur(16px);
  }

  .navbar__mobile--open {
    max-height: 400px;
  }

  .navbar__mobile ul {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
    padding: var(--space-4) var(--space-6) var(--space-6);
  }

  .navbar__mobile-link {
    display: block;
    padding: var(--space-3) var(--space-4);
    color: var(--color-text-muted);
    font-weight: 500;
    border-radius: var(--radius-sm);
    text-decoration: none;
    transition: color var(--transition-fast), background var(--transition-fast);
  }

  .navbar__mobile-link:hover {
    color: var(--color-text);
    background: rgba(76,175,80,0.1);
  }

  /* ── Responsive breakpoints ──────────────────────────────── */
  @media (max-width: 768px) {
    /* Hide desktop links and CTA */
    .navbar__links,
    .navbar__cta {
      display: none;
    }

    /* Show hamburger and mobile menu */
    .navbar__hamburger {
      display: flex;
    }

    .navbar__mobile {
      display: block;
    }
  }
</style>
