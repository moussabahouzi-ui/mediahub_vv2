# MediaHub v2 — Python sources

This directory contains the Python source code that is **bundled inside the
APK** via Chaquopy (ADR-007) and called from Flutter via Pigeon-generated
typed bindings (ADR-008).

## Layout

```
python/
├── mediahub/
│   ├── __init__.py     # package marker, version
│   ├── api.py          # public API surface — mirrors Pigeon schema
│   └── errors.py       # PythonRuntimeError hierarchy
├── tests/
│   └── test_api.py     # pytest host-side contract tests (ADR-017)
├── pyproject.toml      # project metadata + tooling config
├── requirements.lock   # pinned runtime deps (Phase 0: empty)
└── requirements-dev.txt # host-only dev deps (pytest, ruff, mypy, pip-audit)
```

## The IPC contract

The Pigeon schema at `packages/python_bridge/pigeons/api.dart` is the
**single source of truth** for the Flutter ↔ Python interface. Both sides
regenerate from it:

- Dart bindings → `packages/python_bridge/lib/src/messages.g.dart`
- Kotlin adapter → `packages/python_bridge/android/PythonApi.kt` (then
  copied into `android/app/src/main/kotlin/com/mediahub/v2/python/`)

The Kotlin adapter calls into `mediahub.api.ping` (Phase 0) and
marshals the response back into the Pigeon `PingResponse` type.

## Reproducibility (ADR-014)

- All runtime deps MUST be pinned in `requirements.lock` with sha256 hashes.
- The pinned Docker CI image (ADR-014) pre-warms wheels for arm64-v8a,
  armeabi-v7a, and x86_64.
- A wheel-fingerprint check (ADR-015) detects drift between the lockfile
  and the wheels bundled into the APK.

## Defensive boundary (ADR-008)

Every public function in `mediahub/api.py` validates its inputs at the
boundary. Even though the Kotlin adapter is the only caller, defensive
validation is mandatory — a Pigeon schema change between Dart and Python
must surface as a `PythonRuntimeError`, not as a corrupted state deep in
a pipeline.
