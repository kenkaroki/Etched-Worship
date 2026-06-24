<!-- ============================================================
  FeatureCard.svelte
  Reusable card component for the Features section.
  Accepts an icon (emoji/string), title, and description.
  Animates in when scrolled into view using IntersectionObserver.
  ============================================================ -->
<script lang="ts">
  import { onMount } from 'svelte';

  // ── Props (Svelte 5 runes mode) ──────────────────────────
  // In runes mode, component props are declared via $props()
  // instead of the legacy `export let` syntax.
  const {
    /** The emoji or short string to display as the feature icon */
    icon,
    /** Feature title shown in bold */
    title,
    /** Feature description — a sentence or two */
    description,
    /** Optional accent color override for the icon background */
    accentColor = 'rgba(76,175,80,0.12)',
  }: {
    icon: string;
    title: string;
    description: string;
    accentColor?: string;
  } = $props();

  // ── Scroll-in animation ──────────────────────────────────
  // $state() makes these variables reactive in runes mode
  let cardEl: HTMLElement | undefined = $state();
  let inView = $state(false);

  onMount(() => {
    // IntersectionObserver triggers the entrance animation
    // when the card enters the viewport
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          inView = true;
          observer.disconnect(); // Only animate once
        }
      },
      { threshold: 0.15 }
    );

    if (cardEl) observer.observe(cardEl);

    // Cleanup on component destroy
    return () => observer.disconnect();
  });
</script>

<article
  bind:this={cardEl}
  class="feature-card card"
  class:feature-card--visible={inView}
  aria-label="Feature: {title}"
>
  <!-- Icon circle -->
  <div
    class="feature-card__icon"
    style="background: {accentColor};"
    aria-hidden="true"
  >
    {icon}
  </div>

  <!-- Text content -->
  <h3 class="feature-card__title">{title}</h3>
  <p class="feature-card__desc">{description}</p>
</article>

<style>
  /* ── Card layout ─────────────────────────────────────────── */
  .feature-card {
    /* Entrance animation — starts invisible and shifted up */
    opacity: 0;
    transform: translateY(24px);
    transition:
      opacity 0.5s ease,
      transform 0.5s ease,
      border-color var(--transition-normal),
      box-shadow var(--transition-normal),
      /* Override the card hover transform so we can stack it */
      background var(--transition-normal);
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
  }

  /* Triggered by IntersectionObserver when card enters viewport */
  .feature-card--visible {
    opacity: 1;
    transform: translateY(0);
  }

  /* ── Icon circle ─────────────────────────────────────────── */
  .feature-card__icon {
    width: 56px;
    height: 56px;
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.75rem;
    flex-shrink: 0;
    /* Subtle border to define the circle */
    border: 1px solid rgba(76,175,80,0.2);
    transition: transform var(--transition-fast);
  }

  /* Icon bounces slightly on card hover */
  .feature-card:hover .feature-card__icon {
    transform: scale(1.1) rotate(-3deg);
  }

  /* ── Title ───────────────────────────────────────────────── */
  .feature-card__title {
    font-size: 1.125rem;
    font-weight: 700;
    color: var(--color-text);
    margin: 0;
  }

  /* ── Description ─────────────────────────────────────────── */
  .feature-card__desc {
    font-size: 0.9375rem;
    color: var(--color-text-muted);
    line-height: 1.65;
    margin: 0;
    max-width: none; /* Override global p constraint */
  }
</style>
