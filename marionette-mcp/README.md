# Marionette MCP Plugin

MCP server integration for Claude Code to interact with running Flutter applications at runtime.

## Overview

This plugin provides Claude Code with the ability to debug, test, and interact with Flutter applications through the Marionette MCP server. Connect to any running Flutter app and use AI-powered commands to inspect widgets, simulate taps, enter text, scroll views, capture screenshots, and hot reload.

## Features

- **Widget Inspection** - View all interactive elements on screen
- **Tap Simulation** - Tap buttons and interactive elements
- **Text Entry** - Enter text into form fields
- **Scroll Control** - Scroll to bring elements into view
- **Screenshot Capture** - Take screenshots of current UI state
- **Log Retrieval** - View application logs for debugging
- **Hot Reload** - Reload code without losing app state

## Prerequisites

### 1. Flutter App Setup

Add `marionette_flutter` to your Flutter app:

```bash
flutter pub add marionette_flutter
```

Initialize `MarionetteBinding` in `main.dart`:

```dart
import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  MarionetteBinding.ensureInitialized();
  runApp(const MyApp());
}
```

### 2. Install Marionette MCP Server

```bash
dart pub global activate marionette_mcp
```

### 3. Claude Code Plugin Installation

Copy this plugin to your Claude Code plugins directory:

```bash
# Option 1: Copy to project plugins
cp -r marionette-mcp .claude-plugin/

# Option 2: Copy to global plugins
cp -r marionette-mcp ~/.claude/plugins/
```

## Usage

### 1. Start Your Flutter App

Run your Flutter app in debug mode:

```bash
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d android         # Android
flutter run -d ios             # iOS
```

### 2. Find the VM Service URI

Look in the console output for the VM Service URI:

```
The Flutter DevTools debugger and profiler on... is available at: ws://127.0.0.1:54321/ws
```

### 3. Connect Using MCP Tools

Use the `connect` tool with the URI:

```
Use connect with uri="ws://127.0.0.1:54321/ws"
```

### 4. Interact with Your App

| Task | Command |
|------|---------|
| List interactive elements | `get_interactive_elements` |
| Tap a button | `tap` with `key` or `text` |
| Enter text | `enter_text` with `key` and `text` |
| Scroll to element | `scroll_to` with `key` or `text` |
| Get app logs | `get_logs` |
| Take screenshot | `take_screenshots` |
| Hot reload | `hot_reload` |
| Disconnect | `disconnect` |

## Available MCP Tools

| Tool | Purpose |
|------|---------|
| `connect` | Connect to Flutter app via VM Service URI |
| `disconnect` | End current connection |
| `get_interactive_elements` | List all interactive UI elements |
| `tap` | Tap element by key or text |
| `enter_text` | Enter text into field |
| `scroll_to` | Scroll until element visible |
| `get_logs` | Retrieve application logs |
| `take_screenshots` | Capture screenshots as base64 |
| `hot_reload` | Hot reload Flutter app |

## Example Workflows

### Debug Unresponsive Button

```
1. Use connect with uri="ws://127.0.0.1:54321/ws"
2. Use get_interactive_elements to find the button
3. Use tap with key="my_button"
4. Use get_logs to check for errors
5. Use take_screenshots to verify state
```

### Test a Login Form

```
1. Use connect with uri="ws://127.0.0.1:54321/ws"
2. Use enter_text with key="email_field" and text="user@example.com"
3. Use enter_text with key="password_field" and text="secret123"
4. Use scroll_to with text="Login"
5. Use tap with text="Login"
6. Use get_logs and take_screenshots to verify result
```

### Smoke Test After Refactor

```
1. Use connect with uri="ws://127.0.0.1:54321/ws"
2. Use get_interactive_elements for each screen
3. Use tap to navigate through key flows
4. Use get_logs to verify no exceptions
5. Use hot_reload after making code changes
6. Repeat verification
```

## Custom Widget Configuration

For custom widgets that aren't automatically detected:

```dart
MarionetteBinding.ensureInitialized(
  MarionetteConfiguration(
    // Register custom interactive widgets
    isInteractiveWidget: (type) => type == MyCustomButton,
    // Extract text from custom widgets
    extractText: (element) => element.text,
    // Configure log collection
    logCollector: LoggingLogCollector(),
    // Adjust screenshot size (default 2000x2000)
    maxScreenshotSize: Size(2000, 2000),
  ),
);
```

## Troubleshooting

### "Not connected to any app"

Ensure `connect` was called with a valid VM Service URI before using other tools.

### Finding the URI

The URI is printed when the app starts in debug mode. Look for:
```
The Flutter DevTools debugger and profiler on... is available at: http://...
```

Use the WebSocket URL (ws://.../ws) for connection.

### Release Mode Not Supported

Marionette requires debug or profile mode. It will not function in release builds.

### Elements Not Found

1. Confirm widget is visible on screen
2. Register custom widgets via `MarionetteConfiguration`
3. Try `scroll_to` if element might be off-screen
4. Use `get_interactive_elements` to see what's available

## Requirements

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Claude Code with MCP support
- Flutter app must run in debug mode

## See Also

- [Marionette Flutter Package](https://pub.dev/packages/marionette_flutter)
- [Marionette MCP Server](https://github.com/leancodepl/marionette_mcp)
- [Marionette CLI](https://pub.dev/packages/marionette_cli)