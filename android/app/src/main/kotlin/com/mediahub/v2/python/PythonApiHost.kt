// =============================================================================
// MediaHub v2 — PythonApiHost.kt (Feature #5: Embedded Python Runtime)
// Authority: ADR-007 (Chaquopy), ADR-008 (Pigeon typed IPC), ADR-009 (Failure mapping)
// =============================================================================
// Implements the Pigeon-generated `PythonApi` interface. Each method calls
// into the embedded Python runtime via Chaquopy's `PyObject` API.
//
// Error handling (ADR-009): all `Throwable`s are caught and wrapped into
// `FlutterError(code, message, details)`, which Pigeon converts to a
// `PlatformException` on the Dart side. The Dart-side `PythonApiClient`
// then maps the PlatformException to a `PythonRuntimeFailure`.
//
// Registered in `MainActivity.configureFlutterEngine()`.

package com.mediahub.v2.python

import com.chaquo.python.PyException
import com.chaquo.python.PyObject
import com.chaquo.python.Python
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger

class PythonApiHost : PythonApi {

    private val py: Python by lazy { Python.getInstance() }
    private val mediahubModule: PyObject by lazy {
        try {
            py.getModule("mediahub")
        } catch (e: PyException) {
            throw FlutterError(
                "python_module_not_found",
                "Failed to import 'mediahub' Python module: ${e.message}",
                null
            )
        }
    }

    override fun ping(request: PingRequest): PingResponse {
        return try {
            val result = mediahubModule.callAttr("ping", request.message)
            val resultMap = result.asMap()
            PingResponse(
                message = resultMap["message"]?.toString(),
                timestampMs = (resultMap["timestampMs"] as? Number)?.toLong()?.toInt()
            )
        } catch (e: PyException) {
            throw FlutterError(
                "python_ping_failed",
                "ping() failed: ${e.message}",
                null
            )
        }
    }

    override fun verifyRuntime(request: VerifyRuntimeRequest): VerifyRuntimeResponse {
        return try {
            val result = mediahubModule.callAttr("verify_runtime")
            val resultMap = result.asMap()
            VerifyRuntimeResponse(
                pythonVersion = resultMap["pythonVersion"]?.toString(),
                mediahubVersion = resultMap["mediahubVersion"]?.toString(),
                timestampMs = (resultMap["timestampMs"] as? Number)?.toLong()?.toInt()
            )
        } catch (e: PyException) {
            throw FlutterError(
                "python_verify_failed",
                "verify_runtime() failed: ${e.message}",
                null
            )
        }
    }

    companion object {
        /// Registers this host with the Flutter engine.
        /// Called from `MainActivity.configureFlutterEngine()`.
        fun register(messenger: BinaryMessenger) {
            PythonApi.setUp(messenger, PythonApiHost())
        }
    }
}
