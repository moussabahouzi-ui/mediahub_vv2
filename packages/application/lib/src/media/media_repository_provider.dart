// =============================================================================
// MediaHub v2 — mediaRepositoryProvider (Feature #1: Media Library)
// Authority: ADR-002 (application layer), ADR-003 (Riverpod)
// =============================================================================
// Declares the MediaRepository provider. The default implementation throws
// UnimplementedError; the composition root (lib/bootstrap/) overrides it with
// the real MediaRepositoryImpl.
//
// This pattern respects the ADR-002 dependency rule: the application layer
// depends on the domain (for the MediaRepository port), NOT on the data layer.
// The data-layer impl is injected at the composition root.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

/// Provider for the MediaRepository port.
///
/// Throws [UnimplementedError] by default. Override in `ProviderScope`:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     mediaRepositoryProvider.overrideWithValue(
///       MediaRepositoryImpl(database.mediaItemsDao),
///     ),
///   ],
///   child: ...
/// )
/// ```
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  throw UnimplementedError(
    'mediaRepositoryProvider must be overridden in bootstrap (lib/bootstrap/). '
    'See ADR-002 §6.3 (composition root).',
  );
});
