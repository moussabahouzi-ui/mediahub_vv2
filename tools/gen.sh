#!/usr/bin/env bash
# =============================================================================
# MediaHub v2 — deterministic codegen entry point (FIXED)
# =============================================================================
# FIX: Detects CI environment and uses flutter/dart directly (no fvm).
# Local dev still uses fvm if available.

set -euo pipefail

cd "$(dirname "$0")/.."

# Detect CI: use flutter/dart directly; local: use fvm if available
if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
  FLUTTER="flutter"
  DART="dart"
else
  if command -v fvm &> /dev/null; then
    FLUTTER="fvm flutter"
    DART="fvm dart"
  else
    FLUTTER="flutter"
    DART="dart"
  fi
fi

echo "==> Using: $FLUTTER / $DART"

echo "==> melos bootstrap"
$FLUTTER pub global activate melos 2>/dev/null || true
melos bootstrap

echo "==> build_runner across all packages"
for pkg_dir in packages/*/; do
  pubspec="${pkg_dir}pubspec.yaml"
  if [ -f "$pubspec" ] && grep -q "build_runner:" "$pubspec" 2>/dev/null; then
    echo "  -> $pkg_dir"
    (cd "$pkg_dir" && $DART run build_runner build --delete-conflicting-outputs --low-resources-mode)
  fi
done

if grep -q "build_runner:" pubspec.yaml 2>/dev/null; then
  echo "  -> root app"
  $DART run build_runner build --delete-conflicting-outputs --low-resources-mode || true
fi

echo "==> pigeon (python_bridge)"
if [ -f packages/python_bridge/pigeons/api.dart ]; then
  cd packages/python_bridge
  $DART run pigeon --input pigeons/api.dart
  cd -
else
  echo "  ⚠️  No Pigeon schema found, skipping"
fi

echo "==> format generated code"
$DART format . 2>/dev/null || true

echo "[gen] done."
