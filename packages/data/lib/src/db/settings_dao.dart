// =============================================================================
// MediaHub v2 — SettingsDao (Feature #4: Settings)
// Authority: ADR-005 (Drift), ADR-002 (data layer)
// =============================================================================

import 'package:drift/drift.dart';
import 'media_hub_database.dart';
import 'settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<MediaHubDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Stream<List<SettingRow>> watchAll() {
    return select(settings).watch();
  }

  Future<SettingRow?> getByKey(String key) {
    return (select(settings)
      ..where((t) => t.key.equals(key))).getSingleOrNull();
  }

  Future<void> upsert(SettingsCompanion entry) {
    return into(settings).insertOnConflictUpdate(entry);
  }
}
