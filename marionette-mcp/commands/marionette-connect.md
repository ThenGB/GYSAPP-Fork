---
name: marionette-connect
description: Connect to a running Flutter app via Marionette MCP. Use this command to establish connection before other Flutter debugging operations.
argument-hint: <vm-service-uri>
allowed-tools: ["mcp__plugin_marionette_mcp__marionette_connect"]
---

# Marionette Connect Command

Connect to a running Flutter application using its VM Service URI.

## Usage

```
/marionette-connect <vm-service-uri>
```

**Example:**
```
/marionette-connect ws://127.0.0.1:54321/ws
```

## Finding the VM Service URI

1. Run your Flutter app in debug mode:
   ```bash
   flutter run -d chrome
   ```

2. Look in the console output for:
   ```
   The Flutter DevTools debugger and profiler on... is available at: http://...
   ```

3. Copy the WebSocket URL (ws://.../ws) - it ends with `/ws`

## Connection Workflow

After connecting, you can:

1. **Inspect elements:** Use `get_interactive_elements` to see all tappable widgets
2. **Interact:** Use `tap`, `enter_text`, `scroll_to` for UI testing
3. **Debug:** Use `get_logs` to diagnose issues
4. **Verify:** Use `take_screenshots` to confirm UI state
5. **Reload:** Use `hot_reload` after code changes

## Prerequisites

Before connecting, ensure your Flutter app has:

1. **marionette_flutter package:**
   ```bash
   dart pub add marionette_flutter
   ```

2. **MarionetteBinding initialized in main.dart:**
   ```dart
   import 'package:marionette_flutter/marionette_flutter.dart';

   void main() {
     MarionetteBinding.ensureInitialized();
     runApp(const MyApp());
   }
   ```

3. **marionette_mcp server installed:**
   ```bash
   dart pub global activate marionette_mcp
   ```

## Disconnecting

When finished, disconnect using:
```
Use disconnect to end the Marionette connection
```

## Troubleshooting

- **"Not connected to any app"** - Ensure this command was run first
- **URI not found** - App must be running in debug mode
- **Connection refused** - Check if app is still running and debug port is correct

## Notes

- Marionette only works in debug/profile mode, not release
- Connection persists until explicitly disconnected or app closes
- Multiple Flutter apps require separate connections