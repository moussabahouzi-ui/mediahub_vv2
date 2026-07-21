// =============================================================================
// MediaHub v2 — SettingsRepositoryImpl (Feature #4: Settings)
// Authority: ADR-002 (ACL), ADR-005 (Drift), ADR-009 (Either)
// =============================================================================

import 'package:mediahub_domain/mediahub_domain.dart';

import '../db/media_hub_database.dart';
import '../db/settings_dao.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dao);

  final SettingsDao _dao;

  @override
  Future<Either<Failure, Setting>> get(String key) async {
    try {
      final row = await _dao.getByKey(key);
      if (row == null) {
        return const Left(StorageFailure(message: 'Setting not found'));
      }
      return Right(Setting(key: row.key, value: row.value));
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to fetch setting', cause: e));
    }
  }

  @override
  Future<Either<Failure, void>> set(Setting setting) async {
    try {
      await _dao.upsert(
        SettingsCompanion.insert(key: setting.key, value: setting.value),
      );
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to save setting', cause: e));
    }
  }

  @override
  Stream<List<Setting>> watchAll() {
    return _dao.watchAll().map(
      (rows) => rows
          .map((r) => Setting(key: r.key, value: r.value))
          .toList(growable: false),
    );
  }
}
