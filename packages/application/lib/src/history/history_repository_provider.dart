// =============================================================================
// MediaHub v2 — historyRepositoryProvider (Feature #3: History)
// Authority: ADR-002 (application layer), ADR-003 (Riverpod)
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  throw UnimplementedError(
    'historyRepositoryProvider must be overridden in bootstrap (lib/bootstrap/).',
  );
});
