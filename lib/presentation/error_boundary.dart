// =============================================================================
// MediaHub v2 — ErrorBoundary widget
// Authority: ADR-009 (typed failures + ErrorBoundary)
// =============================================================================
// Feature #1: minimal implementation. Installs a global ErrorWidget.builder
// that renders a recovery UI when an uncaught error reaches the framework.
// Phase 2+: typed Failure pattern matching + Sentry reporting (ADR-010).

import 'package:flutter/material.dart';

/// Wraps the app root. Installs [ErrorWidget.builder] so that framework
/// errors during build/layout/paint render a recovery UI instead of red
/// error text in release builds.
///
/// The error handler is installed at most once per process (idempotent).
/// Tests can call [ErrorBoundary.resetForTesting] to reset the flag
/// between test cases.
class ErrorBoundary extends StatelessWidget {
  const ErrorBoundary({super.key, required this.child});

  final Widget child;

  static bool _installed = false;
  static ErrorWidgetBuilder? _originalBuilder;

  @visibleForTesting
  static void resetForTesting() {
    _installed = false;
    if (_originalBuilder != null) {
      ErrorWidget.builder = _originalBuilder!;
      _originalBuilder = null;
    }
  }

  void _installErrorHandler() {
    if (_installed) return;
    _installed = true;
    _originalBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Phase 1: forward to Flutter's default reporter (Phase 2+: Sentry).
      FlutterError.reportError(details);
      return _RecoveryErrorWidget(details: details);
    };
  }

  @override
  Widget build(BuildContext context) {
    _installErrorHandler();
    return child;
  }
}

/// The widget Flutter renders when a build/layout error occurs.
class _RecoveryErrorWidget extends StatelessWidget {
  const _RecoveryErrorWidget({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xFF1A1A18),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.white70),
              SizedBox(height: 12),
              Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'The error has been reported. Please restart the app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
