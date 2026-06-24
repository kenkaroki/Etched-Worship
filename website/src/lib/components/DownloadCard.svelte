<!-- ============================================================
  DownloadCard.svelte
  Platform download card for the Download page.
  Shows platform name, icon, version, and a download button.
  Button is disabled when no installer URL is provided yet,
  showing a "Coming soon" state instead.
  ============================================================ -->
<script lang="ts">
  // ── Props (Svelte 5 runes mode) ──────────────────────────
  // $props() replaces the legacy `export let` syntax in runes mode
  const {
    /** Platform name e.g. "Windows", "macOS", "Linux" */
    platform,
    /** Platform icon — emoji or SVG string */
    icon,
    /** File format description e.g. ".exe Installer", ".dmg Package" */
    fileFormat,
    /** Architecture or extra info e.g. "64-bit • ARM64" */
    arch,
    /**
     * Direct URL to the installer download.
     * Leave empty / undefined to show the "Coming soon" state.
     */
    downloadUrl = '',
    /** Version label shown on the badge */
    version = 'v1.0.0',
  }: {
    platform: string;
    icon: string;
    fileFormat: string;
    arch: string;
    downloadUrl?: string;
    version?: string;
  } = $props();

  // ── Computed state ───────────────────────────────────────
  // $derived() is the runes-mode equivalent of $: for computed values.
  // True when a real download URL has been provided
  const isAvailable = $derived(downloadUrl.trim().length > 0);
</script>

<article
  class="dl-card card"
  class:dl-card--available={isAvailable}
  aria-label="Download for {platform}"
>
  <!-- Platform icon -->
  <div class="dl-card__icon" aria-hidden="true">{icon}</div>

  <!-- Platform name and file format -->
  <div class="dl-card__info">
    <h3 class="dl-card__platform">{platform}</h3>
    <p class="dl-card__format">{fileFormat}</p>
    <p class="dl-card__arch">{arch}</p>
  </div>

  <!-- Version badge -->
  <div class="dl-card__version badge badge-green" aria-label="Version {version}">
    {version}
  </div>

  <!-- Download / Coming soon button -->
  {#if isAvailable}
    <!-- Real download link — opens the installer file -->
    <a
      href={downloadUrl}
      class="btn btn-primary dl-card__btn"
      id="download-btn-{platform.toLowerCase().replace(/\s+/g, '-')}"
      download
      aria-label="Download Etched Worship for {platform}"
    >
      <!-- Download arrow icon -->
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
        <polyline points="7 10 12 15 17 10"/>
        <line x1="12" y1="15" x2="12" y2="3"/>
      </svg>
      Download
    </a>
  {:else}
    <!-- Placeholder state — you can replace this by providing a downloadUrl prop -->
    <button
      class="btn dl-card__btn dl-card__btn--soon"
      disabled
      aria-label="Download for {platform} — coming soon"
      title="Installer not yet available — check back later"
    >
      <!-- Clock icon to indicate "coming soon" -->
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
        <circle cx="12" cy="12" r="10"/>
        <polyline points="12 6 12 12 16 14"/>
      </svg>
      Coming Soon
    </button>
  {/if}
</article>

<style>
  /* ── Card layout ─────────────────────────────────────────── */
  .dl-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: var(--space-4);
    padding: var(--space-8) var(--space-6);
    position: relative;
    overflow: hidden;
  }

  /* When available, show a stronger green glow on hover */
  .dl-card--available:hover {
    box-shadow: var(--shadow-glow), var(--shadow-lg);
  }

  /* ── Platform icon ───────────────────────────────────────── */
  .dl-card__icon {
    font-size: 3rem;
    line-height: 1;
    /* Gentle float animation */
    animation: iconFloat 4s ease-in-out infinite;
  }

  /* Stagger the animation so all three icons don't float in sync */
  .dl-card:nth-child(2) .dl-card__icon { animation-delay: 1.3s; }
  .dl-card:nth-child(3) .dl-card__icon { animation-delay: 2.6s; }

  @keyframes iconFloat {
    0%, 100% { transform: translateY(0); }
    50%       { transform: translateY(-8px); }
  }

  /* ── Info block ──────────────────────────────────────────── */
  .dl-card__info {
    display: flex;
    flex-direction: column;
    gap: var(--space-1);
  }

  .dl-card__platform {
    font-size: 1.5rem;
    font-weight: 800;
    color: var(--color-text);
    margin: 0;
  }

  .dl-card__format {
    font-size: 0.9rem;
    color: var(--color-primary-light);
    font-weight: 500;
    margin: 0;
    max-width: none;
  }

  .dl-card__arch {
    font-size: 0.8rem;
    color: var(--color-text-dim);
    margin: 0;
    max-width: none;
  }

  /* ── Version badge ───────────────────────────────────────── */
  .dl-card__version {
    font-size: 0.7rem;
  }

  /* ── Download button ─────────────────────────────────────── */
  .dl-card__btn {
    width: 100%;
    justify-content: center;
    font-size: 0.9375rem;
    margin-top: auto; /* Push button to bottom of card */
  }

  /* Coming soon state — greyed out, not interactive */
  .dl-card__btn--soon {
    background: var(--color-surface-variant);
    color: var(--color-text-dim);
    border: 1px solid var(--color-outline);
    cursor: not-allowed;
    opacity: 0.7;
  }

  /* Disabled buttons don't animate on hover */
  .dl-card__btn--soon:hover {
    transform: none;
    box-shadow: none;
    background: var(--color-surface-variant);
  }
</style>
