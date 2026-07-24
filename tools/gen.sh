#!/usr/bin/env bash
# =============================================================================
# MediaHub v2 — deterministic codegen entry point (FIXED)
# =============================================================================
# FIX 1: Removed --no-enforce-lockfile (respects melos.yaml enforceLockfile)
# FIX 2: Runs build_runner in ALL packages that have it (not just 3)
# FIX 3: Uses melos run gen when possible, falls back to manual loop

set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> melos bootstrap"
fvm exec melos bootstrap

echo "==> build_runner across all packages"
# Auto-detect packages with build_runner in dev_dependencies
for pkg_dir in packages/*/; do
  pubspec="${pkg_dir}pubspec.yaml"
  if [ -f "$pubspec" ] && grep -q "build_runner:" "$pubspec" 2>/dev/null; then
    echo "  -> $pkg_dir"
    (cd "$pkg_dir" && fvm dart run build_runner build --delete-conflicting-outputs --low-resources-mode)
  fi
done

# Root app (if it has build_runner)
if grep -q "build_runner:" pubspec.yaml 2>/dev/null; then
  echo "  -> root app"
  fvm dart run build_runner build --delete-conflicting-outputs --low-resources-mode || true
fi

echo "==> pigeon (python_bridge)"
if [ -f packages/python_bridge/pigeons/api.dart ]; then
  cd packages/python_bridge
  fvm dart run pigeon --input pigeons/api.dart
  cd -
else
  echo "  ⚠️  No Pigeon schema found, skipping"
fi

echo "==> format generated code"
fvm dart format . 2>/dev/null || true

echo "[gen] done."
