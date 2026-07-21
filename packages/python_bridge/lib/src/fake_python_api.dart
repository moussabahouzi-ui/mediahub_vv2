// =============================================================================
// MediaHub v2 — FakePythonApi (test double) (Feature #5)
// Authority: ADR-017 (contract tests against both real + fake)
// =============================================================================
// An in-memory fake of the Pigeon `PythonApi` for testing. Returns canned
// responses; throws on demand to test error paths.
//
// Pigeon v22 generates `PythonApi` as a concrete class (not abstract), so
// the fake extends it and overrides the `ping` + `verifyRuntime` methods.

import 'messages.g.dart';

class FakePythonApi extends PythonApi {
  FakePythonApi({
    this.pingResponse,
    this.verifyRuntimeResponse,
    this.shouldThrow = false,
  });

  final PingResponse? pingResponse;
  final VerifyRuntimeResponse? verifyRuntimeResponse;
  final bool shouldThrow;

  @override
  Future<PingResponse> ping(PingRequest request) async {
    if (shouldThrow) {
      throw Exception('FakePythonApi: simulated failure');
    }
    return pingResponse ?? PingResponse(message: 'pong', timestampMs: 0);
  }

  @override
  Future<VerifyRuntimeResponse> verifyRuntime(
    VerifyRuntimeRequest request,
  ) async {
    if (shouldThrow) {
      throw Exception('FakePythonApi: simulated failure');
    }
    return verifyRuntimeResponse ??
        VerifyRuntimeResponse(
          pythonVersion: '3.11.0',
          mediahubVersion: '0.1.0',
          timestampMs: 0,
        );
  }
}
