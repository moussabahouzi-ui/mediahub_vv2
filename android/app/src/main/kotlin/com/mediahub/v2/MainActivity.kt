// =============================================================================
// MediaHub v2 — MainActivity.kt
// Authority: ADR-001 (Flutter), ADR-007 (Chaquopy), ADR-008 (Pigeon IPC),
//            ADR-013 (Kotlin pinned)
// =============================================================================
// Phase 2 Feature #5: registers the Pigeon-generated `PythonApi` with the
// Flutter engine, wiring Flutter ↔ Python IPC via the `PythonApiHost`.

package com.mediahub.v2

import com.mediahub.v2.python.PythonApiHost
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register the Python ↔ Flutter IPC bridge (ADR-008).
        // The PythonApiHost calls into the Chaquopy-embedded Python runtime.
        PythonApiHost.register(flutterEngine.dartExecutor.binaryMessenger)
    }
}
