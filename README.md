# MediaHub v2 — Phase 0 Foundation

> **Status:** Phase 0 (foundation) — **awaiting approval for Phase 1**.
> **Authority:** This setup implements the approved Software Architecture
> Document (SAD). No production features are implemented.

This repository contains the Phase 0 project foundation for MediaHub v2 —
the **structural skeleton + toolchain + CI** that will not break later on
GitHub Actions. No application features, no UI screens, no downloader /
player / playlists are implemented.

## What Phase 0 delivers

| Concern | What was set up | Authority |
|---|---|---|
| Flutter SDK | fvm-pinned to 3.29.3 stable | ADR-014 |
| Clean Architecture | 4 layers + 6 packages + `check_imports.sh` ADR-002 rule | ADR-002 |
| Domain purity | `packages/domain/analysis_options.yaml` structurally bans Flutter/Drift/Riverpod imports | ADR-002 |
| Riverpod-only DI | `flutter_riverpod` + `riverpod_generator` wired | ADR-003 |
| Code-gen pipeline | `build_runner` + `freezed` + `json_serializable` + `riverpod_generator` + `drift_dev` + `pigeon`; deterministic entry `tools/gen.sh` | ADR-004 |
| Local persistence | `drift` dependency declared; DB wiring deferred to Phase 1 | ADR-005 |
| Sync engine | `sync_engine` package scaffolded; WorkManager dep declared | ADR-006 |
| Embedded Python | Chaquopy 16.1.0 wired in `android/app/build.gradle.kts`; Python 3.11; `mediahub.api.ping` stub + pytest contract test | ADR-007 |
| Flutter↔Python IPC | Pigeon schema at `packages/python_bridge/pigeons/api.dart` (Phase 0: `ping`) | ADR-008 |
| Error model | Sealed `Failure` hierarchy in `packages/domain/lib/src/values/failure.dart`; `ErrorBoundary` widget at app root | ADR-009 |
| Reproducible builds | `ci/Dockerfile` pinned image (Flutter 3.29.3 / JDK 17 / Android SDK 35 / NDK 26.3 / Python 3.11); nightly reproducibility check | ADR-014 |
| CI/CD | Reusable workflows (gen-check / lint / test / build / security) + `pr.yml` + `main.yml` + `nightly.yml`; composite actions for flutter/java/python/verify-versions | ADR-015 |
| Version matrix verifier | CI step cross-checks `libs.versions.toml` ↔ `gradle-wrapper.properties` ↔ `.fvm/fvm_config.json` ↔ `ci/Dockerfile` | ADR-013 |
| Test foundation | `test/helpers`, `test/fakes`, `test/golden`, `test/integration`; per-package `test/` directories; smoke tests for domain, app, python | ADR-017 |

## Pinned version matrix

| Component | Version | Defined in |
|---|---|---|
| Flutter SDK | 3.29.3 stable | `.fvm/fvm_config.json` + `ci/Dockerfile` |
| Dart | 3.7.x (bundled) | (Flutter) |
| Android Gradle Plugin | 8.7.3 | `android/gradle/libs.versions.toml` |
| Gradle | 8.11.1 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Kotlin | 2.0.21 | `libs.versions.toml` |
| KSP | 2.0.21-1.0.28 | `libs.versions.toml` |
| JDK | Temurin 17 | `ci/Dockerfile` + `setup-java` action |
| compileSdk / targetSdk | 35 | `android/app/build.gradle.kts` |
| minSdk | 26 | `android/app/build.gradle.kts` |
| NDK | 26.3.11579264 | `android/app/build.gradle.kts` + `ci/Dockerfile` |
| Chaquopy | 16.1.0 | `libs.versions.toml` |
| Python | 3.11 | `libs.versions.toml` + `ci/Dockerfile` |
| CI runner | ubuntu-22.04 | all workflows |

CI **verifies** these versions agree (see `.github/actions/verify-versions/action.yml`).

## Folder tree

```
mediahub_v2/
├── .fvm/
│   └── fvm_config.json                # Flutter SDK pin
├── .github/
│   ├── actions/
│   │   ├── setup-flutter/action.yml
│   │   ├── setup-java/action.yml
│   │   ├── setup-python/action.yml
│   │   └── verify-versions/action.yml # CI matrix cross-check
│   └── workflows/
│       ├── _reusable-gen-check.yml
│       ├── _reusable-lint.yml
│       ├── _reusable-test.yml
│       ├── _reusable-build.yml
│       ├── _reusable-security.yml
│       ├── pr.yml                      # required checks for PRs
│       ├── main.yml                    # full suite on main
│       └── nightly.yml                # reproducibility + wheel fingerprint
├── android/
│   ├── app/
│   │   ├── build.gradle.kts           # ADR-007/012/013/016
│   │   ├── proguard-rules.pro         # ADR-011/013
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/mediahub/v2/MainActivity.kt
│   │       └── res/{values,drawable,xml}
│   ├── gradle/
│   │   ├── libs.versions.toml         # version catalog (ADR-013)
│   │   └── wrapper/gradle-wrapper.properties
│   ├── build.gradle.kts
│   ├── settings.gradle.kts
│   └── gradle.properties
├── assets/
│   └── python/mediahub/__init__.py     # bundled Python (ADR-007)
├── ci/
│   └── Dockerfile                     # pinned build image (ADR-014)
├── lib/
│   ├── main.dart                       # ADR-001/003/009
│   ├── bootstrap/bootstrap.dart        # composition root (ADR-002)
│   └── presentation/error_boundary.dart # ADR-009
├── packages/
│   ├── domain/                         # PURE DART (ADR-002)
│   │   ├── lib/
│   │   │   ├── mediahub_domain.dart
│   │   │   └── src/
│   │   │       ├── entities/hello.dart
│   │   │       ├── values/failure.dart
│   │   │       └── repositories/hello_repository.dart
│   │   ├── test/domain_test.dart
│   │   ├── analysis_options.yaml       # bans Flutter/Drift/etc.
│   │   └── pubspec.yaml
│   ├── data/
│   │   ├── lib/src/{db,dto,network,repositories}/.gitkeep
│   │   ├── test/data_test.dart
│   │   └── pubspec.yaml
│   ├── application/
│   │   ├── lib/{src,state}/.gitkeep
│   │   ├── test/application_test.dart
│   │   └── pubspec.yaml
│   ├── design_system/
│   │   ├── lib/src/{tokens,widgets}/.gitkeep
│   │   ├── test/design_system_test.dart
│   │   └── pubspec.yaml
│   ├── python_bridge/                  # ADR-008
│   │   ├── pigeons/api.dart             # Pigeon schema (single source)
│   │   ├── lib/{src,mediahub_python_bridge.dart}
│   │   ├── test/python_bridge_test.dart
│   │   └── pubspec.yaml
│   ├── sync_engine/
│   │   ├── lib/src/{queue,scheduler}/.gitkeep
│   │   ├── test/sync_engine_test.dart
│   │   └── pubspec.yaml
│   └── tooling/
│       ├── import_lint/config.yaml     # ADR-002 dependency rule
│       ├── custom_lint/.gitkeep
│       └── lib/mediahub_tooling.dart
├── python/                             # embedded Python runtime (ADR-007)
│   ├── mediahub/
│   │   ├── __init__.py
│   │   ├── api.py                       # ping() — Phase 0 contract
│   │   └── errors.py                    # PythonRuntimeError hierarchy
│   ├── tests/test_api.py                # pytest contract test (ADR-017)
│   ├── pyproject.toml                   # ruff/mypy/pytest config
│   ├── requirements.lock                # pinned runtime deps (Phase 0: empty)
│   ├── requirements-dev.txt
│   └── README.md
├── test/
│   ├── helpers/test_helpers.dart
│   ├── fakes/.gitkeep
│   ├── golden/.gitkeep
│   ├── integration/.gitkeep
│   └── widget_test.dart                 # smoke test
├── tools/
│   └── gen.sh                           # deterministic codegen entry (ADR-004)
├── analysis_options.yaml
├── melos.yaml
├── pubspec.yaml
├── .gitignore
└── README.md
```

## How to develop

```bash
# 1. Use the pinned Flutter SDK
fvm install
fvm use

# 2. Bootstrap packages (melos)
fvm dart pub global activate melos
melos bootstrap

# 3. Run code generation (deterministic; CI runs the same command)
bash tools/gen.sh

# 4. Verify
fvm flutter analyze .
fvm dart run custom_lint
bash tools/check_imports.sh
fvm flutter test
cd python && pytest -v && cd ..

# 5. Build
fvm flutter build apk --debug
```

## Phase 0 completion criteria

- [x] Complete project structure created per SAD Chapter 7
- [x] Flutter pinned via fvm (3.29.3)
- [x] Clean Architecture folders created; domain is pure Dart
- [x] `packages/domain/analysis_options.yaml` bans Flutter/Drift/Riverpod imports
- [x] AGP / Gradle / Kotlin / JDK pinned and CI-verified
- [x] Chaquopy + Python 3.11 wired (no business logic)
- [x] Pigeon schema defined; `mediahub.api.ping` contract stub
- [x] Base deps locked (no unnecessary packages)
- [x] `pubspec.lock` strategy: COMMITTED (application convention)
- [x] GitHub Actions: flutter/java/python setup + lint + analyzer + gen-check + tests + debug APK build + release APK prep
- [x] Test structure + mock strategy + base config

## Phase 0 does NOT include

- Any feature implementation
- Any UI screen
- Any Riverpod provider for actual state
- Any repository implementation
- Any database schema (Drift DB wiring is deferred)
- Any downloader / player / playlist logic

## Approval gate

Per the SAD (Chapter 17), Phase 1 implementation is **blocked** until the
ARB reviews and approves this Phase 0 foundation. Sign-off is captured as
the git tag `phase/0-approved`.
