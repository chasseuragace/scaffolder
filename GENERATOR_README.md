# Flutter Feature Generator

A small, opinionated code generator that scaffolds a Clean-Architecture
Flutter feature (domain → data → presentation) and wires it into the app
shell automatically. Built around a flag-gated template system; output is
guaranteed to pass `flutter analyze` and `flutter test`.

## What you get per feature

```
lib/features/<name>/
├── domain/
│   ├── entities/<name>_entity.dart
│   ├── repositories/<name>_repository.dart        # abstract contract
│   └── usecases/<name>_usecases.dart              # GetAll / GetById / Add / Update / Delete / Search
├── data/
│   ├── models/<name>_model.dart                   # toJson / toEntity / dummy()
│   └── repositories/
│       ├── <name>_repository_impl.dart            # stub for real backend
│       └── <name>_repository_fake.dart            # in-memory, used by default
├── presentation/
│   ├── providers/<name>_providers.dart            # Riverpod AsyncNotifier with optimistic updates
│   ├── pages/<name>_list_page.dart
│   └── widgets/
│       ├── <name>_item_tile.dart
│       ├── <name>_form_dialog.dart                # gated by `forms`
│       └── <name>_search_delegate.dart            # gated by `search`
└── <name>_module.dart                             # public surface; descriptor exported here
```

Plus once-per-project shared infrastructure under `lib/core/`:
`failures.dart`, `usecase.dart`, `widgets/{error_view,empty_view,shimmer_tile}.dart`,
`utils/debouncer.dart`, and `routing/feature_registry.dart` (the registry
the generator edits to wire each new feature into the app).

## Usage

```bash
# bootstrap shared core (run once)
dart run tool/bin/generate.dart --core-only

# generate a feature with the default `standard` preset
dart run tool/bin/generate.dart User

# pick a preset
dart run tool/bin/generate.dart Order --preset simple
dart run tool/bin/generate.dart Customer --preset enterprise

# override individual flags
dart run tool/bin/generate.dart Product --feature search=false --feature shimmer_loading=false

# regenerate (clobbers your edits — there's no merge yet)
dart run tool/bin/generate.dart User --overwrite
```

`-h` / `--help` prints the full option list.

Re-running the generator on an existing feature is a **no-op by default** —
you must pass `--overwrite` to replace files. This protects hand-edits.

## Presets

| Preset       | What's on                                                          | Best for                       |
|--------------|--------------------------------------------------------------------|--------------------------------|
| `simple`     | forms, optimistic updates, mock data, json                         | quick prototypes               |
| `standard`   | the above + pagination, search, shimmer, unit tests                | most production features       |
| `enterprise` | same as standard (reserved for future flags)                       | flag a feature as fully-loaded |

Presets are just YAML in `templates/presets/*.yaml`; copy one to add your own.

## Feature flags

Defined canonically in `templates/schema.yaml`. Adding a flag is a 3-step process:
1. Declare it in `schema.yaml` with a description and default.
2. Reference it from a template using `// #if features.<name> ... // #else ... // #endif` line markers, or gate a manifest entry with `when: <name>`.
3. (Optional) opt presets in by setting it in `templates/presets/*.yaml`.

CLI `--feature foo=bool` overrides win over presets, which override schema defaults.

## Template syntax

- **Substitution**: `{{Module}}` → PascalCase, `{{module}}` → camelCase, `{{module_snake}}`, `{{MODULE_UPPER}}`, `{{module-kebab}}`. Unknown placeholders error.
- **Conditionals**: line-level comment markers
  ```dart
  // #if features.search
  ...kept when search is true...
  // #else
  ...kept when search is false...
  // #endif
  ```
  No nesting in v1 (the renderer rejects it). Use multiple sequential blocks instead.

The line-comment shape keeps templates valid-looking Dart so editors and
syntax highlighting still work on `.dart.tmpl` files.

## Feature registry

`lib/core/routing/feature_registry.dart` exposes a constant `FeatureRegistry.all`
list of `FeatureDescriptor`s. Each generated feature contributes a static
`descriptor` from its `<name>_module.dart`. The generator inserts an `import`
and an entry inside the `// GENERATED:imports` and `// GENERATED:entries`
markers — idempotently, alphabetically sorted, indentation preserved.

The shell `main.dart` reads from the registry and renders a one-tap home
list of all registered features.

## Pagination

When `pagination=true`, the generator wires:
- `lib/core/pagination/pagination.dart` — `PaginationParams`, `PaginatedResponse<T>`.
- `<name>_repository.getAllPaginated(params)` on the contract.
- An `AsyncNotifier.loadMore()` that appends pages onto the list state.
- `<module>HasMoreProvider` (a `StateProvider<bool>`) that the UI watches.
- A scroll listener on the list page that triggers `loadMore()` 200px before the bottom.

The fake repository slices its in-memory list by offset/limit, so the wired
behaviour works end-to-end without a backend. The page size is `_pageSize = 20`
inside the providers file — change it in one place per feature.

## Limitations

The full candid list lives in [`ROADMAP.md`](ROADMAP.md#known-limitations).
The headline ones to know before adopting:

- `repository_impl.dart` is an `UnimplementedError` stub — only the fake repo runs end-to-end today.
- `--overwrite` is destructive; no three-way merge yet.
- Pagination is offset-only; cursor pagination is roadmap.
- No localization, no offline cache, no telemetry, no widget tests on generated UI.
- Riverpod is hardcoded as the state management layer.
- Conditional templates can't nest and don't support negation (`// #if !X`).

## Future direction

See [`ROADMAP.md`](ROADMAP.md) for the full roadmap, including:

- **Short-term**: Dio-based default `repository_impl`, failure→message
  mapper, cursor pagination variant, `--diff` regeneration mode.
- **Medium-term**: OpenAPI integration (dart-dio + python-flask, both born
  from the same spec), offline cache, retry policies, telemetry hooks.
- **Long-term**: multi-framework portability — the engine is already
  framework-agnostic; a `templates_react/` directory ships React features
  through the same pipeline. See the React port walkthrough in the roadmap.

## Testing the generator itself

```bash
flutter test
```

Covers: case helpers, renderer (substitutions, conditionals, error paths),
registry writer (idempotent insert, sort, indent), and an end-to-end
generator run that scaffolds a feature into a temp dir and verifies the
file shape and registry edit. Generated features each ship with their own
repository test against the in-memory fake.
