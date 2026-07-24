#!/usr/bin/env bash
# =============================================================================
# MediaHub v2 — ADR-002 dependency rule checker (NEW)
# =============================================================================
# Replaces import_lint (removed in Bootstrap Validation).
# Enforces Clean Architecture import rules via grep.

set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== ADR-002 Import Rule Check ==="

VIOLATIONS=0

# Rule 1: domain must NOT import Flutter, Drift, dio, http, riverpod
echo "-> Checking domain package..."
if grep -r "import 'package:flutter/" packages/domain/lib/ 2>/dev/null || \
   grep -r "import 'package:drift/" packages/domain/lib/ 2>/dev/null || \
   grep -r "import 'package:dio/" packages/domain/lib/ 2>/dev/null || \
   grep -r "import 'package:http/" packages/domain/lib/ 2>/dev/null || \
   grep -r "import 'package:flutter_riverpod/" packages/domain/lib/ 2>/dev/null; then
  echo "   ❌ domain package imports forbidden framework (ADR-002 violation)"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "   ✅ domain clean"
fi

# Rule 2: presentation (app) must NOT import data directly
echo "-> Checking presentation layer..."
if grep -r "import 'package:mediahub_data/" app/lib/presentation/ 2>/dev/null || \
   grep -r "import 'package:data/" app/lib/presentation/ 2>/dev/null; then
  echo "   ❌ presentation imports data directly (ADR-002 violation)"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "   ✅ presentation clean"
fi

# Rule 3: design_system must NOT import domain, application, data
echo "-> Checking design_system package..."
if grep -r "import 'package:mediahub_domain/" packages/design_system/lib/ 2>/dev/null || \
   grep -r "import 'package:mediahub_application/" packages/design_system/lib/ 2>/dev/null || \
   grep -r "import 'package:mediahub_data/" packages/design_system/lib/ 2>/dev/null; then
  echo "   ❌ design_system imports business layer (ADR-002 violation)"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "   ✅ design_system clean"
fi

# Summary
if [ $VIOLATIONS -gt 0 ]; then
  echo ""
  echo "❌ ADR-002 check FAILED: $VIOLATIONS violation(s) found"
  exit 1
fi

echo ""
echo "✅ All ADR-002 import rules satisfied"
