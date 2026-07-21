// =============================================================================
// MediaHub v2 — HistoryDao (Feature #3: History)
// Authority: ADR-005 (Drift), ADR-002 (data layer)
// =============================================================================

import 'package:drift/drift.dart';
import 'media_hub_database.dart';
import 'history_entries_table.dart';

part 'history_dao.g.dart';

@DriftAccessor(tables: [HistoryEntries])
class HistoryDao extends DatabaseAccessor<MediaHubDatabase>
    with _$HistoryDaoMixin {
  HistoryDao(super.db);

  /// Watches all history entries (newest first).
  Stream<List<HistoryEntryRow>> watchAll() {
    return (select(historyEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])).watch();
  }

  /// Adds a history entry.
  Future<void> add(String mediaId, int positionMs) {
    return into(historyEntries).insert(
      HistoryEntriesCompanion.insert(
        mediaId: mediaId,
        playedAt: Value(DateTime.now().toUtc()),
        positionMs: Value(positionMs),
      ),
    );
  }

  /// Clears all history.
  Future<int> clear() {
    return delete(historyEntries).go();
  }
}
