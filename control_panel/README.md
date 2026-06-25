# Control Panel - Etched Worship Management Application

The Control Panel is a Flutter-based desktop application that serves as the primary control interface for Etched Worship. It provides an intuitive interface for managing displays, adding media, handling music playback, and controlling the content shown on presentation screens.

## Overview

Control Panel is designed to run on a control device (laptop, desktop computer) and provides the main user interface for managing worship presentations. It communicates with the Canvas application(s) to control what content is displayed.

## Features

- **Display Management** - Create and manage multiple display configurations
- **Media Management** - Add, organize, and display media files (images, videos, text)
- **Music Controls** - Manage music playback during worship sessions
- **Multi-screen Support** - Control multiple Canvas displays simultaneously
- **Theme Support** - Built-in light and dark theme modes that adapt to system settings
- **Organized Navigation** - Clean routing system with dedicated screens for different functions

## Project Structure

```
control_pannel/
├── lib/
│   ├── main.dart                          # Application entry point and routing
│   ├── models/                            # Data models and business logic
│   ├── screens/
│   │   ├── Homes.dart                     # Home/dashboard screen
│   │   ├── create_display/
│   │   │   └── create_display.dart        # Display creation/configuration
│   │   └── music/
│   │       └── music_page.dart            # Music playback controls
│   ├── services/                          # Application services
│   └── themes/
│       └── app_themes.dart                # Light and dark theme definitions
├── build/                                 # Build artifacts (auto-generated)
├── windows/                               # Windows platform configuration
├── macos/                                 # macOS platform configuration
├── linux/                                 # Linux platform configuration
├── pubspec.yaml                           # Dart dependencies
├── analysis_options.yaml                  # Lint rules
└── README.md                              # This file
```

## Dependencies

- `flutter` - Flutter SDK framework
- `cupertino_icons` - iOS-style icons
- `file_picker` - File selection dialog
- `path_provider` - System paths for file storage

## Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK (included with Flutter)
- Platform-specific development tools:
  - **Windows**: Visual Studio 2019+ or clang toolchain
  - **macOS**: Xcode 12.0+
  - **Linux**: build-essential, cmake, pkg-config, libgtk-3-dev

### Installation

1. Navigate to the control_pannel directory:

   ```bash
   cd control_pannel
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

### Main Workflow

1. **Start the Application** - Launch Control Panel on your control device
2. **Home Screen** - View the dashboard with available options
3. **Create Display** - Set up new display configurations or media layouts
4. **Add Media** - Use the file picker to select images, videos, or other media
5. **Music** - Access music playback controls and playlists
6. **Control Canvas** - Updates automatically appear on connected Canvas displays

### Navigation

The application uses Flutter's routing system:

- `/` - Home screen
- `/AddDisplay` - Add/create display configuration
- `/Music` - Music playback screen

## Architecture

### Main Components

- **MyApp** - Root application widget with routing configuration
- **Home** - Dashboard screen
- **AddMedia** - Display creation and media management
- **MusicPage** - Music playback interface
- **AppThemes** - Theme configuration for light/dark modes

### File Organization

- `models/` - Data structures for displays, media, music, etc.
- `screens/` - UI screens for different features
- `services/` - Business logic and external service integration
- `themes/` - Application theming and styling

### Communication Flow

```
Control Panel → Stack File → Canvas Display(s)
```

The Control Panel writes commands and content to a shared stack file that the Canvas application(s) monitor and display.

## Development

### Theme System

The app supports both light and dark themes:

- Light theme - Default Material Light theme
- Dark theme - Material Dark theme
- Adapts to system theme by default

Themes are defined in `themes/app_themes.dart`.

### Adding New Screens

1. Create a new file in `screens/` directory
2. Define the screen widget
3. Add route to `main.dart` routes map
4. Add navigation button on appropriate screen

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

## File Formats

### Stack File Format

Content is communicated via stack files with comma-separated values:

```
content_line_1,content_line_2,content_line_3
```

The Control Panel writes to this format, and Canvas reads and displays the content.

## Testing

Currently, the project uses Flutter's default testing structure. Tests can be added to the `test/` directory.

## Troubleshooting

### Application won't start

- Ensure Flutter is properly installed: `flutter doctor`
- Check that you're in the correct directory
- Try cleaning the build: `flutter clean` then `flutter pub get`

### File picker not working

- Verify file permissions
- Check that the file browser has necessary permissions
- Try selecting a different location

### Theme not applying

- Restart the application
- Clear app cache: `flutter clean`
- Check system theme settings

### Canvas not receiving updates

- Verify the stack file path is correct on both applications
- Ensure both applications have read/write permissions to the file
- Check that Canvas is running and monitoring the file

## Performance Considerations

- Media files are loaded on-demand
- Large playlists may need pagination
- Consider hardware acceleration for video playback
- Monitor memory usage with multiple media files

## License

This project is part of Etched Worship and is licensed under the MIT License.

## Support

For issues or questions specific to Control Panel, please refer to the main project [CONTRIBUTORS.md](../CONTRIBUTORS.md) file for contribution guidelines.
