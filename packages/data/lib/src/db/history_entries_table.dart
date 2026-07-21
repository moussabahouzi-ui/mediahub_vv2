// =============================================================================
// MediaHub v2 — HistoryEntries Drift table (Feature #3: History)
// Authority: ADR-005 (Drift), ADR-002 (data layer)
// =============================================================================

import 'package:drift/drift.dart';

@DataClassName('HistoryEntryRow')
class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mediaId => text()();
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
}
