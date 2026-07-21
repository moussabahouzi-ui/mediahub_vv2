// =============================================================================
// MediaHub v2 — historyProvider (Feature #3: History)
// Authority: ADR-003 (Riverpod), ADR-006 (offline-first)
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

import 'history_repository_provider.dart';

final historyProvider = StreamProvider<List<HistoryEntry>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.watchAll();
});
