// =============================================================================
// MediaHub v2 — PythonApiClient (Feature #5: Embedded Python Runtime)
// Authority: ADR-008 (typed IPC), ADR-009 (Either + Failure mapping)
// =============================================================================
// Wraps the Pigeon-generated `PythonApi` to provide a typed, error-handling
// surface for the rest of the app. Catches `PlatformException` and maps it
// to `PythonRuntimeFailure`.
//
// Usage:
//   final client = PythonApiClient();
//   final result = await client.ping('hello');
//   switch (result) {
//     case Left(:final value): // PythonRuntimeFailure
//     case Right(:final value): // PingResponse
//   }

import 'package:flutter/services.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

import 'messages.g.dart';

class PythonApiClient {
  PythonApiClient([PythonApi? api]) : _api = api ?? PythonApi();

  final PythonApi _api;

  /// Smoke call — returns "pong" + timestamp.
  Future<Either<Failure, PingResponse>> ping(String? message) async {
    try {
      final response = await _api.ping(PingRequest(message: message));
      return Right(response);
    } on PlatformException catch (e) {
      return Left(
        PythonRuntimeFailure(
          message: 'ping failed: ${e.code} ${e.message}',
          cause: e.details,
        ),
      );
    } catch (e) {
      return Left(
        PythonRuntimeFailure(message: 'ping failed unexpectedly', cause: e),
      );
    }
  }

  /// Verifies the embedded Python runtime is alive and the `mediahub`
  /// module is importable. Returns the Python + mediahub versions.
  Future<Either<Failure, VerifyRuntimeResponse>> verifyRuntime() async {
    try {
      final response = await _api.verifyRuntime(VerifyRuntimeRequest());
      return Right(response);
    } on PlatformException catch (e) {
      return Left(
        PythonRuntimeFailure(
          message: 'verifyRuntime failed: ${e.code} ${e.message}',
          cause: e.details,
        ),
      );
    } catch (e) {
      return Left(
        PythonRuntimeFailure(
          message: 'verifyRuntime failed unexpectedly',
          cause: e,
        ),
      );
    }
  }
}
