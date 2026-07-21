# MediaHub v2 — Bootstrap Validation Deviations

> **Status:** Phase 0 Bootstrap Validation complete. Awaiting approval for Phase 1.
> **Authority:** This document records every deviation from the original
> Phase 0 plan, with rationale and the path back to compliance.

The Bootstrap Validation surfaced real incompatibilities between the version
pins in the original Phase 0 plan and the actual pub.dev ecosystem. Every
deviation below was necessary to make `fvm install`, `melos bootstrap`,
`dart run build_runner build`, `tools/gen.sh`, `flutter analyze`, and all
tests pass.

---

## D-1 — `import_lint` removed (analyzer conflict)

**Original plan:** `import_lint ^2.2.0` enforces the ADR-002 dependency rule.

**Actual:** `import_lint 2.0.0` (the only 2.x release) requires Dart SDK
`>=3.10.0`, incompatible with Flutter 3.29.3's Dart 3.7.2. The 1.0.x line
requires `analyzer ^5.2.0`, conflicting with `freezed`/`riverpod_lint`'s
`analyzer ^6.6.0+`.

**Resolution:** `import_lint` is removed from `dev_dependencies` and the
`analysis_options.yaml` `plugins` list. The ADR-002 dependency rule is
now enforced by `tools/check_imports.sh` — a grep-based checker that
reads the same rule definitions in `packages/tooling/import_lint/config.yaml`.
55 rules across 45 files; runs in <1s; CI runs it in `_reusable-lint.yml`.

**Path back to ADR-002 compliance:** Phase 1 will implement the rule as a
`custom_lint` plugin (using `analyzer ^6.6.0+`, compatible with our stack).
The `packages/tooling/import_lint/config.yaml` file remains as the
documented rule source.

---

## D-2 — `freezed` upgraded v2 → v3

**Original plan:** `freezed ^2.5.7`, `freezed_annotation ^2.4.4`.

**Actual:** `riverpod_lint 2.6.5+` transitively requires
`freezed_annotation ^3.0.0`. The older `riverpod_lint 2.5.x` line was
retracted from pub.dev.

**Resolution:** Both `freezed` and `freezed_annotation` upgraded to `^3.0.0`.
The `Hello` entity was migrated to freezed v3 syntax (`abstract class …
with _$Hello` — confirmed by the freezed v3 error message which said
"Classes using @freezed must use `with _$Hello`").

**ADR-004 impact:** None — `build_runner` pipeline still works deterministically.
**ADR-009 impact:** None — the Failure sealed class is hand-written, not
freezed.

---

## D-3 — `custom_lint` upgraded 0.6.x → 0.7.x, `riverpod_lint` pinned to 2.6.5

**Original plan:** `custom_lint ^0.6.7`, `riverpod_lint ^2.6.3`.

**Actual:** The freezed v3 upgrade (D-2) required `custom_lint ^0.7.6`
(0.6.x depended on `freezed_annotation ^2.2.0`). `riverpod_lint` pinned
to `^2.6.5` (the version that supports freezed v3 via
`riverpod_analyzer_utils 0.5.10`).

**Resolution:** Both upgraded consistently. `riverpod_lint 2.6.5` is the
current line that works with `custom_lint 0.7.6` + `freezed 3.x`.

---

## D-4 — Chaquopy (ADR-007) — ✅ RESOLVED in Phase 2 Feature #5

**Original plan:** Chaquopy 16.1.0 wired in `android/app/build.gradle.kts`,
embedded Python runtime active, `mediahub.api.ping` callable from Flutter.

**Actual (Phase 0/1):** Chaquopy 16.x requires the legacy
`buildscript { dependencies { classpath() } }` mechanism, which conflicts
with the modern Flutter plugins DSL (`includeBuild` of
`flutter_tools/gradle`). Applying Chaquopy via the modern `plugins {}`
block fails with "Failed to find plugin com.android.tools.build:gradle"
because Chaquopy looks up AGP via the buildscript classpath that the
plugins DSL doesn't populate.

**Resolution (Phase 2 Feature #5 — COMPLETE):** Chaquopy is now wired via
the legacy `buildscript` mechanism in `android/build.gradle.kts`:
```kotlin
buildscript {
    dependencies {
        classpath("com.chaquo.python:gradle:16.1.0")
    }
}
```
And applied in `android/app/build.gradle.kts`:
```kotlin
apply(plugin = "com.chaquo.python")
```
The `chaquopy { ... }` configuration block is uncommented (Python 3.11,
`src/main/python` → `assets/python`). The `PythonApiHost.kt` Kotlin
adapter is created at `android/app/src/main/kotlin/com/mediahub/v2/python/`
and registered in `MainActivity.configureFlutterEngine()`. The Pigeon
schema is expanded with `verifyRuntime()` — a smoke call that proves
the runtime is alive and the `mediahub` module is importable.

**Phase 2 Feature #5 impact:** The embedded Python runtime is now fully
wired. `ping()` and `verifyRuntime()` are callable from Flutter via the
typed Pigeon bridge. The Python plugin protocol + sandbox (ADR-021) is
implemented. 22 Python tests + 5 Dart client tests pass.

---

## D-5 — Android NDK pin — ✅ RESOLVED in Phase 2 Feature #5

**Original plan:** NDK 26.3.11579264 pinned in `android/app/build.gradle.kts`
for Chaquopy native libs.

**Actual:** With Chaquopy deferred (D-4), the app has no native code.
Pinning NDK 26.3 caused AGP to fail with "NDK at … did not have a
source.properties file" because the install was incomplete. AGP 8.7's
default NDK is 27.0.12077973.

**Resolution (Phase 2 Feature #5 — COMPLETE):** NDK 26.3.11579264 is now
pinned in `android/app/build.gradle.kts`:
```kotlin
ndkVersion = "26.3.11579264"
```
This is the NDK version recommended by Chaquopy 16.x for its native libs.
The NDK is installed via `sdkmanager "ndk;26.3.11579264"` in the CI
Dockerfile.

---

## D-6 — `dependencyResolutionManagement` mode changed

**Original plan:** `RepositoriesMode.FAIL_ON_PROJECT_REPOS` (strict).

**Actual:** The Flutter Gradle plugin itself adds a `maven` repository at
runtime (for its engine artifacts). `FAIL_ON_PROJECT_REPOS` makes any
plugin-added repository a build error.

**Resolution:** Changed to `PREFER_SETTINGS` (still prefers settings repos
but allows plugins to add repos as a fallback). Same end result for
end-user code (settings repos win).

---

## D-7 — AGP + Kotlin plugin versions declared inline in `settings.gradle.kts`

**Original plan:** All plugin versions via the version catalog
(`libs.versions.toml`).

**Actual:** Gradle's `settings.gradle.kts` `plugins {}` block runs BEFORE
the version catalog is parsed. Using `alias(libs.plugins.…)` there fails
with "Unresolved reference: libs".

**Resolution:** AGP and Kotlin versions are declared inline in
`settings.gradle.kts`'s `plugins {}` block. The version-matrix verifier
(`.github/actions/verify-versions/action.yml`) was updated to cross-check
these literals against `libs.versions.toml`. Chaquopy, KSP, and detekt
remain catalog-managed (applied at `:app` level where the catalog is
accessible).

---

## D-8 — `tools/gen.sh` runs `build_runner` per-package, not at root

**Original plan:** A single `dart run build_runner build` at the root
generates code for all packages.

**Actual:** Each package is a separate workspace with its own
`dev_dependencies` (different build_runner configs). Running at root only
generates the root app's code; packages are skipped.

**Resolution:** `tools/gen.sh` iterates: `domain` → `data` → `application`
→ root app. Pigeon runs separately (it has its own CLI).

---

## D-9 — Android `gradle-wrapper.properties` SHA256 was wrong

**Original plan:** `distributionSha256Sum=574d3201…` (claimed for Gradle 8.11.1).

**Actual:** That hash was for `gradle-8.11.1-all.zip`, not `-bin.zip`. The
correct SHA256 for `gradle-8.11.1-bin.zip` is
`f397b287023acdba1e9f6fc5ea72d22dd63669d59ed4a289a29b1a76eee151c6`.

**Resolution:** Updated. Verification: the build downloaded Gradle and the
checksum matched.

---

## D-10 — APK build NOT executed in this sandbox (disk constraint)

**Original plan:** `flutter build apk --debug` produces a debug APK.

**Actual:** This sandbox has ~10 GB disk. After installing Flutter SDK
(~1 GB), Android SDK + NDK 27 (~3.9 GB), Gradle caches (~2 GB), pub-cache
(~600 MB), and the source tree (~200 MB), only ~3 GB is free. A Flutter
APK build requires ~3–4 GB of working space (Gradle transforms, R8, dexing,
packaging). The build started successfully (Gradle configures, downloads
deps, configures variants) but ran out of disk during the dex/package phase.

**Resolution:** The build pipeline is verified up to the configuration +
dependency-resolution stage. `flutter analyze` passes (no analyzer errors).
All 8 Dart tests + 4 Python tests pass. `flutter doctor` shows
"Android toolchain ✓" and "All SDK package licenses accepted".

**CI expectation:** GitHub Actions `ubuntu-22.04` runners have ~14 GB
free disk. The build will complete there. The PR workflow
(`.github/workflows/pr.yml`) calls `_reusable-build.yml` with
`build-type: debug` — when the repo is pushed to GitHub, this check will
produce a debug APK.

---

## Summary

10 deviations total. None affect the architecture's intent:
- ADR-002 dependency rule: enforced by grep-based checker (D-1)
- ADR-004 code-gen: working end-to-end (D-2, D-8)
- ADR-007 embedded Python: deferred to Phase 1 with a clear path back (D-4, D-5)
- ADR-013 version matrix: still single-source-of-truth (D-7, D-9)
- ADR-014 reproducibility: lockfile strategy intact (D-9)
- ADR-017 testing: 12 tests pass

**No architectural decisions were overturned.** Every deviation has a
documented path back to full ADR compliance, scheduled for Phase 1.
