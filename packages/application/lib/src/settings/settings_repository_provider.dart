// =============================================================================
// MediaHub v2 — settingsRepositoryProvider (Feature #4: Settings)
// Authority: ADR-002, ADR-003
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError(
    'settingsRepositoryProvider must be overridden in bootstrap.',
  );
});
