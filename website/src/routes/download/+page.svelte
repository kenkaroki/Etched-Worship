<!-- ============================================================
  download/+page.svelte  (route: /download)
  Download page — shows platform cards for Windows, macOS, and
  Linux. Each card has a "Coming soon" state by default; swap in
  real installer URLs via the `downloadUrl` prop when ready.
  ============================================================ -->
<script lang="ts">
  import DownloadCard from '$lib/components/DownloadCard.svelte';

  // ── Platform definitions ─────────────────────────────────
  // To activate a download button, set `downloadUrl` to the
  // direct URL of the installer file (e.g. a GitHub Release asset).
  // Example: downloadUrl: 'https://github.com/.../releases/download/v1.0.0/EtchedWorship-Setup.exe'
  const platforms = [
    {
      platform:    'Windows',
      icon:        '🪟',
      fileFormat:  '.exe Installer',
      arch:        '64-bit (x86_64)',
      // ← Replace '' with your .exe download URL when ready
      downloadUrl: '',
      version:     'v1.0.0',
    },
    {
      platform:    'macOS',
      icon:        '🍎',
      fileFormat:  '.dmg Package',
      arch:        'Apple Silicon & Intel',
      // ← Replace '' with your .dmg download URL when ready
      downloadUrl: '',
      version:     'v1.0.0',
    },
    {
      platform:    'Linux',
      icon:        '🐧',
      fileFormat:  '.deb / AppImage',
      arch:        '64-bit (x86_64)',
      // ← Replace '' with your Linux installer URL when ready
      downloadUrl: '',
      version:     'v1.0.0',
    },
  ] as const;

  // ── Requirements data ─────────────────────────────────────
  // Shown in the system requirements table below the cards
  const requirements = [
    { label: 'OS',      value: 'Windows 10+, macOS 12+, Ubuntu 20.04+' },
    { label: 'RAM',     value: '4 GB minimum, 8 GB recommended'          },
    { label: 'Storage', value: '200 MB free disk space'                   },
    { label: 'Display', value: 'Dual display recommended for projection'  },
  ] as const;
</script>

<!-- ── Page meta (SEO) ──────────────────────────────────── -->
<svelte:head>
  <title>Download — Etched Worship</title>
  <meta
    name="description"
    content="Download Etched Worship for free on Windows, macOS, or Linux. Free, open-source church presentation software."
  />
</svelte:head>

<!-- Offset for the fixed navbar -->
<div style="padding-top: 64px;">

  <!-- ══════════════════════════════════════════════════════
       PAGE HEADER
       ══════════════════════════════════════════════════════ -->
  <header class="download-header section--sm" aria-labelledby="download-heading">
    <!-- Decorative glow -->
    <div class="download-header__glow" aria-hidden="true"></div>

    <div class="container download-header__content">
      <span class="section-label">Download</span>
      <h1 id="download-heading">
        Get Etched Worship
      </h1>
      <p class="download-header__sub">
        Free for everyone. No account required. Choose your platform below.
      </p>

      <!-- Version / release badge -->
      <div class="download-header__badges">
        <span class="badge badge-green">
          <!-- Green dot = stable release -->
          <span class="dl-dot" aria-hidden="true"></span>
          Latest: v1.0.0
        </span>
        <a
          href="https://github.com/kenkaroki/Etched-Worship/releases"
          class="badge badge-green"
          target="_blank"
          rel="noopener noreferrer"
          style="text-decoration:none;"
          aria-label="View all releases on GitHub"
        >
          All releases →
        </a>
      </div>
    </div>
  </header>

  <!-- ══════════════════════════════════════════════════════
       PLATFORM DOWNLOAD CARDS
       ══════════════════════════════════════════════════════ -->
  <section class="section--sm download-cards-section" aria-label="Platform downloads">
    <div class="container">
      <div class="download-cards">
        <!--
          Pass each platform definition to DownloadCard.
          When downloadUrl is empty, the card shows "Coming soon".
          Set downloadUrl to a real URL to activate the download button.
        -->
        {#each platforms as p}
          <DownloadCard
            platform={p.platform}
            icon={p.icon}
            fileFormat={p.fileFormat}
            arch={p.arch}
            downloadUrl={p.downloadUrl}
            version={p.version}
          />
        {/each}
      </div>

      <!-- Coming-soon notice -->
      <p class="download-notice" role="note">
        🕐 Installers are currently being prepared.
        <a
          href="https://github.com/kenkaroki/Etched-Worship/releases"
          target="_blank"
          rel="noopener noreferrer"
        >Watch the releases page</a>
        on GitHub to be notified when they are ready.
      </p>
    </div>
  </section>

  <!-- ══════════════════════════════════════════════════════
       SYSTEM REQUIREMENTS
       ══════════════════════════════════════════════════════ -->
  <section class="section--sm requirements" aria-labelledby="req-heading">
    <div class="container">
      <h2 id="req-heading" class="requirements__title">System Requirements</h2>

      <table class="requirements__table" aria-describedby="req-heading">
        <thead>
          <tr>
            <th scope="col">Component</th>
            <th scope="col">Specification</th>
          </tr>
        </thead>
        <tbody>
          {#each requirements as req}
            <tr>
              <td class="requirements__label">{req.label}</td>
              <td>{req.value}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </section>

  <!-- ══════════════════════════════════════════════════════
       BUILD FROM SOURCE (for advanced users)
       ══════════════════════════════════════════════════════ -->
  <section class="section--sm build-source" aria-labelledby="source-heading">
    <div class="container">
      <div class="build-source__card card">
        <!-- Dev icon -->
        <div class="build-source__icon" aria-hidden="true">🛠️</div>

        <div class="build-source__content">
          <h2 id="source-heading">Build from Source</h2>
          <p>
            Prefer to compile Etched Worship yourself? The full source is
            available on GitHub. You will need the Flutter SDK installed.
          </p>

          <!-- Terminal snippet showing clone + run commands -->
          <pre class="build-source__code" aria-label="Clone and run commands"><code><span class="code-comment"># Clone the repository</span>
git clone https://github.com/kenkaroki/Etched-Worship.git
<span class="code-comment"># Enter the control panel</span>
cd Etched-Worship/control_pannel
<span class="code-comment"># Install dependencies and run</span>
flutter pub get &amp;&amp; flutter run</code></pre>
        </div>

        <a
          href="https://github.com/kenkaroki/Etched-Worship"
          class="btn btn-outline"
          id="source-github-btn"
          target="_blank"
          rel="noopener noreferrer"
          style="flex-shrink:0;"
        >
          View Repository
        </a>
      </div>
    </div>
  </section>

</div><!-- end navbar offset wrapper -->

<style>
  /* ════════════════════════════════════════════════════════
     PAGE HEADER
     ════════════════════════════════════════════════════════ */
  .download-header {
    position: relative;
    overflow: hidden;
    text-align: center;
    border-bottom: 1px solid var(--color-outline);
  }

  /* Radial green glow behind header text */
  .download-header__glow {
    position: absolute;
    inset: 0;
    background: radial-gradient(ellipse at 50% 0%, rgba(76,175,80,0.15) 0%, transparent 60%);
    pointer-events: none;
  }

  .download-header__content {
    position: relative;
    z-index: 1;
  }

  .download-header__content h1 {
    margin-bottom: var(--space-4);
    font-size: clamp(2rem, 5vw, 3.5rem);
  }

  .download-header__sub {
    font-size: 1.125rem;
    margin-bottom: var(--space-6);
    margin-inline: auto;
  }

  /* Badges row below subtitle */
  .download-header__badges {
    display: flex;
    gap: var(--space-3);
    justify-content: center;
    flex-wrap: wrap;
  }

  /* Animated release dot */
  .dl-dot {
    display: inline-block;
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: var(--color-primary);
    animation: dlDotPulse 2s ease-in-out infinite;
  }

  @keyframes dlDotPulse {
    0%, 100% { box-shadow: 0 0 0 0 rgba(76,175,80,0.5); }
    50%       { box-shadow: 0 0 0 5px rgba(76,175,80,0); }
  }

  /* ════════════════════════════════════════════════════════
     DOWNLOAD CARDS
     ════════════════════════════════════════════════════════ */
  .download-cards-section {
    border-bottom: 1px solid var(--color-outline);
  }

  /* Three equal-width columns for platform cards */
  .download-cards {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: var(--space-6);
    margin-bottom: var(--space-8);
  }

  /* Notice below the cards explaining the "coming soon" state */
  .download-notice {
    text-align: center;
    font-size: 0.9375rem;
    color: var(--color-text-dim);
    background: var(--color-surface);
    border: 1px solid var(--color-outline);
    border-radius: var(--radius-md);
    padding: var(--space-4) var(--space-6);
    max-width: none;
  }

  .download-notice a {
    color: var(--color-primary-light);
  }

  /* ════════════════════════════════════════════════════════
     SYSTEM REQUIREMENTS TABLE
     ════════════════════════════════════════════════════════ */
  .requirements {
    border-bottom: 1px solid var(--color-outline);
  }

  .requirements__title {
    font-size: 1.5rem;
    margin-bottom: var(--space-6);
  }

  .requirements__table {
    width: 100%;
    border-collapse: collapse;
    background: var(--color-surface);
    border: 1px solid var(--color-outline);
    border-radius: var(--radius-md);
    overflow: hidden;
    font-size: 0.9375rem;
  }

  .requirements__table thead {
    background: var(--color-surface-variant);
  }

  .requirements__table th {
    text-align: left;
    padding: var(--space-3) var(--space-6);
    font-size: 0.75rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    color: var(--color-text-dim);
    border-bottom: 1px solid var(--color-outline);
  }

  .requirements__table td {
    padding: var(--space-4) var(--space-6);
    color: var(--color-text-muted);
    border-bottom: 1px solid rgba(74,106,74,0.2);
  }

  .requirements__table tr:last-child td {
    border-bottom: none;
  }

  /* Label column in bold green */
  .requirements__label {
    font-weight: 600;
    color: var(--color-primary-light) !important;
    width: 140px;
  }

  /* ════════════════════════════════════════════════════════
     BUILD FROM SOURCE
     ════════════════════════════════════════════════════════ */
  .build-source__card {
    display: flex;
    align-items: flex-start;
    gap: var(--space-6);
    flex-wrap: wrap;
  }

  .build-source__icon {
    font-size: 2.5rem;
    flex-shrink: 0;
  }

  .build-source__content {
    flex: 1;
    min-width: 260px;
  }

  .build-source__content h2 {
    font-size: 1.3rem;
    margin-bottom: var(--space-3);
  }

  .build-source__content p {
    font-size: 0.9375rem;
    margin-bottom: var(--space-4);
    max-width: none;
  }

  /* Code block / terminal snippet */
  .build-source__code {
    background: #0a0f0a;
    border: 1px solid var(--color-outline);
    border-radius: var(--radius-sm);
    padding: var(--space-4) var(--space-5);
    overflow-x: auto;
    font-family: var(--font-mono);
    font-size: 0.825rem;
    line-height: 1.8;
    color: #c8e6c9;
    /* Horizontal scroll on small screens */
    -webkit-overflow-scrolling: touch;
  }

  /* Comment lines inside the code block */
  .build-source__code :global(.code-comment) {
    color: var(--color-text-dim);
  }

  .code-comment {
    color: var(--color-text-dim);
  }

  /* ════════════════════════════════════════════════════════
     RESPONSIVE
     ════════════════════════════════════════════════════════ */
  @media (max-width: 768px) {
    /* Stack download cards to one column */
    .download-cards {
      grid-template-columns: 1fr;
      max-width: 400px;
      margin-inline: auto;
    }

    /* Stack build-from-source horizontally too */
    .build-source__card {
      flex-direction: column;
    }
  }
</style>
