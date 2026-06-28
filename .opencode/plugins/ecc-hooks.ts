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

import type { Plugin } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import {
  initStore,
  recordChange,
  clearChanges,
} from "./lib/changed-files-store.js"
import changedFilesTool from "../tools/changed-files.js"

/**
 * Type definitions for better type safety
 */
interface ToolArgs {
  filePath?: string
  file_path?: string
  path?: string
  command?: string
  [key: string]: unknown
}

/**
 * Read ECC version from package.json
 * Falls back to a default if package.json cannot be read
 */
function getECCVersion(): string {
  try {
    const packageJsonPath = path.resolve(__dirname, "../package.json")
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8"))
    return packageJson.version || "2.0.0"
  } catch {
    return "2.0.0"
  }
}

export const ECCHooksPlugin: Plugin = async ({
  client,
  $,
  directory,
  worktree,
}) => {
  type HookProfile = "minimal" | "standard" | "strict"

  const worktreePath = worktree || directory
  initStore(worktreePath)

  const editedFiles = new Set<string>()

  function resolvePath(p: string): string {
    if (path.isAbsolute(p)) return p
    return path.join(worktreePath, p)
  }

  function hasProjectFile(relativePath: string): boolean {
    try {
      return fs.statSync(resolvePath(relativePath)).isFile()
    } catch {
      return false
    }
  }

  function readFileContent(filePath: string): string | null {
    try {
      const abs = resolvePath(filePath)
      return fs.readFileSync(abs, "utf-8")
    } catch {
      return null
    }
  }

  const pendingToolChanges = new Map<string, { path: string; type: "added" | "modified" }>()
  let writeCounter = 0

  function getFilePath(args: ToolArgs | undefined | null): string | null {
    if (!args) return null
    const p = (args.filePath ?? args.file_path ?? args.path) as string | undefined
    return typeof p === "string" && p.trim() ? p : null
  }

  // Helper to call the SDK's log API with correct signature
  const log = (level: "debug" | "info" | "warn" | "error", message: string) =>
    client.app.log({ body: { service: "ecc", level, message } })

  const normalizeProfile = (value: string | undefined): HookProfile => {
    if (value === "minimal" || value === "strict") return value
    return "standard"
  }

  const currentProfile = normalizeProfile(process.env.ECC_HOOK_PROFILE)
  const disabledHooks = new Set(
    (process.env.ECC_DISABLED_HOOKS || "")
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean)
  )

  const profileOrder: Record<HookProfile, number> = {
    minimal: 0,
    standard: 1,
    strict: 2,
  }

  const profileAllowed = (required: HookProfile | HookProfile[]): boolean => {
    if (Array.isArray(required)) {
      return required.some((entry) => profileOrder[currentProfile] >= profileOrder[entry])
    }
    return profileOrder[currentProfile] >= profileOrder[required]
  }

  const hookEnabled = (
    hookId: string,
    requiredProfile: HookProfile | HookProfile[] = "standard"
  ): boolean => {
    if (disabledHooks.has(hookId)) return false
    return profileAllowed(requiredProfile)
  }

  return {
    /**
     * Pre-Tool Security Check
     * Equivalent to Claude Code PreToolUse hook
     *
     * Triggers: Before tool execution
     * Action: Warns about potential security issues
     */
    "tool.execute.before": async (
      input: { tool: string; sessionID: string; callID: string },
      output: { args: Record<string, unknown> }
    ) => {
      const args = output.args as ToolArgs

      if (input.tool === "write") {
        const filePath = getFilePath(args)
        if (filePath) {
          const absPath = resolvePath(filePath)
          let type: "added" | "modified" = "modified"
          try {
            if (typeof fs.existsSync === "function") {
              type = fs.existsSync(absPath) ? "modified" : "added"
            }
          } catch {
            type = "modified"
          }
          const key = input.callID ?? `write-${++writeCounter}-${filePath}`
          pendingToolChanges.set(key, { path: filePath, type })
        }
      }

      // Git push review reminder
      if (
        hookEnabled("pre:bash:git-push-reminder", "strict") &&
        input.tool === "bash"
      ) {
        const cmd = String(args?.command || args || "")
        if (cmd.includes("git push")) {
          log(
            "info",
            "[ECC] Remember to review changes before pushing: git diff origin/main...HEAD"
          )
        }
      }

      // Block creation of unnecessary documentation files
      if (
        hookEnabled("pre:write:doc-file-warning", ["standard", "strict"]) &&
        input.tool === "write" &&
        args?.filePath &&
        typeof args.filePath === "string"
      ) {
        const filePath = args.filePath
        if (
          filePath.match(/\.(md|txt)$/i) &&
          !filePath.includes("README") &&
          !filePath.includes("CHANGELOG") &&
          !filePath.includes("LICENSE") &&
          !filePath.includes("CONTRIBUTING")
        ) {
          log(
            "warn",
            `[ECC] Creating ${filePath} - consider if this documentation is necessary`
          )
        }
      }

      // Long-running command reminder
      if (hookEnabled("pre:bash:tmux-reminder", "strict") && input.tool === "bash") {
        const cmd = String(args?.command || args || "")
        if (
          cmd.match(/^(npm|pnpm|yarn|bun)\s+(install|build|test|run)/) ||
          cmd.match(/^cargo\s+(build|test|run)/) ||
          cmd.match(/^go\s+(build|test|run)/)
        ) {
          log(
            "info",
            "[ECC] Long-running command detected - consider using background execution"
          )
        }
      }
    },

    /**
     * TypeScript Check Hook
     * Equivalent to Claude Code PostToolUse hook for tsc
     *
     * Triggers: After edit tool completes on .ts/.tsx files
     * Action: Runs tsc --noEmit to check for type errors
     */
    "tool.execute.after": async (
      input: { tool: string; sessionID: string; callID: string; args: ToolArgs },
      _output: { title: string; output: string; metadata: unknown }
    ) => {
      const filePath = getFilePath(input.args)
      if (input.tool === "edit" && filePath) {
        editedFiles.add(filePath)
        recordChange(filePath, "modified")
      }
      if (input.tool === "write" && filePath) {
        editedFiles.add(filePath)
        const key = input.callID ?? `write-${++writeCounter}-${filePath}`
        const pending = pendingToolChanges.get(key)
        if (pending) {
          recordChange(pending.path, pending.type)
          pendingToolChanges.delete(key)
        } else {
          recordChange(filePath, "modified")
        }
      }

      // Auto-format JS/TS files (Prettier)
      if (
        hookEnabled("post:edit:format", ["strict"]) &&
        (input.tool === "edit" || input.tool === "write") &&
        filePath &&
        filePath.match(/\.(ts|tsx|js|jsx)$/)
      ) {
        try {
          await $`prettier --write ${filePath}`.nothrow()
          log("info", `[ECC] Formatted: ${filePath}`)
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : String(error)
          log("debug", `[ECC] Prettier formatting failed for ${filePath}: ${errorMessage}`)
        }
      }

      // Console.log warning check
      if (
        hookEnabled("post:edit:console-warn", ["standard", "strict"]) &&
        (input.tool === "edit" || input.tool === "write") &&
        filePath &&
        filePath.match(/\.(ts|tsx|js|jsx)$/)
      ) {
        const content = readFileContent(filePath)
        if (content) {
          const matches = content.match(/console\.log/g)
          if (matches && matches.length > 0) {
            log(
              "warn",
              `[ECC] console.log found in ${filePath} (${matches.length} occurrence${matches.length > 1 ? "s" : ""})`
            )
          }
        }
      }

      // Check if a TypeScript file was edited
      if (
        hookEnabled("post:edit:typecheck", ["strict"]) &&
        input.tool === "edit" &&
        input.args?.filePath?.match(/\.tsx?$/)
      ) {
        try {
          await $`npx tsc --noEmit`
          log("info", "[ECC] TypeScript check passed")
        } catch (error: unknown) {
          const err = error as { stdout?: Buffer }
          log("warn", "[ECC] TypeScript errors detected:")
          if (err.stdout) {
            const text = err.stdout.toString()
            const errors = text.split("\n").slice(0, 5)
            errors.forEach((line: string) => log("warn", `  ${line}`))
          }
        }
      }

      // PR creation logging
      if (
        hookEnabled("post:bash:pr-created", ["standard", "strict"]) &&
        input.tool === "bash"
      ) {
        const cmd = String(input.args?.command || input.args || "")
        if (cmd.includes("gh pr create")) {
          log("info", "[ECC] PR created - check GitHub Actions status")
        }
      }
    },

    /**
     * Event Handler Hook
     * Handles session/file/todo events that are NOT available as direct hooks
     * in @opencode-ai/plugin v1.16.0+.
     *
     * Events handled:
     * - session.created → SessionStart
     * - session.idle → Stop (console.log audit)
     * - session.deleted → SessionEnd
     * - file.edited → file tracking
     * - file.watcher.updated → file system tracking
     * - todo.updated → progress logging
     */
    event: async ({ event }: { event: { type: string; properties: Record<string, unknown> } }) => {
      switch (event.type) {
        /**
         * Session Created Hook
         * Equivalent to Claude Code SessionStart hook
         */
        case "session.created": {
          if (!hookEnabled("session:start", ["minimal", "standard", "strict"])) return

          log("info", `[ECC] Session started - profile=${currentProfile}`)

          if (hasProjectFile("CLAUDE.md")) {
            log("info", "[ECC] Found CLAUDE.md - loading project context")
          }
          break
        }

        /**
         * Session Idle Hook
         * Equivalent to Claude Code Stop hook
         *
         * Action: Runs console.log audit on all edited files
         */
        case "session.idle": {
          if (!hookEnabled("stop:check-console-log", ["minimal", "standard", "strict"])) return
          if (editedFiles.size === 0) return

          log("info", "[ECC] Session idle - running console.log audit")

          let totalConsoleLogCount = 0
          const filesWithConsoleLogs: string[] = []

          for (const file of editedFiles) {
            if (!file.match(/\.(ts|tsx|js|jsx)$/)) continue

            const content = readFileContent(file)
            if (content) {
              const matches = content.match(/console\.log/g)
              if (matches && matches.length > 0) {
                totalConsoleLogCount += matches.length
                filesWithConsoleLogs.push(file)
              }
            }
          }

          if (totalConsoleLogCount > 0) {
            log(
              "warn",
              `[ECC] Audit: ${totalConsoleLogCount} console.log statement(s) in ${filesWithConsoleLogs.length} file(s)`
            )
            filesWithConsoleLogs.forEach((f) =>
              log("warn", `  - ${f}`)
            )
            log("warn", "[ECC] Remove console.log statements before committing")
          } else {
            log("info", "[ECC] Audit passed: No console.log statements found")
          }

          // Desktop notification (cross-platform)
          try {
            if (process.platform === "darwin") {
              await $`osascript -e 'display notification "Task completed!" with title "OpenCode ECC"'`.nothrow()
            } else if (process.platform === "win32") {
              await $`powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Task completed!', 'OpenCode ECC', 'OK', 'Information')"`.nothrow()
            } else if (process.platform === "linux") {
              await $`notify-send "OpenCode ECC" "Task completed!"`.nothrow()
            }
          } catch (error: unknown) {
            const errorMessage = error instanceof Error ? error.message : String(error)
            log("debug", `[ECC] Desktop notification failed: ${errorMessage}`)
          }

          // Clear tracked files for next task
          editedFiles.clear()
          break
        }

        /**
         * Session Deleted Hook
         * Equivalent to Claude Code SessionEnd hook
         */
        case "session.deleted": {
          if (!hookEnabled("session:end-marker", ["minimal", "standard", "strict"])) return
          log("info", "[ECC] Session ended - cleaning up")
          editedFiles.clear()
          clearChanges()
          pendingToolChanges.clear()
          break
        }

        /**
         * File Edited Hook
         * Equivalent to Claude Code PostToolUse hook for file tracking
         */
        case "file.edited": {
          const file = event.properties.file as string | undefined
          if (file) {
            editedFiles.add(file)
            recordChange(file, "modified")
          }
          break
        }

        /**
         * File Watcher Hook
         * OpenCode-only feature
         */
        case "file.watcher.updated": {
          const file = event.properties.file as string | undefined
          const changeEvent = event.properties.event as string | undefined
          if (file) {
            let changeType: "added" | "modified" | "deleted" = "modified"
            if (changeEvent === "add") changeType = "added"
            else if (changeEvent === "unlink") changeType = "deleted"
            recordChange(file, changeType)
            if (changeEvent === "change" && file.match(/\.(ts|tsx|js|jsx)$/)) {
              editedFiles.add(file)
            }
          }
          break
        }

        /**
         * Todo Updated Hook
         * OpenCode-only feature
         */
        case "todo.updated": {
          const todos = event.properties.todos as Array<{ status: string; content: string }> | undefined
          if (todos && todos.length > 0) {
            const completed = todos.filter((t) => t.status === "completed").length
            log("info", `[ECC] Progress: ${completed}/${todos.length} tasks completed`)
          }
          break
        }
      }
    },

    /**
     * Shell Environment Hook
     * OpenCode-specific: Inject environment variables into shell commands
     *
     * Triggers: Before shell command execution
     * Action: Sets PROJECT_ROOT, PACKAGE_MANAGER, DETECTED_LANGUAGES, ECC_VERSION
     */
    "shell.env": async (
      _input: { cwd: string; sessionID?: string; callID?: string },
      output: { env: Record<string, string> }
    ) => {
      output.env.ECC_VERSION = getECCVersion()
      output.env.ECC_PLUGIN = "true"
      output.env.ECC_HOOK_PROFILE = currentProfile
      output.env.ECC_DISABLED_HOOKS = process.env.ECC_DISABLED_HOOKS || ""
      output.env.PROJECT_ROOT = worktreePath

      // Detect package manager
      const lockfiles: Record<string, string> = {
        "bun.lockb": "bun",
        "pnpm-lock.yaml": "pnpm",
        "yarn.lock": "yarn",
        "package-lock.json": "npm",
      }
      for (const [lockfile, pm] of Object.entries(lockfiles)) {
        if (hasProjectFile(lockfile)) {
          output.env.PACKAGE_MANAGER = pm
          break
        }
      }

      // Detect languages
      const langDetectors: Record<string, string> = {
        "tsconfig.json": "typescript",
        "go.mod": "go",
        "pyproject.toml": "python",
        "Cargo.toml": "rust",
        "Package.swift": "swift",
      }
      const detected: string[] = []
      for (const [file, lang] of Object.entries(langDetectors)) {
        if (hasProjectFile(file)) {
          detected.push(lang)
        }
      }
      if (detected.length > 0) {
        output.env.DETECTED_LANGUAGES = detected.join(",")
        output.env.PRIMARY_LANGUAGE = detected[0]
      }
    },

    /**
     * Session Compacting Hook
     * OpenCode-specific: Control context compaction behavior
     *
     * Triggers: Before context compaction
     * Action: Push ECC context block and custom compaction prompt
     */
    "experimental.session.compacting": async (
      _input: { sessionID: string },
      output: { context: string[]; prompt?: string }
    ) => {
      output.context.push("# ECC Context (preserve across compaction)")
      output.context.push("")
      output.context.push("## Active Plugin: ECC v2.0.0")
      output.context.push("- Hooks: tool.execute.before/after, event, shell.env, compacting, permission.ask")
      output.context.push("- Tools: run-tests, check-coverage, security-audit, format-code, lint-check, git-summary, changed-files")
      output.context.push("- Agents: 13 specialized (planner, architect, tdd-guide, code-reviewer, security-reviewer, build-error-resolver, e2e-runner, refactor-cleaner, doc-updater, go-reviewer, go-build-resolver, database-reviewer, python-reviewer)")
      output.context.push("")
      output.context.push("## Key Principles")
      output.context.push("- TDD: write tests first, 80%+ coverage")
      output.context.push("- Immutability: never mutate, always return new copies")
      output.context.push("- Security: validate inputs, no hardcoded secrets")
      output.context.push("")

      // Include recently edited files
      if (editedFiles.size > 0) {
        output.context.push("## Recently Edited Files")
        for (const f of editedFiles) {
          output.context.push(`- ${f}`)
        }
        output.context.push("")
      }

      output.prompt =
        "Focus on preserving: 1) Current task status and progress, 2) Key decisions made, 3) Files created/modified, 4) Remaining work items, 5) Any security concerns flagged. Discard: verbose tool outputs, intermediate exploration, redundant file listings."
    },

    /**
     * Permission Auto-Approve Hook
     * OpenCode-specific: Auto-approve safe operations
     *
     * Triggers: When permission is requested
     * Action: Auto-approve reads, formatters, and test commands; log all for audit
     */
    "permission.ask": async (
      input: { id: string; type: string; pattern?: string | Array<string>; title: string; metadata: Record<string, unknown> },
      output: { status: "ask" | "deny" | "allow" }
    ) => {
      log("info", `[ECC] Permission requested for: ${input.type}`)

      try {
        const pattern = typeof input.pattern === "string" ? input.pattern : ""

        // Auto-approve: read/search tools
        if (["read", "glob", "grep", "search", "list"].includes(input.type)) {
          log("debug", `[ECC] Auto-approved read-only tool: ${input.type}`)
          output.status = "allow"
          return
        }

        // Auto-approve: formatters
        if (input.type === "bash" && /^(npx )?(@biomejs\/biome|prettier|black|gofmt|rustfmt|swift-format)/.test(pattern)) {
          log("debug", `[ECC] Auto-approved formatter: ${pattern}`)
          output.status = "allow"
          return
        }

        // Auto-approve: test execution
        if (input.type === "bash" && /^(npm test|npx vitest|npx jest|pytest|go test|cargo test)/.test(pattern)) {
          log("debug", `[ECC] Auto-approved test execution: ${pattern}`)
          output.status = "allow"
          return
        }

        // Everything else: let user decide
        log("debug", `[ECC] Permission requires user approval: ${input.type}`)
        output.status = "ask"
      } catch (error: unknown) {
        const errorMessage = error instanceof Error ? error.message : String(error)
        log("error", `[ECC] Permission handling error for ${input.type}: ${errorMessage}`)
        output.status = "deny"
      }
    },

    tool: {
      "changed-files": changedFilesTool,
    },
  }
}

export default ECCHooksPlugin
