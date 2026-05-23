---
name: Marionette MCP Usage
description: When debugging Flutter apps, testing UI interactions, inspecting widgets, taking screenshots of Flutter screens, entering text into form fields, scrolling views, or verifying Flutter app behavior. Triggers include phrases like "debug Flutter app", "test Flutter UI", "tap button in Flutter", "Flutter screenshot", "Flutter app not responding", "inspect Flutter widgets", "run Flutter smoke test", "verify Flutter feature", "hot reload Flutter".
version: 1.0.0
---

# Marionette MCP Usage Guide

Marionette MCP enables AI agents to interact with running Flutter applications through the Model Context Protocol. It provides tools for widget inspection, tap simulation, text entry, scrolling, screenshots, and hot reload.

## Prerequisites

Before using Marionette, ensure:

1. **Flutter app has MarionetteBinding initialized:**
   ```dart
   import 'package:marionette_flutter/marionette_flutter.dart';

   void main() {
     MarionetteBinding.ensureInitialized();
     runApp(const MyApp());
   }
   ```

2. **Marionette MCP server is installed:**
   ```bash
   dart pub global activate marionette_mcp
   ```

3. **App runs in debug mode:**
   ```bash
   flutter run -d chrome  # or -d android, -d ios, etc.
   ```

4. **VM Service URI is available** - shown in console as `The Flutter DevTools debugger and profiler on... is available at: ws://...`

## Available MCP Tools

### connect

Connect to a running Flutter app via VM Service URI.

**Parameters:**
- `uri` (required): WebSocket URI like `ws://127.0.0.1:54321/ws`

**Usage:**
```
Use connect with uri="ws://127.0.0.1:54321/ws"
```

### disconnect

End the current Marionette connection.

**Usage:**
```
Use disconnect to end the connection
```

### get_interactive_elements

Retrieve all interactive UI elements visible on screen.

**Parameters:**
- `depth` (optional): Tree depth for element traversal (default: 3)

**Usage:**
```
Use get_interactive_elements to see all tappable elements
```

### tap

Simulate a tap gesture on an element.

**Parameters:**
- `key` (optional): Widget key to match
- `text` (optional): Visible text to match
- `index` (optional): Index if multiple matches

**Usage:**
```
Use tap with key="submit_button"
Use tap with text="Submit"
```

### enter_text

Input text into a text field.

**Parameters:**
- `key` (required): Widget key to match
- `text` (required): Text to enter
- `submit` (optional): Whether to submit after (default: false)

**Usage:**
```
Use enter_text with key="email_field" and text="user@example.com"
```

### scroll_to

Scroll until an element becomes visible.

**Parameters:**
- `key` (optional): Widget key to match
- `text` (optional): Visible text to match
- `scrollDirection` (optional): "up", "down", "left", "right"

**Usage:**
```
Use scroll_to with text="Submit Button"
```

### get_logs

Retrieve application logs.

**Parameters:**
- `since` (optional): "startup" or "hotReload" (default: "hotReload")

**Usage:**
```
Use get_logs to see recent logs
```

### take_screenshots

Capture current screen as base64 image.

**Parameters:**
- None

**Usage:**
```
Use take_screenshots to capture the current screen
```

### hot_reload

Hot reload the Flutter app without losing state.

**Parameters:**
- None

**Usage:**
```
Use hot_reload after code changes
```

## Workflows

### Workflow 1: Debug Unresponsive Button

1. Connect to app: `connect` with VM URI
2. Find button: `get_interactive_elements`
3. Tap button: `tap` with key or text
4. Check logs: `get_logs` for errors
5. Take screenshot: `take_screenshots` to verify state

### Workflow 2: Form Testing

1. Connect: `connect` with VM URI
2. Enter text: `enter_text` for each field
3. Scroll if needed: `scroll_to` to find submit
4. Tap submit: `tap` with text
5. Verify: `get_logs` and `take_screenshots`

### Workflow 3: Smoke Testing After Refactor

1. Connect: `connect` with VM URI
2. Navigate tabs: Use `get_interactive_elements` then `tap`
3. Check for crashes: `get_logs`
4. Hot reload: `hot_reload` after code changes
5. Repeat verification

## Custom Widget Configuration

For custom widgets, configure `MarionetteConfiguration`:

```dart
MarionetteBinding.ensureInitialized(
  MarionetteConfiguration(
    isInteractiveWidget: (type) => type == MyCustomButton,
    extractText: (element) => element.text,
    logCollector: LoggingLogCollector(),
    maxScreenshotSize: Size(2000, 2000),
  ),
);
```

## Troubleshooting

### "Not connected to any app"

Ensure `connect` was called with a valid VM Service URI before using other tools.

### Finding the VM URI

Look for this line in console output:
```
The Flutter DevTools debugger and profiler on... is available at: http://...
```

Use the WebSocket URL (ws://.../ws) for connection.

### Release Mode Not Supported

Marionette requires debug or profile mode. It will not function in release builds.

### Elements Not Found

1. Confirm widget is visible on screen
2. Check if widget needs registration via `isInteractiveWidget`
3. Try using `get_interactive_elements` first to see available elements
4. Use `scroll_to` if element is off-screen

## Best Practices

1. **Always connect first** - Most tools require active connection
2. **Check interactive elements** - Use `get_interactive_elements` before tapping
3. **Verify with screenshots** - Take screenshots to confirm UI state
4. **Check logs after actions** - `get_logs` helps diagnose issues
5. **Use hot reload for changes** - Preserve app state during debugging
6. **Be specific with selectors** - Use unique keys/text when possible