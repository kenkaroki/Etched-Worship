# Website - Etched Worship Official Site

The official website for Etched Worship, built with SvelteKit and TypeScript. This site serves as the project homepage, documentation portal, and download hub for the Etched Worship church presentation software.

## Overview

The Etched Worship website is a modern, responsive web application built with cutting-edge web technologies. It provides project information, documentation, and download resources for users interested in the Etched Worship presentation software.

## Features

- **Responsive Design** - Works seamlessly on desktop, tablet, and mobile devices
- **Modern Web Stack** - Built with Svelte 5, SvelteKit, TypeScript, and Vite
- **Fast Performance** - Optimized build process with Vite
- **Type Safety** - Full TypeScript support for better development experience
- **Static Export** - Can be deployed as static content

## Project Structure

```
website/
├── src/
│   ├── app.html                # Main HTML template
│   ├── app.css                 # Global styles
│   ├── app.d.ts               # TypeScript declarations
│   ├── routes/
│   │   ├── +layout.svelte      # Root layout
│   │   ├── +layout.ts          # Layout server logic
│   │   ├── +page.svelte        # Home page
│   │   └── download/           # Download section
│   ├── lib/                    # Shared utilities and components
│   └── svelte.config.js        # Svelte configuration
├── static/
│   └── robots.txt              # SEO robots file
├── build/                      # Build output (auto-generated)
├── package.json                # Project dependencies
├── tsconfig.json               # TypeScript configuration
├── vite.config.ts              # Vite build configuration
└── README.md                   # This file
```

## Technology Stack

- **Frontend Framework** - Svelte 5 with SvelteKit
- **Language** - TypeScript
- **Build Tool** - Vite
- **Styling** - CSS (with design system support)
- **Fonts** - Inter font via Google Fonts

## Dependencies

### Dev Dependencies

- `@sveltejs/adapter-auto` - Automatic adapter detection
- `@sveltejs/adapter-static` - Static site adapter
- `@sveltejs/kit` - SvelteKit framework
- `@sveltejs/vite-plugin-svelte` - Svelte plugin for Vite
- `svelte` - Svelte compiler
- `svelte-check` - Type checking for Svelte
- `typescript` - TypeScript support
- `vite` - Build tool

## Getting Started

### Prerequisites

- Node.js (16.0.0 or higher)
- npm (7.0.0 or higher) or yarn/pnpm

### Installation

1. Navigate to the website directory:

   ```bash
   cd website
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

The site will be available at `http://localhost:5173` (or another port if 5173 is in use).

## Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm run preview` - Preview the production build locally
- `npm run check` - Run type checking with svelte-check
- `npm run check:watch` - Run type checking in watch mode

## Development

### Project Structure

- **`src/routes/`** - Page routes and layouts
  - `+page.svelte` - Home page component
  - `+layout.svelte` - Root layout component
  - `download/` - Download page and resources
- **`src/lib/`** - Shared components and utilities
- **`static/`** - Static assets (robots.txt, images, etc.)

### Styling

The site uses CSS with the following design guidelines:

- Primary color: Green (#4CAF50) - set in theme-color meta tag
- Font: Inter (loaded from Google Fonts)
- Responsive breakpoints for mobile, tablet, and desktop

### SEO Configuration

Meta tags are configured in:

- `src/app.html` - Base SEO meta tags
- Individual `+page.svelte` files - Page-specific overrides

Default meta description: "Etched Worship — free, open-source church presentation software for Windows, macOS, and Linux."

### Building

#### Development Build

```bash
npm run dev
```

#### Production Build

```bash
npm run build
npm run preview
```

#### Static Export

The site is configured to export as static HTML using `@sveltejs/adapter-static`.

## Deployment

### Static Hosting

The website can be deployed to any static hosting service:

- Vercel (recommended for SvelteKit)
- Netlify
- GitHub Pages
- Cloudflare Pages
- AWS S3

### Build and Deploy

1. Build the site:

   ```bash
   npm run build
   ```

2. The output is in the `build/` directory
3. Deploy the `build/` folder to your hosting service

### Environment Variables

Create a `.env.local` file if needed for environment-specific configurations.

## Type Checking

The project uses TypeScript and Svelte type checking:

```bash
# Check types once
npm run check

# Check types in watch mode
npm run check:watch
```

## Component Development

### Creating New Components

1. Create a `.svelte` file in `src/lib/` or appropriate route
2. Use TypeScript for script blocks:

   ```svelte
   <script lang="ts">
     let message: string = "Hello";
   </script>
   ```

3. Style with scoped CSS:
   ```svelte
   <style>
     :global(body) { /* global styles */ }
     /* component styles are automatically scoped */
   </style>
   ```

## Theming and Customization

### Colors

The primary color is green (#4CAF50), configured in:

- `src/app.html` - Meta theme color
- Global CSS - Override as needed

### Typography

- Font Family: Inter
- Sizes: Adjust in CSS as needed
- Weights: 300, 400, 500, 600, 700, 800, 900 available

## Testing

TypeScript provides basic type safety testing. For runtime testing, consider adding:

- Vitest for unit testing
- Playwright for e2e testing

## Troubleshooting

### Port already in use

```bash
npm run dev -- --port 3000
```

### Build errors

```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Type checking errors

```bash
npm run check
```

### Hot reload not working

- Ensure you're editing `.svelte` files
- Save the file to trigger hot reload
- Check that `npm run dev` is still running

## Performance

- Optimized with Vite for fast development and production builds
- Svelte's compiler output produces minimal JavaScript
- Static export for optimal deployment performance
- Google Fonts preconnect for faster font loading

## License

This project is part of Etched Worship and is licensed under the MIT License.

## Support

For issues or questions specific to the website, please refer to the main project [CONTRIBUTORS.md](../CONTRIBUTORS.md) file for contribution guidelines.

## Additional Resources

- [SvelteKit Documentation](https://kit.svelte.dev)
- [Svelte Documentation](https://svelte.dev)
- [Vite Documentation](https://vitejs.dev)
- [TypeScript Documentation](https://www.typescriptlang.org)

## Developing

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:

```sh
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

To create a production version of your app:

```sh
npm run build
```

You can preview the production build with `npm run preview`.

> To deploy your app, you may need to install an [adapter](https://svelte.dev/docs/kit/adapters) for your target environment.
