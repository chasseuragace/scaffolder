# Flutter Feature Generator

An opinionated code generator that scaffolds production-shape Flutter
features (Clean Architecture + Riverpod + tests) and wires them into the
app shell automatically. Generated code passes `flutter analyze` and
`flutter test` from the moment it lands.

The engine is framework-agnostic — retargeting to React, a server, or any
other text-templated codebase is a templates-directory swap, not a
rewrite. See [`ROADMAP.md`](ROADMAP.md).

## Repo layout

```
packages/
├── generator/          — engine + CLI + templates  (pure Dart, no Flutter)   ← workspace
├── generator_mcp/      — MCP server for AI IDEs    (pure Dart, no Flutter)   ← workspace
├── example_app/        — Flutter playground that consumes generator output   ← standalone
└── example_react_app/  — React playground that consumes generator output    ← standalone
```

The dev tools (`generator` and `generator_mcp`) form a Dart workspace —
one `dart pub get` at repo root resolves both, and `dart test` works
without a Flutter SDK installed.

The example apps are normal framework projects. Each has its own package
config and is driven by the framework's tooling (`flutter pub` for Flutter,
`npm` for React).

## Quick start

### Flutter

```bash
# 1. Resolve the dev tools (pure Dart, no Flutter SDK required)
dart pub get

# 2. Scaffold a feature into the example app
dart run packages/generator/bin/generate.dart Invoice --out packages/example_app

# 3. Run the Flutter app
cd packages/example_app
flutter pub get
flutter analyze && flutter test
flutter run
```

### React

```bash
# 1. Resolve the dev tools (pure Dart, no Flutter SDK required)
dart pub get

# 2. Scaffold a feature into the React example app
dart run packages/generator/bin/generate.dart Product --out packages/example_react_app --templates templates_react

# 3. Run the React app
cd packages/example_react_app
npm install
npm run build && npm test
npm run dev
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

`.github/workflows/ci.yml` runs three jobs on every push and PR. The two pure-Dart jobs (`generator`, `generator_mcp`) don't install Flutter — they boot in seconds. The `example_app` job installs Flutter and runs the full app pipeline (`flutter analyze --fatal-infos --fatal-warnings` + `flutter test`).
