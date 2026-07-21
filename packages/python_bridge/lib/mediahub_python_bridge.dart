// =============================================================================
// MediaHub v2 — python_bridge public surface (Feature #5)
// Authority: ADR-008 (typed IPC)
// =============================================================================
// Feature #5: exports the Pigeon-generated API + the typed client wrapper
// + the fake for tests.

export 'src/fake_python_api.dart' show FakePythonApi;
export 'src/messages.g.dart'
    show
        PythonApi,
        PingRequest,
        PingResponse,
        VerifyRuntimeRequest,
        VerifyRuntimeResponse;
export 'src/python_api_client.dart' show PythonApiClient;
