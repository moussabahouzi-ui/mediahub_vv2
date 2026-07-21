// =============================================================================
// MediaHub v2 — HistoryRepository port (Feature #3: History)
// Authority: ADR-002, ADR-009
// =============================================================================

import 'package:mediahub_domain/src/entities/history_entry.dart';
import 'package:mediahub_domain/src/values/either.dart';
import 'package:mediahub_domain/src/values/failure.dart';
import 'package:mediahub_domain/src/values/media_id.dart';

abstract interface class HistoryRepository {
  /// Watches all history entries (newest first).
  Stream<List<HistoryEntry>> watchAll();

  /// Adds a history entry. Returns Left(Failure) on error.
  Future<Either<Failure, void>> add(MediaId mediaId, Duration position);

  /// Clears all history. Returns Left(Failure) on error.
  Future<Either<Failure, void>> clear();
}
