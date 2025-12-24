# Feature Generator

This small tool generates feature architecture files from `simpler_generator_folders.yaml` template.

Usage:

- From the repository root:

  ```bash
  # generate for 'User' feature
  dart run tool/generate_feature.dart User

  # or using the shell wrapper
  tool/generate_feature.sh User

  # overwrite existing files
  dart run tool/generate_feature.dart User --overwrite

  # use a custom template path or output base
  dart run tool/generate_feature.dart User --template my_template.yaml --out lib
  ```

Notes:
- Place `simpler_generator_folders.yaml` at the project root (it already exists).
- The script uses placeholder replacements:
  - `ModuleName` -> PascalCase (e.g., `UserProfile`)
  - `module_name` -> snake_case (e.g., `user_profile`)
  - `NAME` -> UPPER_SNAKE_CASE (e.g., `USER_PROFILE`)
- By default the generated files are written under `lib/<category>/...`. Use `--out` to change the base folder.

