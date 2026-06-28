/**
 * ECC Plugin Hooks for OpenCode
 *
 * This plugin translates Claude Code hooks to OpenCode's plugin system.
 * OpenCode's plugin system is MORE sophisticated than Claude Code with 20+ events
 * compared to Claude Code's 3 phases (PreToolUse, PostToolUse, Stop).
 *
 * Hook Event Mapping:
 * - PreToolUse → tool.execute.before
 * - PostToolUse → tool.execute.after
 * - Stop → session.idle (via event hook)
 * - SessionStart → session.created (via event hook)
 * - SessionEnd → session.deleted (via event hook)
 * - FileEdit → file.edited (via event hook)
 * - FileWatcher → file.watcher.updated (via event hook)
 * - TodoUpdated → todo.updated (via event hook)
 *
 * NOTE: In @opencode-ai/plugin v1.16.0+, session/file/todo events are delivered
 * through the `event` hook, not as direct hook properties. Direct hooks like
 * "file.edited", "session.created" etc. are NOT in the Hooks interface and
 * would be silently ignored.
 */
import type { Plugin } from "@opencode-ai/plugin";
export declare const ECCHooksPlugin: Plugin;
export default ECCHooksPlugin;
//# sourceMappingURL=ecc-hooks.d.ts.map