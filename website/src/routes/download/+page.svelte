<script lang="ts">
  import { onMount } from 'svelte';
  import DownloadCard from '$lib/components/DownloadCard.svelte';

  // ── Types ─────────────────────────────────────────────────
  interface Platform {
    platform: 'Windows' | 'macOS' | 'Linux';
    icon: string;
    fileFormat: string;
    arch: string;
    downloadUrl: string;
    version: string;
  }

  // ── Reactive State ────────────────────────────────────────
  let latestVersion = 'v1.0.0';
  let isLoading = true;
  let hasError = false;

  let platforms: Platform[] = [
    {
      platform:    'Windows',
      icon:        '🪟',
      fileFormat:  '.exe Installer',
      arch:        '64-bit (x86_64)',
      downloadUrl: '',
      version:     '--',
    },
    {
      platform:    'macOS',
      icon:        '🍎',
      fileFormat:  '.dmg Package', // Note: Your workflow currently builds an extensionless binary, updated below accordingly.
      arch:        'Apple Silicon & Intel',
      downloadUrl: '',
      version:     '--',
    },
    {
      platform:    'Linux',
      icon:        '🐧',
      fileFormat:  'Binary Installer',
      arch:        '64-bit (x86_64)',
      downloadUrl: '',
      version:     '--',
    },
  ];

  // ── Requirements data ─────────────────────────────────────
  const requirements = [
    { label: 'OS',      value: 'Windows 10+, macOS 12+, Ubuntu 20.04+' },
    { label: 'RAM',     value: '4 GB minimum, 8 GB recommended'          },
    { label: 'Storage', value: '70 MB free disk space'                   },
    { label: 'Display', value: 'Dual / Extended display recommended for projection'  },
  ] as const;

  // ── Fetch Releases from GitHub ────────────────────────────
  onMount(async () => {
    try {
      const res = await fetch('https://api.github.com/repos/kenkaroki/Etched-Worship/releases/latest');
      if (!res.ok) throw new Error('Failed to fetch release info');
      
      const data = await res.json();
      latestVersion = data.tag_name; // e.g., "installer-1.0.0"

      // Update the platforms array with actual asset URLs
      platforms = platforms.map(p => {
        // Map local platform name to workflow naming scheme
        const workflowPlatform = p.platform.toLowerCase(); // 'windows', 'macos', 'linux'
        
        // Find the asset that matches your workflow's naming scheme:
        // "Etched Worship {platform}-{version} installer"
        const asset = data.assets.find((a: any) => 
          a.name.toLowerCase().includes(`etched worship ${workflowPlatform}`) &&
          a.name.toLowerCase().includes('installer')
        );

        if (asset) {
          return {
            ...p,
            downloadUrl: asset.browser_download_url,
            version: data.tag_name.replace('installer-', 'v') // Formats "installer-1.0.0" to "v1.0.0"
          };
        }
        return p;
      });
    } catch (error) {
      console.error('Error fetching release assets:', error);
      hasError = true;
    } finally {
      isLoading = false;
    }
  });
</script>

<svelte:head>
  <title>Download — Etched Worship</title>
  <meta
    name="description"
    content="Download Etched Worship for free on Windows, macOS, or Linux. Free, open-source church presentation software."
  />
</svelte:head>

<div style="padding-top: 64px;">

  <header class="download-header section--sm" aria-labelledby="download-heading">
    <div class="download-header__glow" aria-hidden="true"></div>

    <div class="container download-header__content">
      <span class="section-label">Download</span>
      <h1 id="download-heading">Get Etched Worship</h1>
      <p class="download-header__sub">
        Free for everyone. No account required. Choose your platform below.
      </p>

      <div class="download-header__badges">
        <span class="badge badge-green">
          <span class="dl-dot" aria-hidden="true"></span>
          Latest: {latestVersion.replace('installer-', 'v')}
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

  <section class="section--sm download-cards-section" aria-label="Platform downloads">
    <div class="container">
      {#if isLoading}
        <div style="text-align: center; padding: var(--space-8); color: var(--color-text-dim);">
          Retrieving live download links from GitHub...
        </div>
      {:else}
        <div class="download-cards">
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

        {#if platforms.every(p => !p.downloadUrl)}
          <p class="download-notice" role="note">
            🕐 Installers are currently being prepared or failed to load.
            <a href="https://github.com/kenkaroki/Etched-Worship/releases" target="_blank" rel="noopener noreferrer">
              Watch the releases page
            </a> on GitHub to download manually.
          </p>
        {/if}
      {/if}
    </div>
  </section>

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

  <section class="section--sm build-source" aria-labelledby="source-heading">
    <div class="container">
      <div class="build-source__card card">
        <div class="build-source__icon" aria-hidden="true">🛠️</div>

        <div class="build-source__content">
          <h2 id="source-heading">Build from Source</h2>
          <p>
            Prefer to compile Etched Worship yourself? The full source is
            available on GitHub. You will need the Flutter SDK installed.
          </p>

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

</div>

<style>
  /* Keep your existing component CSS styling intact below */
  .download-header {
    position: relative;
    overflow: hidden;
    text-align: center;
    border-bottom: 1px solid var(--color-outline);
  }
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
  .download-header__badges {
    display: flex;
    gap: var(--space-3);
    justify-content: center;
    flex-wrap: wrap;
  }
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
  .download-cards-section {
    border-bottom: 1px solid var(--color-outline);
  }
  .download-cards {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: var(--space-6);
    margin-bottom: var(--space-8);
  }
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
  .requirements__label {
    font-weight: 600;
    color: var(--color-primary-light) !important;
    width: 140px;
  }
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
    -webkit-overflow-scrolling: touch;
  }
  .build-source__code :global(.code-comment) {
    color: var(--color-text-dim);
  }
  .code-comment {
    color: var(--color-text-dim);
  }
  @media (max-width: 768px) {
    .download-cards {
      grid-template-columns: 1fr;
      max-width: 400px;
      margin-inline: auto;
    }
    .build-source__card {
      flex-direction: column;
    }
  }
</style>