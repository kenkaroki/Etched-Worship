# Etched Worship

Free, open-source church presentation software for Windows, macOS, and Linux.

Etched Worship is a comprehensive solution for managing and displaying worship content during church services. It provides an intuitive control panel for managing displays, music, and presentation slides, with a dedicated canvas application for displaying content to congregations.

## Project Overview

Etched Worship consists of three main components working together to provide a complete presentation and control system:

### 📱 Components

- **Canvas** - A Flutter application that displays worship content on presentation screens via extended display. Monitors and displays content from the stack in real-time.
- **Control Panel** - A Flutter application that serves as the control interface for managing displays, adding media, and managing music playback.
- **Website** - A Svelte-based website built with SvelteKit that serves as the project homepage and documentation portal.

## Project Structure

```
etched-worship/
├── canvas/              # Canvas display application (Flutter)
├── control_pannel/      # Control panel application (Flutter)
├── website/             # Project website (SvelteKit + Svelte)
├── LICENSE              # MIT License
└── README.md            # This file
```

## Getting Started

### Prerequisites

- **For Flutter Apps (Canvas & Control Panel)**
  - Flutter SDK (version 3.9.0 or higher)
  - Dart SDK (included with Flutter)
  - Platform-specific requirements:
    - Windows: Visual Studio 2019+ or clang toolchain
    - macOS: Xcode 12.0+
    - Linux: build-essential, cmake, pkg-config, libgtk-3-dev

- **For Website**
  - Node.js (16.0.0 or higher)
  - npm or yarn

### Quick Start

#### Canvas Application

```bash
cd canvas
flutter pub get
flutter run -d <platform>
```

#### Control Panel Application

```bash
cd control_pannel
flutter pub get
flutter run -d <platform>
```

#### Website

```bash
cd website
npm install
npm run dev
```

For detailed setup instructions, refer to the individual README files:

- [Canvas README](canvas/README.md)
- [Control Panel README](control_pannel/README.md)
- [Website README](website/README.md)

## Features

### Canvas

- Real-time content display
- File monitoring for dynamic content updates
- Responsive UI with auto-scaling text
- Support for displaying stack-based content

### Control Panel

- Multi-display management interface
- Media file selection and management
- Music playback controls
- Theme support (Light/Dark modes)
- Organized routing and screen management

### Website

- Project information and documentation
- Download resources
- Built with modern web standards (SvelteKit, TypeScript, Vite)
- Responsive design

## Development

### Technology Stack

- **Mobile/Desktop**: Flutter, Dart
- **Web**: Svelte, SvelteKit, TypeScript, Vite
- **Build**: Flutter build system, Vite

### Code Organization

Each component follows standard project conventions:

- `lib/` - Source code
- `test/` - Test files
- `build/` - Build artifacts (generated)
- Platform-specific folders: `windows/`, `macos/`, `linux/`

## Contributing

We welcome contributions! Please see [CONTRIBUTORS.md](CONTRIBUTORS.md) for detailed guidelines on:

- Setting up your development environment
- Code style and conventions
- Submitting pull requests
- Reporting issues

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or suggestions, please open an issue on the project repository.

## Acknowledgments

- Built with [Flutter](https://flutter.dev) and [Svelte](https://svelte.dev)
- Designed for churches and worship teams worldwide
