// =============================================================================
// MediaHub v2 — Failure (typed error hierarchy)
// Authority: ADR-009 (sealed Failure + Either)
// =============================================================================
// Phase 0: minimal Failure hierarchy. Phase 1+ extends per feature.
//
// IRON LAW: Failures cross the domain boundary as VALUES, never as thrown
// exceptions. The UI pattern-matches on the sealed type.

sealed class Failure {
  const Failure({this.message, this.cause});
  final String? message;
  final Object? cause;
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.cause});
}

class StorageFailure extends Failure {
  const StorageFailure({super.message, super.cause});
}

class PythonRuntimeFailure extends Failure {
  const PythonRuntimeFailure({super.message, super.cause});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message, super.cause});
}
