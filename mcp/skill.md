# Flutter Feature Generator — MCP Server

MCP server that lets an AI IDE scaffold Flutter Clean-Architecture features.
Speaks JSON-RPC 2.0 over stdin/stdout. Pure Dart, zero runtime dependencies.

## Why this server is shaped the way it is

This generator is unusually well-suited to AI agents:

- **Declarative inputs** — name + preset + flag overrides; nothing prosey.
- **Idempotent** — re-running on an existing feature is a no-op by default.
- **Schema-driven** — `get_schema` and `get_presets` return structured JSON
  so the agent never has to hallucinate flag names.
- **Dry-run capable** — every generation can be previewed without writing.
- **Closed-loop** — `validate` runs `flutter analyze` (and optionally
  `flutter test`) so the agent can verify its own work without leaving the
  tool surface.
- **Path-safe** — the optional `ALLOWED_ROOT` env confines `output_dir` so
  this remote-write capability cannot escape into the rest of the FS.

## Tools

### `get_schema`

Return the canonical feature-flag schema as structured JSON. Call this
before composing flags so you never invent a flag that doesn't exist.

**Input:** none.
**Returns:** `{ flags: [{name, default, description}], conflicts: [...] }`

### `get_presets`

Return the available presets and the flags each one sets, as structured JSON.

**Input:** none.
**Returns:** `{ presets: { simple: {features: {...}}, standard: {...}, enterprise: {...} } }`

### `get_manifest`

Return the template manifest — which templates write to which paths,
and under which flag-gates.

**Input:** none.
**Returns:** `{ core: [...], feature: [...] }`. Each entry has `template`,
`output`, optional `when` / `once` / `preserve`.

### `list_features`

List the features already scaffolded in a project (read-only).

**Input:** `{ output_dir?: string }`.
**Returns:** `{ project_root, features: [{id, module_path, module_exists, registered}], count }`

### `dry_run` *(folded into `generate_feature`)*

Pass `dry_run: true` to `generate_feature` to preview without writing.

### `generate_feature`

Scaffold a Flutter CRUD feature. Side effects: creates files under
`lib/features/<name>/` and `test/features/<name>/`, may modify
`lib/core/routing/feature_registry.dart`.

**Input:**
| Field         | Type                       | Notes |
|---------------|----------------------------|-------|
| `module_name` | string (required)          | Any case shape — `User`, `userProfile`, `user_profile` all normalise. |
| `preset`      | enum: simple/standard/enterprise | Default `standard`. |
| `features`    | object<string, bool>       | Per-flag overrides on top of the preset. |
| `overwrite`   | bool                       | Default false. Destructive — clobbers hand-edits. `feature_registry.dart` is preserved regardless. |
| `dry_run`     | bool                       | Default false. Preview only. |
| `output_dir`  | string                     | Override `PROJECT_ROOT`. Validated: exists, is directory, contains `pubspec.yaml`, and (if `ALLOWED_ROOT` is set) resides under it. |

**Returns:**
```json
{
  "module": "User",
  "preset": "standard",
  "dry_run": false,
  "project_root": "/path/to/project",
  "created":     ["lib/features/user/...", ...],
  "overwritten": [],
  "skipped":     ["lib/core/errors/failures.dart", ...],
  "summary":     {"created": 14, "overwritten": 0, "skipped": 10}
}
```

**Failures** bubble up as MCP protocol errors (code `-32000`) with a
human-readable message. The agent should treat any non-200 protocol
response as a tool failure, not parse `success: false` from a content body.

### `validate`

Run `flutter analyze` and optionally `flutter test` against the project,
return a structured report.

**Input:** `{ output_dir?: string, run_tests?: bool }`.
**Returns:** `{ project_root, analyze: {exit_code, passed, stdout, stderr}, test?: {...}, passed: bool }`.

## The recommended agent loop

```
get_schema   → understand what flags exist
get_presets  → pick a starting bundle
list_features → avoid duplicates
generate_feature dry_run=true   → preview
generate_feature dry_run=false  → write
validate                         → confirm flutter analyze (+ test) passes
```

If `validate` fails, the agent inspects the structured `analyze.stderr`,
adjusts flags, and re-runs `generate_feature` with `overwrite=true`.

## Configuration

Environment variables (all optional, all overridable per call where it
makes sense):

| Var | Default | What it does |
|---|---|---|
| `PROJECT_ROOT` | parent dir | Default project to scaffold into when `output_dir` is omitted. |
| `TEMPLATES_DIR` | `<PROJECT_ROOT>/templates` | Where the templates live. |
| `PACKAGE_NAME` | `flutter_project` | Used by the registry import paths. |
| `ALLOWED_ROOT` | *(unset)* | If set, every `output_dir` must reside under this path. **Recommended in shared / multi-project setups.** |

CLI flags `--project-root`, `--templates-dir`, `--package-name`
mirror the env vars.

## Wiring it into an AI IDE

```jsonc
{
  "mcpServers": {
    "flutter-generator": {
      "command": "dart",
      "args": ["run", "/abs/path/to/flutter_project/mcp/bin/main.dart"],
      "env": {
        "PROJECT_ROOT": "/abs/path/to/flutter_project",
        "ALLOWED_ROOT": "/abs/path/to/code"
      }
    }
  }
}
```

## Architecture

```
mcp/
├── bin/main.dart              # CLI entry: env+args -> server.start()
├── lib/
│   ├── server.dart            # JSON-RPC dispatcher, tool registry
│   ├── base/
│   │   ├── tool.dart          # MCPTool interface + ToolFailure exception
│   │   ├── path_safety.dart   # output_dir validator (exists, pubspec, ALLOWED_ROOT)
│   │   └── yaml_parser.dart   # minimal YAML reader for schema/manifest/presets
│   └── tools/
│       ├── schema_tool.dart       # get_schema       (structured JSON)
│       ├── presets_tool.dart      # get_presets      (structured JSON)
│       ├── manifest_tool.dart     # get_manifest     (structured JSON)
│       ├── list_features_tool.dart # list_features
│       ├── validate_tool.dart     # validate (flutter analyze [+ test])
│       └── generator_tool.dart    # generate_feature (shells to tool/bin/generate.dart --json)
└── pubspec.yaml               # zero runtime deps
```

The wrapper invokes the underlying CLI generator with `--json`, so it
never depends on the CLI's human-readable output format. Generator
failures parse from JSON; protocol errors propagate as MCP errors.
