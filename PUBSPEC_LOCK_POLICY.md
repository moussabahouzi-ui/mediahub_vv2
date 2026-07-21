# =============================================================================
# MediaHub v2 — pubspec.lock policy
# Authority: ADR-014 (reproducibility), ADR-018 (dependency hygiene)
# =============================================================================
#
# For an APPLICATION (not a publishable package), pubspec.lock MUST be committed.
# This is non-negotiable for MediaHub v2.
#
# Why:
#   - Reproducibility: every CI build resolves the exact same transitive
#     versions. No "works on my machine" build failures.
#   - Auditability: dependency changes go through PR review.
#   - Supply chain: lockfile changes show up in the diff; reviewers can
#     spot a compromised transitive dep.
#
# Renovate (ADR-018) opens PRs to bump the lockfile; auto-merge is allowed
# ONLY for low-risk deps (pure-Dart packages with a passing test suite).
# AGP/Kotlin/Gradle/Flutter bumps are manual.
#
# The committed lockfile is checked by:
#   - melos bootstrap --enforce-lockfile  (ADR-002)
#   - the gen-check workflow (ADR-015)
#   - the reproducibility check (ADR-014, nightly)
#
# This file is a marker; the actual lockfile lives at:
#   /pubspec.lock
# It is committed (see .gitignore: NOT in the ignore list).
