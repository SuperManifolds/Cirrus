# Contributing to Cirrus

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Getting Started

### Prerequisites

- Xcode 26 or later
- macOS 26.4 or later
- An Apple Developer account (for WeatherKit provider)

### Development Setup

1. **Clone the repository**

```bash
git clone https://github.com/SuperManifolds/Cirrus.git
cd Cirrus
```

2. **Open in Xcode**

```bash
open Cirrus.xcodeproj
```

3. **Configure signing**

Select your development team in the project settings for the Cirrus target.

4. **Build and run**

Press `Cmd+R` or build from the Product menu.

## Development Workflow

### Running Tests

```bash
# Run unit tests
xcodebuild -project Cirrus.xcodeproj -scheme Cirrus \
  -only-testing:CirrusTests test \
  -parallel-testing-enabled NO

# Or run from Xcode with Cmd+U
```

### Code Quality

Before submitting changes, ensure your code passes quality checks:

```bash
# Build the project
xcodebuild -project Cirrus.xcodeproj -scheme Cirrus -configuration Debug build

# Run SwiftLint
swiftlint lint
```

- **Zero warnings policy** — all SwiftLint warnings must be resolved
- Do not silence warnings with `swiftlint:disable` without maintainer approval

### Code Style

This project follows the conventions outlined in [AGENTS.md](AGENTS.md):

- Build with Xcode after every change and verify zero warnings/errors
- Avoid excessive nesting (prefer early returns, extract helper functions)
- Keep functions small and focused on a single responsibility
- Follow Swift naming conventions and idiomatic patterns
- Use constants from `LayoutConstants` for magic numbers, colors, spacing, and layout values
- Prefer declarative patterns (`map`, `filter`, `compactMap`) over imperative loops
- Keep views focused on UI — business logic goes in ViewModels or Services
- All views should have `#Preview` blocks with realistic data
- Use `String(localized:)` for all user-facing strings
- Do not extract sub-views into `private var` computed properties — use separate structs
- Use protocols for testability and SwiftUI previews

### LLM and AI Assistance

Using LLMs and AI coding assistants is allowed, but requires deliberate and responsible use.

Core principles:

- **You are accountable** — You are responsible for all code you submit, regardless of how it was written
- **Understand your code** — Don't submit code you can't explain; be prepared to discuss every line in review
- **Verify everything** — Always review, test, and understand LLM-generated code before committing
- **Respect reviewer time** — Don't dump unreviewed LLM output into PRs

## Making Changes

### Branch Naming

```
githubusername/<issue-id>-description
```

```bash
git checkout -b yourname/123-add-weather-widget
# or for bug fixes
git checkout -b yourname/456-fix-location-search
```

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` — New feature
- `fix:` — Bug fix
- `refactor:` — Code refactoring
- `docs:` — Documentation changes
- `test:` — Adding or updating tests
- `chore:` — Maintenance tasks

### Pull Requests

1. **Ensure the project builds with zero warnings**
2. **Run tests** with `Cmd+U`
3. **Push your changes** and open a Pull Request on GitHub
4. **Fill out the PR template** with a clear description
5. **Respond to feedback** — address review comments and push additional commits

## Project Structure

```
Cirrus/
├── App/                    # App entry point (CirrusApp.swift)
├── Extensions/             # Swift extensions (Measurement+Formatting)
├── Models/                 # Data models (CurrentWeather, HourlyForecast, etc.)
├── Protocols/              # Protocols and mocks (WeatherProviding, LocationProviding)
├── Services/               # API clients and services (OpenMeteoService, WeatherKitService, etc.)
├── ViewModels/             # MVVM view models (WeatherViewModel, SettingsViewModel)
├── Views/
│   ├── Components/         # Reusable components (WeatherDetailCard, SparklineView, etc.)
│   ├── MenuBar/            # Menu bar popover and label
│   ├── Popover/            # Weather display views (CurrentConditions, HourlyScroll, etc.)
│   └── Settings/           # Settings window tabs
CirrusTests/                # Unit tests
CirrusUITests/              # UI tests
```

## Reporting Issues

**When reporting bugs:**

- Include steps to reproduce
- Include macOS version
- Include which weather provider is selected (Open-Meteo or WeatherKit)

**For feature requests:**

- Describe the use case
- Provide examples of how it would work

## Questions?

If you have questions about contributing, feel free to open a discussion on GitHub.

Thank you for contributing to Cirrus!
