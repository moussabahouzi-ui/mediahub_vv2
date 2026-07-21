// =============================================================================
// MediaHub v2 — Settings Drift table (Feature #4: Settings)
// Authority: ADR-005 (Drift), ADR-002 (data layer)
// =============================================================================
// Simple key-value store. PK = key.

import 'package:drift/drift.dart';

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
