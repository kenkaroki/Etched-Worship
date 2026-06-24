<!-- ============================================================
  Hero.svelte
  Full-viewport landing hero section with animated headline,
  sub-tagline, primary CTA buttons, and a floating mockup card.
  ============================================================ -->
<script lang="ts">
  import { onMount } from "svelte";
  import { base } from '$app/paths';

  // Svelte 5: $state() makes this reactive.
  // Svelte 4: drop $state() and just use `let visible = false;`
  let visible = $state(false);

  onMount(() => {
    // Let the browser paint the initial frame (opacity: 0),
    // then trigger the fade-in transition.
    requestAnimationFrame(() => {
      setTimeout(() => {
        visible = true;
      }, 80);
    });
    // ← removed the erroneous synchronous `visible = true` that was here
  });
</script>

<!-- Hero section — full viewport height -->
<section class="hero section" id="home" aria-label="Introduction">
  <!-- Decorative background mesh / glow orbs (CSS-only, no images) -->
  <div class="hero__bg" aria-hidden="true">
    <div class="hero__orb hero__orb--1"></div>
    <div class="hero__orb hero__orb--2"></div>
    <div class="hero__orb hero__orb--3"></div>
  </div>

  <div class="container hero__content" class:hero__content--visible={visible}>
    <!-- Small eyebrow label above headline -->
    <div class="hero__eyebrow">
      <span class="badge badge-green">
        <!-- Open source indicator dot -->
        <span class="hero__dot" aria-hidden="true"></span>
        Free &amp; Open Source
      </span>
    </div>

    <!-- Main headline -->
    <h1 class="hero__headline">
      Church Presentations,<br />
      <span class="text-glow">Done Beautifully</span>
    </h1>

    <!-- Sub-headline description -->
    <p class="hero__description">
      <strong>Etched Worship</strong> is a free, open-source presentation tool built
      for churches — manage lyrics, queue songs, control a second display, and lead
      worship without the complexity.
    </p>

    <!-- Call-to-action buttons -->
    <div class="hero__actions">
      <a
        href="{base}/download"
        class="btn btn-primary hero__btn"
        id="hero-download-btn"
      >
        <!-- Download icon -->
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2.5"
          aria-hidden="true"
        >
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
          <polyline points="7 10 12 15 17 10" />
          <line x1="12" y1="15" x2="12" y2="3" />
        </svg>
        Download Free
      </a>

      <a
        href="https://github.com/kenkaroki/Etched-Worship"
        class="btn btn-outline hero__btn"
        id="hero-github-btn"
        target="_blank"
        rel="noopener noreferrer"
      >
        <!-- GitHub icon -->
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="currentColor"
          aria-hidden="true"
        >
          <path
            d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"
          />
        </svg>
        View on GitHub
      </a>
    </div>

    <!-- Platform availability note -->
    <p class="hero__platforms" aria-label="Available on">
      Available for
      <span>Windows</span> •
      <span>macOS</span> •
      <span>Linux</span>
    </p>
  </div>

  <!-- Floating app mockup card (visual element) -->
  <div
    class="container hero__mockup-wrapper"
    class:hero__mockup-wrapper--visible={visible}
  >
    <div class="hero__mockup" aria-hidden="true" role="presentation">
      <!-- Simulated app window chrome -->
      <div class="hero__mockup-bar">
        <span class="hero__mockup-dot" style="background:#ff5f57"></span>
        <span class="hero__mockup-dot" style="background:#ffbd2e"></span>
        <span class="hero__mockup-dot" style="background:#28c840"></span>
        <span class="hero__mockup-title">Etched Worship — Control Panel</span>
      </div>

      <!-- Simulated app content area -->
      <div class="hero__mockup-body">
        <!-- Sidebar queue list simulation -->
        <div class="hero__mockup-sidebar">
          <div class="hero__mockup-queue-label">🎵 Queue</div>
          {#each ["Amazing Grace", "How Great Is Our God", "Oceans", "10,000 Reasons"] as song, i}
            <div
              class="hero__mockup-item"
              class:hero__mockup-item--active={i === 1}
            >
              {#if i === 1}
                <span style="color:var(--color-primary)">▶</span>
              {:else}
                <span style="color:var(--color-outline)">♪</span>
              {/if}
              {song}
            </div>
          {/each}
        </div>

        <!-- Main display simulation -->
        <div class="hero__mockup-display">
          <p class="hero__mockup-lyric">
            "How great is our God,<br />
            sing with me<br />
            how great is our God"
          </p>
        </div>
      </div>
    </div>
  </div>
</section>

<style>
  /* ── Hero section ────────────────────────────────────────── */
  .hero {
    position: relative;
    overflow: hidden;
    min-height: 50px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding-top: 80px; /* Clear the fixed navbar */
  }

  /* ── Decorative background orbs ─────────────────────────── */
  .hero__bg {
    position: absolute;
    inset: 0;
    pointer-events: none;
    z-index: 0;
  }

  /* Each orb is a blurred radial gradient circle */
  .hero__orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(80px);
    opacity: 0.15;
    animation: orbFloat 8s ease-in-out infinite;
  }

  .hero__orb--1 {
    width: 600px;
    height: 600px;
    top: -200px;
    left: -100px;
    background: radial-gradient(
      circle,
      var(--color-primary) 0%,
      transparent 70%
    );
    animation-delay: 0s;
  }

  .hero__orb--2 {
    width: 400px;
    height: 400px;
    bottom: 0;
    right: 10%;
    background: radial-gradient(
      circle,
      var(--color-primary-dark) 0%,
      transparent 70%
    );
    animation-delay: 3s;
  }

  .hero__orb--3 {
    width: 300px;
    height: 300px;
    top: 40%;
    right: 30%;
    background: radial-gradient(
      circle,
      var(--color-accent) 0%,
      transparent 70%
    );
    animation-delay: 5s;
    opacity: 0.07;
  }

  /* Floating animation for orbs */
  @keyframes orbFloat {
    0%,
    100% {
      transform: translateY(0) scale(1);
    }
    50% {
      transform: translateY(-30px) scale(1.05);
    }
  }

  /* ── Content area ────────────────────────────────────────── */
  .hero__content {
    position: relative;
    z-index: 1;
    max-width: 640px;
    /* Entrance animation — starts invisible/shifted down */
    opacity: 0;
    transform: translateY(30px);
    transition:
      opacity 0.7s ease,
      transform 0.7s ease;
  }

  .hero__content--visible {
    opacity: 1;
    transform: translateY(0);
  }

  /* ── Eyebrow badge ───────────────────────────────────────── */
  .hero__eyebrow {
    margin-bottom: var(--space-6);
  }

  /* Animated green dot (like a "live" indicator) */
  .hero__dot {
    display: inline-block;
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: var(--color-primary);
    animation: dotPulse 2s ease-in-out infinite;
  }

  @keyframes dotPulse {
    0%,
    100% {
      box-shadow: 0 0 0 0 rgba(76, 175, 80, 0.5);
    }
    50% {
      box-shadow: 0 0 0 5px rgba(76, 175, 80, 0);
    }
  }

  /* ── Headline ────────────────────────────────────────────── */
  .hero__headline {
    margin-bottom: var(--space-6);
    font-size: clamp(2.5rem, 6vw, 4.5rem);
    font-weight: 900;
    line-height: 1.1;
  }

  /* ── Description ─────────────────────────────────────────── */
  .hero__description {
    font-size: 1.125rem;
    color: var(--color-text-muted);
    margin-bottom: var(--space-8);
    max-width: 540px;
    line-height: 1.75;
  }

  .hero__description strong {
    color: var(--color-text);
    font-weight: 600;
  }

  /* ── CTA buttons ─────────────────────────────────────────── */
  .hero__actions {
    display: flex;
    gap: var(--space-4);
    flex-wrap: wrap;
    margin-bottom: var(--space-6);
  }

  .hero__btn {
    font-size: 1rem;
    padding: var(--space-3) var(--space-8);
  }

  /* ── Platform availability ────────────────────────────────── */
  .hero__platforms {
    font-size: 0.8125rem;
    color: var(--color-text-dim);
    max-width: none;
  }

  .hero__platforms span {
    color: var(--color-text-muted);
  }

  /* ── App mockup ──────────────────────────────────────────── */
  .hero__mockup-wrapper {
    position: relative;
    z-index: 1;
    margin-top: var(--space-16);
    /* Entrance animation with slight delay */
    opacity: 0;
    transform: translateY(40px);
    transition:
      opacity 0.8s ease 0.3s,
      transform 0.8s ease 0.3s;
  }

  .hero__mockup-wrapper--visible {
    opacity: 1;
    transform: translateY(0);
  }

  /* The mock app window */
  .hero__mockup {
    background: var(--color-surface);
    border: 1px solid var(--color-outline);
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: var(--shadow-glow), var(--shadow-lg);
    max-width: 900px;
    margin-inline: auto;
    /* Subtle floating animation */
    animation: mockupFloat 6s ease-in-out infinite;
  }

  @keyframes mockupFloat {
    0%,
    100% {
      transform: translateY(0);
    }
    50% {
      transform: translateY(-8px);
    }
  }

  /* Title bar chrome */
  .hero__mockup-bar {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    padding: var(--space-3) var(--space-4);
    background: rgba(0, 0, 0, 0.4);
    border-bottom: 1px solid var(--color-outline);
  }

  .hero__mockup-dot {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    flex-shrink: 0;
  }

  .hero__mockup-title {
    font-size: 0.75rem;
    color: var(--color-text-dim);
    margin-left: var(--space-3);
    flex: 1;
    text-align: center;
  }

  /* App body: sidebar + display */
  .hero__mockup-body {
    display: grid;
    grid-template-columns: 220px 1fr;
    min-height: 220px;
  }

  /* Queue sidebar */
  .hero__mockup-sidebar {
    border-right: 1px solid var(--color-outline);
    padding: var(--space-4);
    background: var(--color-surface-variant);
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
  }

  .hero__mockup-queue-label {
    font-size: 0.7rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    color: var(--color-text-dim);
    margin-bottom: var(--space-2);
  }

  .hero__mockup-item {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    font-size: 0.8rem;
    color: var(--color-text-muted);
    padding: var(--space-2) var(--space-3);
    border-radius: var(--radius-sm);
    cursor: default;
  }

  /* Currently active item gets green highlight */
  .hero__mockup-item--active {
    background: rgba(76, 175, 80, 0.15);
    color: var(--color-primary-light);
    font-weight: 600;
  }

  /* Main display area */
  .hero__mockup-display {
    display: flex;
    align-items: center;
    justify-content: center;
    background: #0a0f0a;
    padding: var(--space-8);
  }

  .hero__mockup-lyric {
    text-align: center;
    font-size: 1.1rem;
    font-weight: 500;
    color: #ffffff;
    line-height: 1.8;
    max-width: none;
    /* Text glow effect mimicking a projector screen */
    text-shadow: 0 0 30px rgba(255, 255, 255, 0.2);
  }

  /* ── Responsive adjustments ──────────────────────────────── */
  @media (max-width: 768px) {
    .hero__content {
      max-width: 100%;
    }

    .hero__mockup-body {
      grid-template-columns: 1fr;
    }

    .hero__mockup-sidebar {
      border-right: none;
      border-bottom: 1px solid var(--color-outline);
    }
  }

  @media (max-width: 500px) {
    .hero__actions {
      flex-direction: column;
    }

    .hero__btn {
      width: 100%;
      justify-content: center;
    }
  }
</style>
