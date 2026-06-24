# Contributing to Etched Worship

First, thank you for your interest in contributing to Etched Worship! We welcome contributions from everyone. This document provides guidelines and instructions for contributing to the project.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [Making Changes](#making-changes)
5. [Coding Standards](#coding-standards)
6. [Commit Guidelines](#commit-guidelines)
7. [Pull Request Process](#pull-request-process)
8. [Reporting Issues](#reporting-issues)
9. [Questions](#questions)

## Code of Conduct

- Be respectful and inclusive
- Welcome feedback and constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members
- Harassment, discrimination, or offensive behavior is not tolerated

## Getting Started

1. **Fork the Repository** - Create a personal fork of the project
2. **Clone Your Fork** - Clone your forked repository to your local machine
3. **Create a Branch** - Create a feature branch for your changes
4. **Make Your Changes** - Implement your feature or fix
5. **Test Thoroughly** - Ensure your changes work correctly
6. **Submit a Pull Request** - Push your changes and create a PR

## Development Setup

### Prerequisites

- **For Flutter Apps (Canvas & Control Panel)**
  - Flutter SDK (3.9.0+)
  - Dart SDK (included with Flutter)
  - Platform-specific tools (see platform README for details)

- **For Website**
  - Node.js (16.0.0+)
  - npm (7.0.0+) or yarn

### Clone and Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/etched-worship.git
cd etched-worship

# For Flutter apps
cd canvas
flutter pub get
flutter run

# For website
cd ../website
npm install
npm run dev
```

### Verify Installation

```bash
# Flutter
flutter doctor

# Node/npm
node --version
npm --version
```

## Making Changes

### Project Structure

The project consists of three main components:

1. **Canvas** (`/canvas`) - Flutter display application
2. **Control Panel** (`/control_pannel`) - Flutter control application
3. **Website** (`/website`) - SvelteKit website

### Choosing What to Work On

- Browse existing issues for bugs or feature requests
- Check "help wanted" or "good first issue" labels for beginner-friendly tasks
- Discuss larger features in an issue before implementing

### Creating a Feature Branch

```bash
# Create and switch to a feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

## Coding Standards

### General Standards

- **Code Quality** - Write clean, readable, maintainable code
- **Comments** - Add meaningful comments for complex logic
- **No Debug Code** - Remove debug prints and console logs before committing
- **No Commented Code** - Remove commented-out code blocks

### Dart/Flutter Standards

- **Naming** - Use camelCase for variables/functions, PascalCase for classes
- **Formatting** - Run `flutter format .` before committing
- **Analysis** - Ensure no lint warnings: `flutter analyze`
- **Documentation** - Add dartdoc comments to public APIs

```dart
/// Reads content from the stack file.
///
/// Returns the content as a comma-separated string.
Future<String> readStack() async {
  // implementation
}
```

### TypeScript/Svelte Standards

- **Naming** - Use camelCase for variables, PascalCase for components
- **Formatting** - The project uses Prettier configuration (if configured)
- **Type Safety** - Always use TypeScript types
- **No Any** - Avoid using `any` type; be specific

```typescript
// Good
interface User {
  id: string;
  name: string;
}

function getUser(id: string): User {
  // implementation
}

// Avoid
function getUser(id: any): any {
  // implementation
}
```

## Commit Guidelines

### Commit Message Format

Use clear, descriptive commit messages following this pattern:

```
[Component] Brief description

Detailed explanation of the changes, if needed.
```

Examples:

```
[Canvas] Fix real-time content update timer
[Control Panel] Add file picker for media selection
[Website] Update download page layout
[All] Update dependencies to latest versions
```

### Best Practices

- **Small, Focused Commits** - One logical change per commit
- **Atomic Commits** - Each commit should be independently testable
- **No Merge Commits** - Rebase before pushing
- **Reference Issues** - Include issue numbers: "Fixes #123"

```bash
# Good commit
git commit -m "[Canvas] Fix timer not resetting on content update

- Reset timer when new content is detected
- Prevent memory leaks from timer accumulation
- Fixes #45"

# Avoid
git commit -m "Fixed stuff"
git commit -m "WIP: trying something"
```

## Pull Request Process

### Before Submitting

1. **Test Thoroughly**
   - Run all existing tests
   - Test on multiple platforms if applicable
   - Test your specific changes

2. **Code Quality**
   - Run formatters: `flutter format .` or Prettier
   - Run linters: `flutter analyze` or `npm run check`
   - Review your own code first

3. **Documentation**
   - Update README if needed
   - Add comments to complex code
   - Update any related documentation

4. **Update Your Branch**
   ```bash
   git fetch origin
   git rebase origin/main
   git push --force-with-lease origin feature/your-feature
   ```

### Submitting a PR

1. Push your changes to your fork
2. Go to the original repository
3. Click "New Pull Request"
4. Fill in the PR template with:
   - **Title**: Brief, descriptive title
   - **Description**: What changes you made and why
   - **Related Issues**: Link any related issues (#123)
   - **Type**: Bug fix, feature, documentation, etc.

### PR Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Breaking change

## Related Issues

Fixes #(issue number)

## Testing

- [ ] Tested on Windows
- [ ] Tested on macOS
- [ ] Tested on Linux
- [ ] Added/updated tests

## Checklist

- [ ] Code follows project style guidelines
- [ ] No debug code or commented-out lines
- [ ] Updated documentation
- [ ] Changes don't break existing functionality
```

### PR Review

- At least one maintainer review required
- Address feedback promptly
- Push additional commits to the same branch
- Don't force-push after review starts (unless requested)

## Reporting Issues

### Before Reporting

- Search existing issues to avoid duplicates
- Check the FAQ in README files
- Try troubleshooting steps from documentation

### Issue Template

```markdown
## Description

Clear description of the issue

## Reproduction Steps

1. Step 1
2. Step 2
3. Step 3

## Expected Behavior

What should happen

## Actual Behavior

What actually happens

## Environment

- Platform: Windows/macOS/Linux
- Component: Canvas/Control Panel/Website
- Version: If applicable

## Screenshots

Add screenshots if applicable
```

### Issue Labels

- `bug` - Something isn't working
- `feature` - Feature request
- `documentation` - Documentation improvement
- `good first issue` - Good for newcomers
- `help wanted` - Needs community contribution
- `question` - Question/discussion

## Questions

### Getting Help

- **GitHub Discussions** - Ask questions (if enabled)
- **GitHub Issues** - Ask in relevant issue
- **Documentation** - Check README files first

### Discussions

- Be respectful and constructive
- Provide context and details
- Search previous discussions first

## Recognition

Contributors will be recognized in:

- Project README
- Release notes for major contributions
- Git commit history

Thank you for contributing to Etched Worship! 🎉

---

For more information, see the main [README.md](README.md) file.

**Last Updated**: June 2026
