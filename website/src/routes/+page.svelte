<!-- ============================================================
  +page.svelte  (route: /)
  Home page — covers:
    1. Hero  (imported component)
    2. What is Etched Worship
    3. Features grid
    4. Open Source section
    5. Final CTA banner
  ============================================================ -->
<script lang="ts">
  import Hero from '$lib/components/Hero.svelte';
  import FeatureCard from '$lib/components/FeatureCard.svelte';

  // ── Feature data ─────────────────────────────────────────
  // Each entry maps to a <FeatureCard /> in the grid below.
  // Add or remove entries here to update the features section.
  const features = [
    {
      icon: '🎵',
      title: 'Lyric & Song Management',
      description:
        'Build a library of worship songs with structured lyrics. Add, edit, and organise them in seconds — no more fumbling through folders.',
      accentColor: 'rgba(76,175,80,0.12)',
    },
    {
      icon: '📋',
      title: 'Smart Queue System',
      description:
        'Create named queues for your service order. Queue up songs, jump to any slide instantly, and keep the service flowing without interruption.',
      accentColor: 'rgba(56,142,60,0.14)',
    },
    {
      icon: '🖥️',
      title: 'Dual-Display Output',
      description:
        'Control what the congregation sees on the projector from your laptop. A dedicated Canvas window handles the presentation display independently.',
      accentColor: 'rgba(38,198,218,0.1)',
    },
    {
      icon: '🎶',
      title: 'Music Playback',
      description:
        'Play backing tracks directly from within Etched Worship. Import audio files and sync them to your worship set without switching apps.   (Coming Soon)',
      accentColor: 'rgba(76,175,80,0.12)',
    },
    {
      icon: '🌗',
      title: 'Light & Dark Themes',
      description:
        'Switch between a crisp light theme and a deep green dark theme automatically based on your system preference, or choose manually.',
      accentColor: 'rgba(27,94,32,0.2)',
    },
    {
      icon: '💾',
      title: 'Local File Storage',
      description:
        'All your data stays on your machine — no cloud account required.',
      accentColor: 'rgba(76,175,80,0.1)',
    },
    {
      icon: '🎨',
      title: 'Control Your Backgrounds',
      description:
        'You can customize your slides with background whether solid colors or images that come pre-built. If thats not enough add your own backgrounds',
      accentColor: 'rgba(76,175,80,0.1)',
    },
  ] as const;

  // ── Open-source stats / highlights ───────────────────────
  // Displayed in the open-source section
  const openSourceHighlights = [
    { label: 'License',    value: 'MIT' },
    { label: 'Language',   value: 'Dart / Flutter' },
    { label: 'Platforms',  value: 'Win · macOS · Linux' },
    { label: 'Status',     value: 'Active Development' },
  ] as const;
</script>

<!-- ── Page meta (SEO) ──────────────────────────────────── -->
<svelte:head>
  <title>Etched Worship — Free Church Presentation Software</title>
  <meta
    name="description"
    content="Etched Worship is a free, open-source church presentation app for Windows, macOS, and Linux. Manage lyrics, control queues, and project worship on a second display."
  />
  <meta property="og:title"       content="Etched Worship — Free Church Presentation Software" />
  <meta property="og:description" content="Free, open-source worship presentation software built for churches." />
  <meta property="og:type"        content="website" />
</svelte:head>

<!-- ════════════════════════════════════════════════════════
     1. HERO SECTION
     ════════════════════════════════════════════════════════ -->
<Hero />

<!-- ════════════════════════════════════════════════════════
     2. WHAT IS ETCHED WORSHIP
     ════════════════════════════════════════════════════════ -->
<section class="section what-is" id="what-is" aria-labelledby="what-is-heading">
  <div class="container">

    <!-- Section label + heading -->
    <span class="section-label">About</span>
    <h2 class="section-title" id="what-is-heading">
      What is Etched Worship?
    </h2>

    <!-- Two-column layout: main text + side highlights -->
    <div class="what-is__grid">

      <!-- Left: descriptive text -->
      <div class="what-is__text">
        <p>
          <strong>Etched Worship</strong> is a desktop presentation application
          designed specifically for church worship teams. Whether you are a small
          congregation meeting in a hall or a mid-size church with a dedicated AV
          setup, Etched Worship gives you everything you need to lead worship
          without the confusion of overly complex software.
        </p>
        <p>
          It is built on <strong>Flutter</strong>, giving it a consistent and
          polished feel across Windows, macOS, and Linux — with a single codebase
          that makes community contributions straightforward.
        </p>
        <p>
          The app is split into two parts: the <strong>Control Panel</strong> —
          where the worship leader manages songs, queues, and content — and the
          <strong>Canvas</strong> window that displays the current slide fullscreen
          on a projector or second monitor.
        </p>

        <!-- Inline CTA -->
        <div class="what-is__actions">
          <a href="/download" class="btn btn-primary" id="about-download-btn">Get Started Free</a>
          <a
            href="https://github.com/kenkaroki/Etched-Worship"
            class="btn btn-outline"
            target="_blank"
            rel="noopener noreferrer"
            id="about-github-btn"
          >
            Explore the Source
          </a>
        </div>
      </div>

      
    </div>
  </div>
</section>

<!-- ════════════════════════════════════════════════════════
     3. FEATURES GRID
     ════════════════════════════════════════════════════════ -->
<section class="section features" id="features" aria-labelledby="features-heading">
  <div class="container">

    <span class="section-label">Features</span>
    <h2 class="section-title" id="features-heading">
      Everything your worship team needs
    </h2>
    <p class="section-subtitle">
      Etched Worship packs the tools you actually use — nothing more, nothing less.
    </p>

    <!-- Responsive auto-fit grid of feature cards -->
    <div class="grid-auto features__grid">
      {#each features as feature, i}
        <!--
          Each card has a slight animation delay proportional to its index,
          creating a staggered reveal as the user scrolls down.
        -->
        <div style="--stagger-delay: {i * 80}ms;">
          <FeatureCard
            icon={feature.icon}
            title={feature.title}
            description={feature.description}
            accentColor={feature.accentColor}
          />
        </div>
      {/each}
    </div>
  </div>
</section>

<!-- ════════════════════════════════════════════════════════
     4. OPEN SOURCE SECTION
     ════════════════════════════════════════════════════════ -->
<section class="section open-source" id="open-source" aria-labelledby="oss-heading">
  <div class="container">

    <span class="section-label">Open Source</span>
    <h2 class="section-title" id="oss-heading">
      Built in the open, <span class="text-glow">for everyone</span>
    </h2>
    <p class="section-subtitle">
      Etched Worship is 100% free and open source under the MIT licence.
      Inspect the code, suggest improvements, or fork it for your own needs.
    </p>

    <!-- OSS highlight cards row -->
    <div class="oss__cards">

      <!-- MIT Licence card -->
      <div class="oss__card card">
        <div class="oss__card-icon" aria-hidden="true">⚖️</div>
        <h3>MIT Licensed</h3>
        <p>
          Use it, modify it, distribute it. The MIT licence gives you full
          freedom with minimal restriction — forever free, for churches of
          every size.
        </p>
      </div>

      <!-- Community card -->
      <div class="oss__card card">
        <div class="oss__card-icon" aria-hidden="true">🤝</div>
        <h3>Community Driven</h3>
        <p>
          Contributions are welcome. Report bugs, suggest features, or open
          a pull request. The project grows with the needs of real worship
          communities.
        </p>
      </div>

      <!-- Transparency card -->
      <div class="oss__card card">
        <div class="oss__card-icon" aria-hidden="true">🔍</div>
        <h3>Fully Transparent</h3>
        <p>
          No telemetry, no ads, no accounts. Your data stays on your computer.
          Read every line of code on GitHub and verify that yourself.
        </p>
      </div>
    </div>

    <!-- GitHub CTA strip -->
    <div class="oss__github-strip">
      <div class="oss__github-text">
        <svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" style="color:var(--color-primary)">
          <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"/>
        </svg>
        <div>
          <strong>kenkaroki/Etched-Worship</strong>
          <span>Browse the source code, open issues, and contribute</span>
        </div>
      </div>
      <a
        href="https://github.com/kenkaroki/Etched-Worship"
        class="btn btn-primary"
        id="oss-github-btn"
        target="_blank"
        rel="noopener noreferrer"
      >
        View on GitHub
      </a>
    </div>
  </div>
</section>

<!-- ════════════════════════════════════════════════════════
     5. FINAL CTA BANNER
     ════════════════════════════════════════════════════════ -->
<section class="section--sm cta-banner" aria-labelledby="cta-heading">
  <div class="container cta-banner__inner">
    <!-- Decorative glow orb behind the banner -->
    <div class="cta-banner__glow" aria-hidden="true"></div>

    <div class="cta-banner__content">
      <h2 id="cta-heading">Ready to elevate your worship?</h2>
      <p>Download Etched Worship for free and get started in minutes.</p>

      <div class="cta-banner__actions">
        <a href="/download" class="btn btn-primary" id="cta-download-btn">
          Download Free
        </a>
        <a
          href="https://github.com/kenkaroki/Etched-Worship"
          class="btn btn-outline"
          id="cta-github-btn"
          target="_blank"
          rel="noopener noreferrer"
        >
          Star on GitHub
        </a>
      </div>
    </div>
  </div>
</section>

<style>
  /* ════════════════════════════════════════════════════════
     WHAT IS SECTION
     ════════════════════════════════════════════════════════ */
  .what-is__grid {
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .what-is__text {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
  }

  /* Override global p to allow full width in this context */
  .what-is__text p {
    max-width: none;
    font-size: 1.0625rem;
    line-height: 1.8;
  }

  .what-is__text strong {
    color: var(--color-primary-light);
    font-weight: 600;
  }

  .what-is__actions {
    display: flex;
    gap: var(--space-4);
    flex-wrap: wrap;
    margin-top: var(--space-2);
  }

  

  /* ════════════════════════════════════════════════════════
     FEATURES SECTION
     ════════════════════════════════════════════════════════ */
  .features {
    /* Subtle alternate background to break up sections */
    background: rgba(26,42,26,0.3);
    border-top:    1px solid var(--color-outline);
    border-bottom: 1px solid var(--color-outline);
  }

  /* Apply stagger delay from --stagger-delay CSS variable */
  .features__grid > div :global(.feature-card) {
    transition-delay: var(--stagger-delay, 0ms);
  }

  /* ════════════════════════════════════════════════════════
     OPEN SOURCE SECTION
     ════════════════════════════════════════════════════════ */

  /* Three-column card row */
  .oss__cards {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: var(--space-6);
    margin-bottom: var(--space-12);
  }

  .oss__card {
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--space-4);
  }

  .oss__card-icon {
    font-size: 2.5rem;
  }

  .oss__card h3 {
    font-size: 1.1rem;
    font-weight: 700;
  }

  .oss__card p {
    font-size: 0.9375rem;
    text-align: center;
    max-width: none;
  }

  /* GitHub CTA strip — wide bar with repo name + button */
  .oss__github-strip {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-6);
    background: var(--color-surface);
    border: 1px solid var(--color-outline);
    border-radius: var(--radius-lg);
    padding: var(--space-6) var(--space-8);
    flex-wrap: wrap;
  }

  .oss__github-text {
    display: flex;
    align-items: center;
    gap: var(--space-4);
  }

  .oss__github-text div {
    display: flex;
    flex-direction: column;
    gap: var(--space-1);
  }

  .oss__github-text strong {
    font-size: 1rem;
    font-weight: 700;
    color: var(--color-text);
    font-family: var(--font-mono);
  }

  .oss__github-text span {
    font-size: 0.875rem;
    color: var(--color-text-muted);
  }

  /* ════════════════════════════════════════════════════════
     CTA BANNER
     ════════════════════════════════════════════════════════ */
  .cta-banner {
    position: relative;
    overflow: hidden;
    text-align: center;
  }

  /* Large green radial glow behind the banner */
  .cta-banner__glow {
    position: absolute;
    inset: 0;
    background: radial-gradient(ellipse at 50% 50%, rgba(76,175,80,0.12) 0%, transparent 70%);
    pointer-events: none;
  }

  .cta-banner__inner {
    position: relative;
    z-index: 1;
  }

  .cta-banner__content {
    max-width: 600px;
    margin-inline: auto;
  }

  .cta-banner__content h2 {
    margin-bottom: var(--space-4);
  }

  .cta-banner__content p {
    font-size: 1.0625rem;
    margin-bottom: var(--space-8);
    margin-inline: auto;
  }

  .cta-banner__actions {
    display: flex;
    gap: var(--space-4);
    justify-content: center;
    flex-wrap: wrap;
  }

  /* ════════════════════════════════════════════════════════
     RESPONSIVE
     ════════════════════════════════════════════════════════ */
  @media (max-width: 900px) {
    /* Stack what-is two columns into one */
    .what-is__grid {
      grid-template-columns: 1fr;
      gap: var(--space-10);
    }

    .what-is__highlights {
      position: static;
    }

    /* OSS cards stack to one column on small screens */
    .oss__cards {
      grid-template-columns: 1fr;
    }

    .oss__github-strip {
      flex-direction: column;
      align-items: flex-start;
    }
  }

  @media (max-width: 600px) {
    .what-is__highlights {
      grid-template-columns: 1fr 1fr;
    }
  }
</style>
