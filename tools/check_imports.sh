#!/usr/bin/env bash
# =============================================================================
# MediaHub v2 — Phase 0 import-rule checker (replaces import_lint)
# Authority: ADR-002 (dependency rule), ADR-015 (CI build-breaking)
# =============================================================================
# Reads the rule definitions in packages/tooling/import_lint/config.yaml and
# enforces them via grep. This is a Phase 0 stop-gap; Phase 1 will replace it
# with a proper custom_lint plugin (see DEVIATIONS.md).
#
# The script exits 1 on any violation.
# =============================================================================
set -euo pipefail

cd "$(dirname "$0")/.."

CONFIG="packages/tooling/import_lint/config.yaml"
if [ ! -f "$CONFIG" ]; then
    echo "::error::import-lint config not found at $CONFIG"
    exit 1
fi

# ── Hard-coded rule table (mirrors config.yaml) ───────────────────────────────
# Format: "target_glob|banned_import_pattern|rule_name"
RULES=(
  # DOMAIN PURITY (ADR-002)
  "packages/domain/lib/**/*.dart|package:flutter/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:flutter_riverpod/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:riverpod_annotation/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:drift/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:sqlite3_flutter_libs/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:dio/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:flutter_secure_storage/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:workmanager/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:sentry_flutter/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:path_provider/|domain_no_flutter"
  "packages/domain/lib/**/*.dart|package:mediahub_data/|domain_no_outer_packages"
  "packages/domain/lib/**/*.dart|package:mediahub_application/|domain_no_outer_packages"
  "packages/domain/lib/**/*.dart|package:mediahub_design_system/|domain_no_outer_packages"
  "packages/domain/lib/**/*.dart|package:mediahub_python_bridge/|domain_no_outer_packages"
  "packages/domain/lib/**/*.dart|package:mediahub_sync_engine/|domain_no_outer_packages"

  # DATA ISOLATION
  "packages/data/lib/**/*.dart|package:flutter/widgets.dart|data_no_flutter_ui"
  "packages/data/lib/**/*.dart|package:flutter/material.dart|data_no_flutter_ui"
  "packages/data/lib/**/*.dart|package:flutter/cupertino.dart|data_no_flutter_ui"
  "packages/data/lib/**/*.dart|package:flutter_riverpod/|data_no_flutter_ui"
  "packages/data/lib/**/*.dart|package:riverpod_annotation/|data_no_flutter_ui"
  "packages/data/lib/**/*.dart|package:mediahub_application/|data_no_flutter_ui"
  "packages/data/lib/**/*.dart|package:mediahub_design_system/|data_no_flutter_ui"

  # APPLICATION LAYER
  "packages/application/lib/**/*.dart|package:drift/|application_no_data"
  "packages/application/lib/**/*.dart|package:dio/|application_no_data"
  "packages/application/lib/**/*.dart|package:flutter_secure_storage/|application_no_data"
  "packages/application/lib/**/*.dart|package:mediahub_data/|application_no_data"
  "packages/application/lib/**/*.dart|package:mediahub_python_bridge/|application_no_data"
  "packages/application/lib/**/*.dart|package:mediahub_design_system/|application_no_data"

  # DESIGN_SYSTEM ISOLATION
  "packages/design_system/lib/**/*.dart|package:mediahub_domain/|design_system_isolated"
  "packages/design_system/lib/**/*.dart|package:mediahub_application/|design_system_isolated"
  "packages/design_system/lib/**/*.dart|package:mediahub_data/|design_system_isolated"
  "packages/design_system/lib/**/*.dart|package:mediahub_python_bridge/|design_system_isolated"
  "packages/design_system/lib/**/*.dart|package:mediahub_sync_engine/|design_system_isolated"
  "packages/design_system/lib/**/*.dart|package:drift/|design_system_isolated"
  "packages/design_system/lib/**/*.dart|package:dio/|design_system_isolated"

  # PYTHON_BRIDGE ISOLATION
  "packages/python_bridge/lib/**/*.dart|package:flutter/widgets.dart|python_bridge_isolated"
  "packages/python_bridge/lib/**/*.dart|package:flutter/material.dart|python_bridge_isolated"
  "packages/python_bridge/lib/**/*.dart|package:flutter_riverpod/|python_bridge_isolated"
  "packages/python_bridge/lib/**/*.dart|package:drift/|python_bridge_isolated"
  "packages/python_bridge/lib/**/*.dart|package:dio/|python_bridge_isolated"
  "packages/python_bridge/lib/**/*.dart|package:mediahub_application/|python_bridge_isolated"
  "packages/python_bridge/lib/**/*.dart|package:mediahub_design_system/|python_bridge_isolated"

  # SYNC_ENGINE ISOLATION
  "packages/sync_engine/lib/**/*.dart|package:flutter/widgets.dart|sync_engine_isolated"
  "packages/sync_engine/lib/**/*.dart|package:flutter/material.dart|sync_engine_isolated"
  "packages/sync_engine/lib/**/*.dart|package:flutter_riverpod/|sync_engine_isolated"
  "packages/sync_engine/lib/**/*.dart|package:mediahub_application/|sync_engine_isolated"
  "packages/sync_engine/lib/**/*.dart|package:mediahub_design_system/|sync_engine_isolated"

  # APP CANNOT IMPORT DATA FRAMEWORKS DIRECTLY
  # The presentation layer (lib/presentation/) talks to the application layer;
  # never to the data layer's frameworks. lib/bootstrap/ is the composition
  # root (ADR-002 Chapter 6.3) and IS allowed to import the data layer to
  # wire repository impls — see the BOOTSTRAP_EXEMPT pattern below.
  "lib/**/*.dart|package:drift/|app_no_data_frameworks"
  "lib/**/*.dart|package:dio/|app_no_data_frameworks"
  "lib/**/*.dart|package:flutter_secure_storage/|app_no_data_frameworks"
  "lib/**/*.dart|package:sqlite3_flutter_libs/|app_no_data_frameworks"
  "lib/**/*.dart|package:workmanager/|app_no_data_frameworks"
  "lib/**/*.dart|package:mediahub_data/|app_no_data_frameworks"
  "lib/**/*.dart|package:mediahub_python_bridge/|app_no_data_frameworks"
  "lib/**/*.dart|package:mediahub_sync_engine/|app_no_data_frameworks"
)

# Extensions to skip (generated files)
SKIP_PATTERN='\.(g|freezed|drift)\.dart$'

# Path patterns to EXEMPT from the app_no_data_frameworks rules.
# The composition root (lib/bootstrap/) is the ONLY place in the app that
# may import data-layer packages (drift, mediahub_data, etc.) — it wires
# repository implementations into application-layer providers.
# See ADR-002 Chapter 6.3: "Cross-cutting services are wired in bootstrap."
BOOTSTRAP_EXEMPT='/bootstrap/'

violations=0
total_files_checked=0

echo "── ADR-002 import-rule checker (Phase 0 grep-based) ──"
echo "   Config: $CONFIG"
echo "   Rules:  ${#RULES[@]}"
echo ""

for rule in "${RULES[@]}"; do
    IFS='|' read -r glob pattern name <<< "$rule"
    # Find matching files
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        # Skip generated
        if [[ "$file" =~ $SKIP_PATTERN ]]; then
            continue
        fi
        # Exempt the composition root (lib/bootstrap/) from app_no_data_frameworks.
        # The bootstrap wires data-layer impls into application-layer providers;
        # it MUST be allowed to import drift/mediahub_data/etc. (ADR-002 §6.3).
        if [[ "$name" == "app_no_data_frameworks" && "$file" == *"$BOOTSTRAP_EXEMPT"* ]]; then
            continue
        fi
        total_files_checked=$((total_files_checked + 1))
        # Check for the banned import pattern (only on import lines)
        if grep -nE "^import\s+['\"]${pattern}" "$file" >/dev/null 2>&1; then
            line=$(grep -nE "^import\s+['\"]${pattern}" "$file" | head -1)
            echo "  ❌ $name"
            echo "     file: $file"
            echo "     line: $line"
            violations=$((violations + 1))
        fi
    done < <(eval find . -type f -path "./$glob" 2>/dev/null)
done

echo ""
echo "── Summary ──"
echo "   Files checked: $total_files_checked"
echo "   Violations:    $violations"

if [ "$violations" -gt 0 ]; then
    echo ""
    echo "::error::ADR-002 dependency rule violations detected. See above."
    exit 1
fi

echo "✅ ADR-002 dependency rule: PASS"
exit 0
