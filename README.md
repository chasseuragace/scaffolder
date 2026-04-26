# Flutter Feature Generator

A small, opinionated code generator that scaffolds production-shape Flutter
features (Clean Architecture + Riverpod + tests) and wires them into the
app shell automatically. Output is guaranteed to pass `flutter analyze` and
`flutter test` from the moment it lands.

The engine itself is framework-agnostic — re-targeting it to React, a
server, or any other text-templated codebase is a templates-directory
swap, not a rewrite. See [`ROADMAP.md`](ROADMAP.md).

## Quick start

```bash
flutter pub get
dart run tool/bin/generate.dart --core-only        # bootstrap once
dart run tool/bin/generate.dart Invoice            # standard preset
dart run tool/bin/generate.dart Note --preset simple
flutter analyze && flutter test
flutter run
```

## What you get

```
lib/
├── core/               # shared infra (failures, pagination, widgets, registry)
├── features/<name>/
│   ├── domain/         # entities + repository contracts + use cases
│   ├── data/           # models + fake repo + impl stub
│   ├── presentation/   # Riverpod providers + pages + widgets
│   └── <name>_module.dart
└── main.dart
```

A working in-memory fake repository, optimistic mutations, optional
infinite-scroll pagination, search, forms, shimmer loading, error/empty
views, and per-feature unit tests — all flag-gated.

## Documentation

- **[GENERATOR_README.md](GENERATOR_README.md)** — full usage, presets, flag schema, template syntax, contributing a template.
- **[ROADMAP.md](ROADMAP.md)** — what ships today, architecture invariants, **known limitations** (read this before adopting), prioritized roadmap, multi-framework portability walkthrough, OpenAPI integration plan.
- **[tool/README.md](tool/README.md)** — internals of the generator engine.
