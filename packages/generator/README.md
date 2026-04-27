# tool/

Generator implementation. See `../USAGE.md` for usage.

## Layout

```
tool/
├── bin/generate.dart         # CLI entry point
└── src/
    ├── case_helpers.dart     # tokenize + Pascal/camel/snake/upper/kebab conversions
    ├── schema.dart           # parses templates/schema.yaml (flag definitions + conflicts)
    ├── preset.dart           # parses templates/presets/*.yaml
    ├── manifest.dart         # parses templates/manifest.yaml (file groups)
    ├── renderer.dart         # mustache substitution + line-marker conditionals
    ├── registry_writer.dart  # idempotent edits to feature_registry.dart
    └── generator.dart        # orchestrates schema -> preset -> manifest -> render -> write
```

The generator has zero Flutter dependencies; it is plain Dart that reads
yaml. Tests live in `../test/tool/`.

## Adding a new template file

1. Create `templates/<group>/<name>.dart.tmpl` using the substitution
   placeholders and `// #if features.X` markers as needed.
2. Add an entry to `templates/manifest.yaml` under `core` (one-shot) or
   `feature` (per-feature). Set `when: <flag>` to gate it.
3. Run `dart run tool/bin/generate.dart <Module> --overwrite` to verify.

## Adding a new flag

1. Declare it in `templates/schema.yaml` with `default` and `description`.
2. Reference it from at least one template (`// #if features.<flag>`) or
   manifest entry (`when: <flag>`).
3. Decide which presets opt in via `templates/presets/*.yaml`.

## Documentation

- See `templates/docs/FILTERS.md` for comprehensive guide on implementing
  generic filter parameters for API query params.

## Limits

- Conditionals are line-based and do not nest (renderer raises).
- No three-way merge on regeneration — `--overwrite` is destructive.
- `repository_impl.dart` is a hand-edit stub. The intended path forward is
  an openapi-generated client, see USAGE.md.
