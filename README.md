# Flutter Feature Generator

An opinionated code generator that scaffolds production-shape Flutter
features (Clean Architecture + Riverpod + tests) and wires them into the
app shell automatically. Generated code passes `flutter analyze` and
`flutter test` from the moment it lands.

The engine is framework-agnostic — retargeting to React, a server, or any
other text-templated codebase is a templates-directory swap, not a
rewrite. See [`ROADMAP.md`](ROADMAP.md).

## Repo layout

This is a Dart workspace with three packages, each with a clear job:

```
packages/
├── generator/        — the product: engine + CLI + templates (pure Dart, no Flutter)
├── generator_mcp/    — MCP server wrapping the generator for AI IDEs
└── example_app/      — the Flutter playground that consumes generated code
```

Top-level `pubspec.yaml` declares the workspace; one `dart pub get` at
root resolves all three packages.

## Quick start

```bash
# from the workspace root
dart pub get

# scaffold a feature into the example app
dart run packages/generator/bin/generate.dart Invoice --out packages/example_app

# run it
cd packages/example_app
flutter pub get
flutter analyze && flutter test
flutter run
```

`--core-only` bootstraps shared infra into a fresh project before the
first feature; subsequent generations skip core idempotently.

## What a generated feature looks like

```
lib/features/<name>/
├── domain/                   # entities + repository contract + use cases
├── data/                     # model + fake repo + impl stub
├── presentation/             # Riverpod providers + pages + widgets
│   ├── providers/<name>_providers.dart
│   ├── pages/<name>_list_page.dart, <name>_details_page.dart
│   └── widgets/<name>_{item_tile, form_dialog, search_delegate}.dart
└── <name>_module.dart        # public surface; auto-registered in feature_registry
```

Includes optimistic mutations with rollback, infinite-scroll pagination,
search delegate, add/edit forms, shimmer loading, error/empty views,
delete confirmation, friendly error mapping, and success snackbars — all
flag-gated.

## Driving it from an AI IDE

`packages/generator_mcp/` is an MCP (Model Context Protocol) server that
exposes the generator as a tool surface for AI agents. Six tools:
`get_schema`, `get_presets`, `get_manifest`, `list_features`,
`generate_feature` (with `dry_run`), and `validate`. See
[`packages/generator_mcp/skill.md`](packages/generator_mcp/skill.md).

The server auto-detects its sibling generator package via the workspace
layout — point it at any working project and it scaffolds there.

## Documentation

- **[USAGE.md](USAGE.md)** — full CLI usage, presets, flag schema, template syntax, contributing a template.
- **[ROADMAP.md](ROADMAP.md)** — what ships today, architecture invariants, **known limitations** (read this before adopting), prioritized roadmap, multi-framework portability walkthrough, OpenAPI integration plan.
- **[packages/generator/README.md](packages/generator/README.md)** — generator engine internals.
- **[packages/generator_mcp/skill.md](packages/generator_mcp/skill.md)** — MCP server tool surface for AI IDEs.

## CI

`.github/workflows/ci.yml` runs three jobs on every push and PR — generator (`dart analyze` + `dart test`), generator_mcp (`dart analyze` + `dart test`, including the integration test that pipes JSON-RPC at the server), example_app (`flutter analyze --fatal-infos --fatal-warnings` + `flutter test`).
