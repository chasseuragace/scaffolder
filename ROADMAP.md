# Roadmap

This document captures where the generator is, what is intentionally
deferred, and where it can go. It is the source of truth for "is X coming?"
questions — keep it in sync as priorities shift.

---

## Vision

A small, opinionated **feature scaffolder** that:

1. Produces production-shape code: layered architecture, idiomatic state
   management, tests, and a working in-memory implementation that compiles
   and analyzes clean from day one.
2. Treats **the spec as the contract** — generated features should be
   trivially swappable to backends produced from the same OpenAPI document
   that drives the server.
3. Has a **framework-agnostic engine**: the same schema/manifest/preset/
   renderer/registry pipeline can scaffold a Flutter feature today and a
   React (or other) feature tomorrow by swapping the template directory.

The generator is not trying to be a build-runner replacement, a code-mod
tool, or a full IDE. It scaffolds the file shape; the developer owns the
business logic.

---

## What ships today (v1)

| Layer | Coverage |
|---|---|
| Architecture | Clean Architecture per feature: domain (entity / repository / use cases) → data (model / fake / impl stub) → presentation (Riverpod AsyncNotifier providers / pages / widgets) |
| Per-feature isolation | Everything under `lib/features/<name>/`; features coexist without collision |
| Shared core | `failures`, `pagination`, `usecase`, `feature_registry`, generic widgets — generated once into `lib/core/` |
| State management | Riverpod 2.x AsyncNotifier with optimistic updates, error rollback, refresh, edit, remove, add |
| Pagination | `PaginationParams` / `PaginatedResponse<T>`, `loadMore()`, `<module>HasMoreProvider`, infinite-scroll list |
| Search | `searchProvider` family + `SearchDelegate` widget, gated |
| Forms | Add/edit dialog with validation, gated |
| UI affordances | shimmer skeletons, error view, empty view |
| Routing | `FeatureRegistry` with idempotent generated edits inside `// GENERATED` markers |
| Testing | Generated repository tests against the in-memory fake; generator self-tests for case helpers, renderer, registry writer, end-to-end |
| Presets | `simple`, `standard`, `enterprise` |
| CLI | `--preset`, `--feature flag=bool`, `--core-only`, `--overwrite`, `--templates`, `--root`, `--package` |

**Quality gates**: `flutter analyze` clean; `flutter test` 35/35 green; three
coexisting features (User, Order, UserProfile) generated and verified.

---

## Architecture invariants

These are the load-bearing decisions. Changing any of them is a v2 break,
not a v1 change.

### 1. Engine is framework-agnostic

```
                ┌─────────────────────────────────────────┐
                │  ENGINE (tool/src/, framework-agnostic) │
                │                                         │
                │   case_helpers   schema   preset        │
                │   manifest       renderer registry      │
                │   generator      bin/generate.dart      │
                └────────────────────┬────────────────────┘
                                     │
                ┌────────────────────┼────────────────────┐
                │                    │                    │
                ▼                    ▼                    ▼
   ┌────────────────┐   ┌────────────────┐   ┌────────────────┐
   │   templates/   │   │ templates_react/│  │ templates_node/│
   │  (Flutter, v1) │   │   (future)      │  │   (future)     │
   └────────────────┘   └────────────────┘   └────────────────┘
```

The engine knows nothing about Dart, Flutter, or Riverpod. It loads
templates, substitutes placeholders, gates with line-based conditionals,
and writes files. Re-targeting it for React means swapping the templates
directory — see "Multi-framework portability" below.

### 2. Spec at the centre

Domain entities and use cases never reference framework or wire formats.
Only `<feature>_repository_impl.dart` knows the wire shape. Swapping it
for a variant that wraps an OpenAPI-generated dart-dio client (or any
other transport) does not move anything else.

### 3. Conditionals are line-based, non-nesting

`// #if features.X` ... `// #else` ... `// #endif` lives in line comments.
Templates remain syntactically close-to-valid in their target language so
editors can still highlight them. Nesting is intentionally rejected — it
encourages flatter, clearer templates and helper-method extraction.

### 4. Generation is idempotent

Re-running on an existing feature is a no-op by default. `--overwrite`
replaces files. `feature_registry.dart` carries `preserve: true` so it is
written once and only ever touched via the marker-aware `RegistryWriter`.

---

## Roadmap

Priority is "value × confidence ÷ effort." Items are roughly ordered;
exact ordering is a planning decision, not a contract.

### Short-term — finish the v1 story

**S1. Dio-based default `repository_impl`**
Today the non-fake `repository_impl.dart` throws `UnimplementedError`.
Ship a Dio-based variant behind a flag (`http_client: dio`) so the
generator produces a working real-API path out of the box: base URL config,
interceptor slot, error mapping (DioException → `Failure` subtype).
*Why now:* removes the only "but it doesn't actually call a backend" gap.

**S2. Failure → user-message mapper**
`error: (e, _) => ErrorView(message: e.toString())` is ugly. Add
`lib/core/errors/failure_messages.dart` that maps each `Failure` subtype
to a localized-ready string. Generated UI pulls from it.

**S3. Cursor-based pagination variant**
Many real APIs are cursor-paginated, not offset-based. Add a
`pagination_style: offset|cursor` schema field; ship a `cursor` variant of
the repository contract and notifier. Same surface in the UI.

**S4. `--diff` regeneration mode**
`--overwrite` clobbers hand-edits. Add a three-way mode that reports
diffs against the previous generation and applies non-conflicting changes.
Implementation: stash the rendered output as `<file>.generated`; diff
on regen.

**S5. Per-feature DI scoping**
Today the repository provider lives in the feature's `providers.dart`.
For larger apps, a `<feature>Module.providers()` factory that exposes
testable overrides is cleaner. Ship as an opt-in flag.

### Medium-term — production maturity

**M1. OpenAPI integration**
Add a `--openapi <package>` mode that generates a `repository_impl_openapi.dart.tmpl`
variant, importing the openapi-generated client and mapping DTOs ↔ entities.
The user's existing
`/Volumes/shared_code/code_shared/portal/dev_tools/package_form_open_api`
tool already produces the dart-dio client; this slots into it. Server side,
the same spec drives a python-flask generator output for symmetry.

**M2. Offline cache layer**
A flag (`offline: hive|sqflite|none`) that injects a caching repository
decorator in front of the remote one: read-through cache, optional
write-back queue. Requires DI scoping (S5) to compose cleanly.

**M3. Retry policies**
`retry: { attempts: 3, backoff: exponential }` flag wires a retry decorator
around the repository. Surfaces a `RetryFailure` to the UI when exhausted.

**M4. Telemetry hooks**
`telemetry: sentry|firebase|custom` adds breadcrumbs at repository call
boundaries and exception capture in the AsyncNotifier error paths. Custom
mode generates an interface; user wires their own backend.

**M5. Stream-based providers**
For real-time domains, generate `StreamProvider` variants that subscribe
to a websocket / SSE stream. Repository contract gains `watch()` methods.

**M6. Form validation library**
Today's form validation is one-line "Required". Ship a small
`FormField<T>` framework with composable validators and a
`<feature>FormSchema` description so the generated dialog reflects domain
constraints.

**M7. Equatable / freezed support**
Currently entities hand-roll `==`/`hashCode`. Flag (`equatable` or
`freezed`) generates the appropriate variants for teams that already use
those packages.

### Long-term — strategic

**L1. Multi-framework parity**
Ship `templates_react/` (Vite + TanStack Query + React Router) as a peer
of `templates/`. Same engine, same flag schema, same preset shape.
See "Multi-framework portability" below.

**L2. Server-side templates**
`templates_python_flask/` and `templates_node_express/` that consume the
same OpenAPI spec and produce wired controllers + service layer.
Generator becomes a "spec → full stack" tool.

**L3. Plugin architecture**
External `templates_*` packages discovered via convention. Users author
their own template packs without forking. A `--templates-package` flag
loads them.

**L4. Web UI**
Point-and-click feature scaffolder that drives the same engine. Useful
for non-CLI-fluent product engineers and for live demos.

**L5. Migration runbook generation**
When templates evolve, a `--migrate-from <commit>` mode that produces a
commented diff and a step-by-step "apply this to your hand-edited files"
script.

---

## Multi-framework portability

**The engine is already framework-agnostic.** Re-targeting to React (or any
other framework) is a templates-and-conventions exercise, not a code rewrite.

### What stays identical

| Engine module | What it does |
|---|---|
| `tool/src/case_helpers.dart` | Tokenize + Pascal/camel/snake/upper/kebab |
| `tool/src/schema.dart` | Parse flag definitions and conflict rules |
| `tool/src/preset.dart` | Parse preset YAML files |
| `tool/src/manifest.dart` | Parse template → output mappings, gating fields |
| `tool/src/renderer.dart` | `{{placeholder}}` substitution + `// #if` line markers |
| `tool/src/registry_writer.dart` | Idempotent edits inside `// GENERATED` markers |
| `tool/src/generator.dart` | Orchestrate schema → preset → manifest → render → write |
| `tool/bin/generate.dart` | CLI |

Zero of these reference Dart, Flutter, Riverpod, or any framework concept.
They are text-and-files all the way down.

### What changes per framework

1. **Templates directory**. `templates_react/` mirrors `templates/`'s shape:
   `schema.yaml`, `manifest.yaml`, `presets/*.yaml`, `core/*.tmpl`,
   `feature/**/*.tmpl`. File extensions become `.tsx.tmpl`, `.ts.tmpl`,
   etc. The engine doesn't care about extensions.

2. **Output paths in manifest**. `lib/features/{{module_snake}}/...` →
   `src/features/{{module-kebab}}/...` (idiomatic React layout).

3. **Registry shape**. Flutter's `FeatureRegistry.all` is a `const List<FeatureDescriptor>`.
   React's equivalent is a route array consumed by React Router. Same
   `// GENERATED:imports` / `// GENERATED:entries` marker pattern;
   different content between the markers. The `RegistryWriter` doesn't
   care — it's marker-aware, content-blind.

4. **Conditional line-comment syntax stays `//` for TypeScript** (same as Dart).
   For other languages (Python `#`, Ruby `#`, HTML `<!-- -->`), the
   renderer's marker regex would need to be parameterised — small change.

### A worked sketch — React port

```
templates_react/
├── schema.yaml                    # shared shape; flags renamed to react idioms
├── manifest.yaml
├── presets/
│   ├── simple.yaml
│   ├── standard.yaml
│   └── enterprise.yaml
├── core/
│   ├── failures.ts.tmpl           # discriminated union
│   ├── pagination.ts.tmpl
│   ├── error_view.tsx.tmpl
│   ├── empty_view.tsx.tmpl
│   ├── shimmer_tile.tsx.tmpl
│   └── feature_registry.ts.tmpl   # route array with markers
└── feature/
    ├── domain/
    │   ├── entity.ts.tmpl
    │   ├── repository.ts.tmpl
    │   └── usecases.ts.tmpl
    ├── data/
    │   ├── model.ts.tmpl
    │   ├── repository_impl.ts.tmpl
    │   └── repository_fake.ts.tmpl
    ├── presentation/
    │   ├── hooks.ts.tmpl          # TanStack Query hooks instead of Riverpod
    │   ├── list_page.tsx.tmpl
    │   ├── item_row.tsx.tmpl
    │   ├── form_dialog.tsx.tmpl
    │   └── search_bar.tsx.tmpl
    └── module.ts.tmpl
```

Run as: `dart run tool/bin/generate.dart User --templates templates_react`.
The engine doesn't change.

State management equivalents that map cleanly:

| Flutter | React |
|---|---|
| `AsyncNotifier<List<T>>` | `useQuery` (TanStack Query) |
| optimistic update via `state = ...` | `useMutation` with `onMutate` rollback |
| `<module>HasMoreProvider` (StateProvider) | `useInfiniteQuery` `hasNextPage` |
| Riverpod `Provider` for repository | `RepositoryContext` (React context) |
| `ScrollController` listener | `IntersectionObserver` on a sentinel ref |

Pagination, optimistic updates, fakes for development, error mapping —
all map one-to-one.

### One engine change required for full multi-framework

The renderer's marker regex is currently hardcoded to `//`:

```dart
final ifRe = RegExp(r'^\s*//\s*#if\s+features\.(\w+)\s*$');
```

For Python/Ruby/YAML templates, parameterise the comment prefix per
template directory (e.g. read it from `schema.yaml`'s metadata: `comment: "#"`).
This is roughly 30 lines of code and fully covered by existing
`renderer_test.dart` patterns.

---

## OpenAPI as the contract layer

The medium-term north star. The user already has internal tooling at
`/Volumes/shared_code/code_shared/portal/dev_tools/package_form_open_api`
that runs `openapi-generator` (`dart-dio`) over a spec to produce a
typed Dart API client.

The integration story:

```
        ┌──────────────────┐
        │   openapi.yaml   │   ← single source of truth
        └────────┬─────────┘
                 │
       ┌─────────┴──────────┐
       │                    │
       ▼                    ▼
 dart-dio client     python-flask server
 (data layer)        (api implementation)
       │
       ▼
 our generator
 ─ replaces repository_impl.dart with a Dio-wrapped variant
   that maps DTO ↔ entity
 ─ everything else (entity, use cases, providers, UI) unchanged
```

**Concrete v2 surface**:

```bash
dart run tool/bin/generate.dart User \
  --openapi-package my_api_client \
  --openapi-tag users
```

Effects:
- `repository_impl.dart` template is swapped for `repository_impl_openapi.dart.tmpl`
- That variant imports `package:my_api_client/api.dart`, instantiates the `UsersApi`, and maps DTOs into the existing `UserEntity`
- `<module>_model.dart` becomes optional (the openapi DTOs supersede it; a `model.dart` is generated only as a thin DTO ↔ entity mapper if the schemas diverge)
- `pubspec.yaml` is updated idempotently to depend on the openapi package

This unlocks **changing the spec → regenerate the client → regenerate the
feature → no domain or UI changes needed**.

---

## Known limitations

A candid list of what the tool **does not** do today. None of these are
secret — calling them out up-front saves users from misaligned expectations
and makes it easy to spot the next priority.

### Capability gaps

1. **No working real backend out of the box.** `repository_impl.dart`
   throws `UnimplementedError`. The fake repository is the only path that
   runs. Real HTTP integration is hand-written until **S1** ships.
2. **Pagination is offset-based only.** Cursor pagination (Stripe / GitHub
   style) is not supported yet. **S3** plans the variant.
3. **No state persistence between launches.** The fake repo is purely
   in-memory. Closing the app drops everything. Hive / sqflite caching is
   reserved for **M2**.
4. **No telemetry, retry, or offline policies.** Errors disappear into
   `e.toString()`; failures aren't reported to Sentry/Firebase; failed
   requests don't auto-retry. Reserved for **M3** / **M4**.
5. **No localization.** UI strings are hardcoded English (`'No Users yet'`,
   `'Required'`, `'Edit'`, etc.). Wiring `intl` / `flutter_localizations`
   was deferred — see decision (3) below.
6. **Form validation is trivial.** Single-line `Required` validators only.
   No composable validators, no async/server-side validation, no debounced
   field-level checks. **M6** plans the upgrade.

### Architectural lock-ins

7. **Riverpod-only state management.** Bloc, ChangeNotifier, signals — none
   of these are supported, and adding them triples template surface. Teams
   already standardised elsewhere would need to fork the templates.
8. **Hand-rolled value classes.** No `freezed` / `equatable` integration.
   Entity equality is hand-written `==`/`hashCode` — easy to forget a new
   field on edit. **M7** is the opt-in flag.
9. **Clean Architecture is not optional.** Every feature gets the
   domain/data/presentation split, even when the feature is trivially
   small. We rejected a `simple_mode` toggle in v1 because the conditional
   surface area was unsustainable.
10. **No widget tests on generated UI.** We test the fake repository
    against its contract; we do not test that the generated `list_page`
    renders correctly. `flutter analyze` enforces structural correctness;
    behavioural correctness of the UI is the developer's responsibility.

### Engine simplifications

11. **Conditionals don't nest.** `// #if A` inside `// #if B` is rejected
    by the renderer. The fix is helper-method extraction. Intentional —
    nesting would invite spaghetti templates.
12. **No conditional expressions.** No `// #if !A`, no `&&`, no `||`. If
    you need negation, invert the branches with `// #else`.
13. **Single comment prefix (`//`).** Templates assume C-style line
    comments. Python / Ruby / YAML templates would need the renderer's
    marker regex parameterised — one of the changes flagged in the React
    port walkthrough.
14. **Placeholder typos fail at render time, not parse time.** A typo like
    `{{Modle}}` only errors when the renderer can't resolve it. A stricter
    template-time validator (cross-checking placeholders against the known
    substitution set) is a small future improvement.

### DX gaps

15. **`--overwrite` is destructive.** Hand-edits are clobbered. Three-way
    merge regeneration (`--diff`) is **S4**.
16. **No build-runner / file-watcher integration.** The generator runs on
    demand. Generated code is committed (deliberate — the generator
    scaffolds, it doesn't compile).
17. **No batch mode.** One feature per invocation. A `--from-manifest
    features.yaml` mode that scaffolds a list at once is not yet shipped.
18. **No CI workflow shipped.** A `.github/workflows/test.yml` that runs
    `flutter analyze && flutter test` and re-validates the generator's
    output on every PR is missing — easy to add when the project moves
    to GitHub.

### Production polish gaps

19. **No accessibility scaffolding.** No `Semantics` widgets, no explicit
    keyboard-traversal hints, no font-scaling overrides. A11y is left to
    Material defaults — fine for many apps, not enough for compliance-bound
    products.
20. **No optimistic-update conflict resolution.** Two simultaneous edits
    against the same id will both apply locally; reconciliation is by
    "whoever's `update` returned last." No CRDT, no vector clocks. Fine
    for v1, brittle for collaborative apps.
21. **Single `_pageSize = 20` per feature.** Hardcoded constant in the
    generated `providers.dart`. Not configurable per call (e.g., bigger
    pages for search results). Edit the constant after generation.

If any of these block your use case, that's a strong signal to bump the
matching roadmap item up the queue — or fork the templates and ship a
local override.

## Open questions / decisions deferred

These are real fork-in-the-road choices that have not been made yet.
Listed so the next person picking this up doesn't redo the analysis.

1. **State management lock-in.** Riverpod is opinionated. Should the
   templates support Bloc or hand-rolled `ChangeNotifier` as alternative
   presentation layers? Probably not for v1 — the cost is template-set
   triplication. Revisit if there is a multi-team rollout where teams
   already standardised on different libraries.

2. **`freezed` vs hand-rolled value classes.** Today entities are
   hand-rolled. `freezed` produces nicer code but adds a build step and
   `build_runner`. M7 leaves this as a flag.

3. **Localization.** Today titles like `'No {{Module}}s yet'` are
   hardcoded. Wiring `intl` or `flutter_localizations` requires a project
   convention (ARB files, generated keys). Deferred until a real
   localization need surfaces.

4. **Test coverage of generated UI.** Today we test the fake repository.
   Widget-testing the generated `<feature>_list_page.dart` is feasible
   but adds significant template surface and dependencies. Deferred —
   structural correctness is enforced by `flutter analyze` already.

5. **Generated code in version control.** Convention: yes, generated code
   is committed (it's stable, deterministic, and developer-owned post
   generation). The generator is not a build-time tool; it scaffolds once.

6. **Naming of `Module` vs `Feature`.** Used somewhat interchangeably.
   `Module` is the file/class name; `Feature` is the routing/registry
   concept. Worth aligning if it ever becomes confusing.

---

## Contributing a new template

The shortest path to making the generator do something new:

1. **Add a flag** to `templates/schema.yaml` if the change is conditional.
2. **Add a template** under `templates/core/` (one-shot) or `templates/feature/` (per-feature). Use `{{Module}}` / `{{module_snake}}` placeholders and `// #if features.X` line markers.
3. **Add a manifest entry** in `templates/manifest.yaml` mapping the
   template to its output path. Use `when:` to gate, `once:` for one-shot,
   `preserve:` if you mutate the file idempotently elsewhere.
4. **Run** `dart run tool/bin/generate.dart Sample --overwrite` and verify `flutter analyze && flutter test` stay green.
5. **Add tests** to `test/tool/` for any non-trivial generator behaviour
   the new template depends on.

That's the whole loop.
