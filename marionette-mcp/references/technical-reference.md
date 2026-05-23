# Marionette MCP Plugin - Technical Reference

## MCP Server Configuration

The `.mcp.json` file configures the Marionette MCP server for Claude Code:

```json
{
  "marionette": {
    "command": "dart",
    "args": ["run", "marionette_mcp"],
    "env": {
      "LOG_LEVEL": "${LOG_LEVEL:-info}"
    }
  }
}
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LOG_LEVEL` | `info` | Logging verbosity (debug, info, warn, error) |

## Tool Naming Convention

MCP tools follow this naming pattern:

```
mcp__plugin_marionette_mcp__marionette_<tool-name>
```

| Tool | Full Name |
|------|-----------|
| connect | `mcp__plugin_marionette_mcp__marionette_connect` |
| disconnect | `mcp__plugin_marionette_mcp__marionette_disconnect` |
| get_interactive_elements | `mcp__plugin_marionette_mcp__marionette_get_interactive_elements` |
| tap | `mcp__plugin_marionette_mcp__marionette_tap` |
| enter_text | `mcp__plugin_marionette_mcp__marionette_enter_text` |
| scroll_to | `mcp__plugin_marionette_mcp__marionette_scroll_to` |
| get_logs | `mcp__plugin_marionette_mcp__marionette_get_logs` |
| take_screenshots | `mcp__plugin_marionette_mcp__marionette_take_screenshots` |
| hot_reload | `mcp__plugin_marionette_mcp__marionette_hot_reload` |

## Tool Parameters

### connect
```json
{
  "uri": "ws://127.0.0.1:54321/ws"
}
```

### tap
```json
{
  "key": "submit_button",      // optional: match by widget key
  "text": "Submit",            // optional: match by visible text
  "index": 0                   // optional: if multiple matches
}
```

### enter_text
```json
{
  "key": "email_field",        // required: widget key to match
  "text": "user@example.com",   // required: text to enter
  "submit": false              // optional: submit after entering
}
```

### scroll_to
```json
{
  "key": "my_element",         // optional: match by key
  "text": "Submit Button",     // optional: match by text
  "scrollDirection": "down"    // optional: up, down, left, right
}
```

### get_logs
```json
{
  "since": "hotReload"         // optional: "startup" or "hotReload"
}
```

## MarionetteConfiguration Reference

```dart
MarionetteConfiguration({
  // Function to identify custom interactive widgets
  // Returns true if the widget type should be treated as interactive
  bool Function(Type)? isInteractiveWidget,

  // Function to extract text from custom widgets
  // Return null if no text can be extracted
  String? Function(Element)? extractText,

  // Log collector for get_logs functionality
  LogCollector? logCollector,

  // Maximum screenshot dimensions (default: 2000x2000)
  // Set to null to disable downscaling
  Size? maxScreenshotSize,
})
```

### Log Collectors

```dart
// Dart logging package
logCollector: LoggingLogCollector()

// Dart logger package
logCollector: LoggerLogCollector()

// Print statements
logCollector: PrintLogCollector()
```

## CLI Alternative

For environments without MCP support, use the Marionette CLI:

```bash
# Install
dart pub global activate marionette_cli

# Direct mode (stateless)
marionette --uri ws://127.0.0.1:8181/ws get-interactive-elements
marionette --uri ws://127.0.0.1:8181/ws tap --key submit_button

# Named instances (stateful)
marionette register my-app ws://127.0.0.1:8181/ws
marionette -i my-app tap --text "Submit"
marionette list
marionette doctor
```

## Platform Support

| Platform | Debug Mode | Profile Mode | Release Mode |
|----------|-----------|--------------|--------------|
| Chrome (Web) | ✅ | ✅ | ❌ |
| Windows | ✅ | ✅ | ❌ |
| macOS | ✅ | ✅ | ❌ |
| Linux | ✅ | ✅ | ❌ |
| Android | ✅ | ✅ | ❌ |
| iOS | ✅ | ✅ | ❌ |

## Known Limitations

1. **Debug/Profile only** - Marionette requires VM Service, not available in release
2. **Visible elements** - Elements must be on screen or scrollable into view
3. **Custom widgets** - May need explicit registration in `MarionetteConfiguration`
4. **Network** - Flutter app and Claude Code should be on same network for Android/iOS
5. **Port forwarding** - For mobile devices, may need port forwarding for remote debugging

## Source

- [Marionette MCP GitHub](https://github.com/leancodepl/marionette_mcp)
- [Marionette Flutter Package](https://pub.dev/packages/marionette_flutter)
- [Marionette CLI](https://pub.dev/packages/marionette_cli)