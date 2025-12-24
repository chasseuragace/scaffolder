#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 ModuleName [--template path] [--out lib] [--overwrite]"
  exit 2
fi

dart run tool/generate_feature.dart "$@"