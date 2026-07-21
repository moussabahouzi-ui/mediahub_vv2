// =============================================================================
// MediaHub v2 — Pigeon schema for Flutter <-> Python IPC
// Authority: ADR-008 (typed bindings, no MethodChannel strings in app code)
// =============================================================================
// Run:  dart run pigeon --input pigeons/api.dart
// Output: lib/src/messages.g.dart (Dart) + android/PythonApi.kt (Kotlin adapter)
//
// Phase 0: a single `ping` method that proves the IPC path end-to-end.
// Phase 2 Feature #5: added `verifyRuntime` — proves the Chaquopy-embedded
//   Python runtime boots and the mediahub module is importable.
// Phase 2 Feature #9: will add transcribe/embed/tag methods.

import 'package:pigeon/pigeon.dart';

// ── Configuration ────────────────────────────────────────────────────────────
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: 'android/PythonApi.kt',
    kotlinOptions: KotlinOptions(package: 'com.mediahub.v2.python'),
    dartPackageName: 'mediahub_python_bridge',
  ),
)
// ── Phase 0 schema ───────────────────────────────────────────────────────────
class PingRequest {
  String? message;
}

class PingResponse {
  String? message;
  int? timestampMs;
}

// ── Phase 2 Feature #5 schema ────────────────────────────────────────────────

class VerifyRuntimeRequest {
  // Pigeon requires at least one field to generate encode/decode.
  // This sentinel is ignored by the Python side; it exists only so the
  // codec can serialise the request.
  String? sentinel;
}

class VerifyRuntimeResponse {
  String? pythonVersion;
  String? mediahubVersion;
  int? timestampMs;
}

@HostApi()
abstract class PythonApi {
  /// Phase 0 smoke call. Returns "pong" + a timestamp.
  @async
  PingResponse ping(PingRequest request);

  /// Phase 2 Feature #5: verifies the embedded Python runtime is alive
  /// and the `mediahub` module is importable. Returns the Python version
  /// + mediahub package version + a timestamp.
  @async
  VerifyRuntimeResponse verifyRuntime(VerifyRuntimeRequest request);
}
