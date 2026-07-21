#!/usr/bin/env bash
# =============================================================================
# MediaHub v2 — deterministic codegen entry point (ADR-004)
# =============================================================================
# Same command runs locally, in CI gen-check, and in pre-commit hooks.
# No arguments — fully deterministic.
#
# Bootstrap Validation note: melos exec runs build_runner per-package
# (each package has its own dev_dependencies + build_runner config). Pigeon
# runs separately as it has its own CLI.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> melos bootstrap (resolves packages + lockfile)"
melos bootstrap

echo "==> dart run build_runner (per-package via melos exec)"
# Run only in packages that have build_runner as a dev_dependency
for pkg in domain data application; do
  if [ -f "packages/$pkg/pubspec.yaml" ]; then
    echo "  -> packages/$pkg"
    (cd "packages/$pkg" && \
     dart run build_runner build --delete-conflicting-outputs --low-resources-mode)
  fi
done

echo "==> dart run build_runner (root app)"
dart run build_runner build --delete-conflicting-outputs --low-resources-mode || true

echo "==> dart run pigeon (generates python_bridge bindings)"
cd packages/python_bridge
dart run pigeon --input pigeons/api.dart
cd -

echo "==> format generated code"
dart format \
  packages/domain/lib/src/entities/*.g.dart \
  packages/domain/lib/src/entities/*.freezed.dart \
  packages/python_bridge/lib/src/messages.g.dart 2>/dev/null || true

echo "[gen] done."
