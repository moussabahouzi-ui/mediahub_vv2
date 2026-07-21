// =============================================================================
// MediaHub v2 — SettingsRepository port (Feature #4: Settings)
// Authority: ADR-002, ADR-009
// =============================================================================

import 'package:mediahub_domain/src/entities/setting.dart';
import 'package:mediahub_domain/src/values/either.dart';
import 'package:mediahub_domain/src/values/failure.dart';

abstract interface class SettingsRepository {
  /// Gets a setting by key. Returns Left(StorageFailure) if not found.
  Future<Either<Failure, Setting>> get(String key);

  /// Sets a setting. Returns Left(Failure) on error.
  Future<Either<Failure, void>> set(Setting setting);

  /// Watches all settings.
  Stream<List<Setting>> watchAll();
}
