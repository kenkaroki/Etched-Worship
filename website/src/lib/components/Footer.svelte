<!-- ============================================================
  Footer.svelte
  Site-wide footer with brand, nav columns, and legal info.
  ============================================================ -->
<script lang="ts">
  // Current year for the copyright line — computed at runtime
  const year = new Date().getFullYear();

  // Footer link groups
  const linkGroups = [
    {
      title: 'Product',
      links: [
        { href: '/#features',     label: 'Features'    },
        { href: '/#what-is',      label: 'About'       },
        { href: '/download',      label: 'Download'    },
      ],
    },
    {
      title: 'Open Source',
      links: [
        { href: 'https://github.com/kenkaroki/Etched-Worship', label: 'GitHub Repo'   },
        { href: 'https://github.com/kenkaroki/Etched-Worship/blob/main/LICENSE', label: 'MIT License' },
        { href: 'https://github.com/kenkaroki/Etched-Worship/issues', label: 'Report Issue'  },
      ],
    },
    {
      title: 'Community',
      links: [
        { href: 'https://github.com/kenkaroki/Etched-Worship/discussions', label: 'Discussions' },
        { href: 'https://github.com/kenkaroki/Etched-Worship/releases',    label: 'Releases'    },
      ],
    },
  ] as const;
</script>

<footer class="footer" role="contentinfo">
  <!-- Top section: brand + link columns -->
  <div class="container footer__top">

    <!-- Brand column -->
    <div class="footer__brand">
      <a href="/" class="footer__logo" aria-label="Etched Worship home">
        <span class="footer__logo-icon" aria-hidden="true">✝</span>
        <span class="footer__logo-text">Etched Worship</span>
      </a>
      <p class="footer__tagline">
        Free, open-source church presentation software.<br />
        Made with ❤️ for worship communities.
      </p>

      <!-- GitHub star badge -->
      <a
        href="https://github.com/kenkaroki/Etched-Worship"
        class="badge badge-green footer__gh-badge"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="View source on GitHub"
      >
        <!-- GitHub icon (inline SVG for zero-dependency) -->
        <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"/>
        </svg>
        View on GitHub
      </a>
    </div>

    <!-- Link columns -->
    {#each linkGroups as group}
      <nav class="footer__col" aria-label="{group.title} links">
        <h3 class="footer__col-title">{group.title}</h3>
        <ul role="list">
          {#each group.links as link}
            <li>
              <a
                href={link.href}
                class="footer__link"
                target={link.href.startsWith('http') ? '_blank' : undefined}
                rel={link.href.startsWith('http') ? 'noopener noreferrer' : undefined}
              >
                {link.label}
              </a>
            </li>
          {/each}
        </ul>
      </nav>
    {/each}
  </div>

  <!-- Divider -->
  <div class="container">
    <div class="divider"></div>
  </div>

  <!-- Bottom bar: copyright + licence -->
  <div class="container footer__bottom">
    <p class="footer__copy">
      &copy; {year} Etched Worship. Released under the
      <a
        href="https://github.com/kenkaroki/Etched-Worship/blob/main/LICENSE"
        target="_blank"
        rel="noopener noreferrer"
      >MIT License</a>.
    </p>
    <p class="footer__built">Built with SvelteKit + TypeScript</p>
  </div>
</footer>

<style>
  /* ── Footer wrapper ──────────────────────────────────────── */
  .footer {
    background: var(--color-primary-deep);
    /* Subtle gradient overlay */
    background-image: linear-gradient(
      180deg,
      var(--color-bg) 0%,
      var(--color-primary-deep) 40%
    );
    border-top: 1px solid var(--color-outline);
    padding-top: var(--space-16);
    padding-bottom: var(--space-8);
  }

  /* ── Top grid: brand + 3 columns ─────────────────────────── */
  .footer__top {
    display: grid;
    grid-template-columns: 2fr 1fr 1fr 1fr;
    gap: var(--space-8);
    margin-bottom: var(--space-8);
  }

  /* ── Brand column ────────────────────────────────────────── */
  .footer__logo {
    display: inline-flex;
    align-items: center;
    gap: var(--space-2);
    text-decoration: none;
    margin-bottom: var(--space-4);
  }

  .footer__logo-icon {
    font-size: 1.5rem;
    color: var(--color-primary);
  }

  .footer__logo-text {
    font-size: 1.1rem;
    font-weight: 800;
    color: var(--color-text);
  }

  .footer__tagline {
    font-size: 0.875rem;
    color: var(--color-text-muted);
    line-height: 1.7;
    margin-bottom: var(--space-4);
    max-width: none; /* Override global p max-width */
  }

  .footer__gh-badge {
    font-size: 0.8125rem;
    text-decoration: none;
    gap: var(--space-2);
    transition: background var(--transition-fast), transform var(--transition-fast);
  }

  .footer__gh-badge:hover {
    background: rgba(76,175,80,0.25);
    transform: translateY(-1px);
  }

  /* ── Link columns ────────────────────────────────────────── */
  .footer__col-title {
    font-size: 0.75rem;
    font-weight: 700;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--color-primary-light);
    margin-bottom: var(--space-4);
  }

  .footer__col ul {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  .footer__link {
    font-size: 0.875rem;
    color: var(--color-text-muted);
    text-decoration: none;
    transition: color var(--transition-fast);
  }

  .footer__link:hover {
    color: var(--color-primary-light);
  }

  /* ── Bottom bar ──────────────────────────────────────────── */
  .footer__bottom {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: var(--space-4);
  }

  .footer__copy,
  .footer__built {
    font-size: 0.8125rem;
    color: var(--color-text-dim);
    max-width: none;
  }

  .footer__copy a {
    color: var(--color-primary-light);
  }

  /* ── Responsive ──────────────────────────────────────────── */
  @media (max-width: 900px) {
    .footer__top {
      grid-template-columns: 1fr 1fr;
    }

    /* Brand spans both columns */
    .footer__brand {
      grid-column: 1 / -1;
    }
  }

  @media (max-width: 500px) {
    .footer__top {
      grid-template-columns: 1fr;
    }

    .footer__bottom {
      flex-direction: column;
      align-items: flex-start;
    }
  }
</style>
