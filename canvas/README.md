# Canvas - Etched Worship Display Application

The Canvas application is a Flutter-based display client for Etched Worship. It monitors and displays content from the stack in real-time, providing a clean, responsive interface for projecting worship materials during church services.

## Overview

Canvas is designed to run on extended display and serves as the visual output component of the Etched Worship system. It communicates with the Control Panel to receive content updates and display them automatically.

## Features

- **Real-time Content Updates** - Monitors stack files for changes and updates display automatically
- **Responsive Display** - Auto-scaling text that adapts to any screen size
- **File-based Communication** - Reads content from stack files for simple, file-based inter-application communication
- **Cross-platform Support** - Runs on Windows, macOS, and Linux

## Project Structure

```
canvas/
├── lib/
│   ├── main.dart                 # Application entry point
│   └── services/
│       └── stack_reader.dart     # Stack file reading logic
├── build/                        # Build artifacts (auto-generated)
├── windows/                      # Windows platform configuration
├── macos/                        # macOS platform configuration
├── linux/                        # Linux platform configuration
├── pubspec.yaml                  # Dart dependencies
├── analysis_options.yaml         # Lint rules
└── README.md                     # This file
```

## Dependencies

- `flutter` - Flutter SDK framework
- `cupertino_icons` - iOS-style icons
- `auto_size_text` - Responsive text scaling

## Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK (included with Flutter)
- Platform-specific development tools:
  - **Windows**: Visual Studio 2019+ or clang toolchain
  - **macOS**: Xcode 12.0+
  - **Linux**: build-essential, cmake, pkg-config, libgtk-3-dev

### Installation

1. Navigate to the canvas directory:

   ```bash
   cd canvas
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

### Running on Specific Platforms

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## Usage

1. Start the Canvas application on your display device
2. The app will automatically:
   - Monitor the stack file for content changes
   - Display new content when updates are received
   - Update the display every second

3. Content is controlled through the Control Panel application

## Architecture

### Main Components

- **EtchedWorshipCanvas** - Main application widget
- **Stack Reader** - Service that reads and monitors stack files
- **Auto-scaling Display** - Responsive text widget that adapts to screen size

### Communication Flow

```
Control Panel → Stack File → Canvas Display
```

The Control Panel writes updates to the stack file, which Canvas continuously monitors and displays.

## Development

### File Structure Details

- `main.dart` - Contains the application entry point, main widget, and display logic
- `services/stack_reader.dart` - Handles reading and parsing of stack files

### Building

```bash
# Build for Windows
flutter build windows

# Build for macOS
flutter build macos

# Build for Linux
flutter build linux
```

### Debugging

Enable debug output by running with verbose logging:

```bash
flutter run -v
```

## Testing

Currently, the project uses Flutter's default testing structure. Tests can be added to the `test/` directory.

## Configuration

Configuration and theming can be modified in `main.dart`. The app currently uses Material Design theming.

## Troubleshooting

### Application won't start

- Ensure Flutter is properly installed: `flutter doctor`
- Check that you're in the correct directory
- Try cleaning the build: `flutter clean` then `flutter pub get`

### Content not updating

- Verify the stack file path is correct
- Check file permissions
- Ensure the Control Panel is writing updates to the correct location

### Display issues

- Restart the application
- Try full-screen mode
- Check display resolution compatibility

## Performance Considerations

- Content updates check every 1 second
- Auto-scaling text may need tuning for very large displays
- Consider removing debug prints in production builds

## License

This project is part of Etched Worship and is licensed under the MIT License.

## Support

For issues or questions specific to Canvas, please refer to the main project [CONTRIBUTORS.md](../CONTRIBUTORS.md) file for contribution guidelines.
