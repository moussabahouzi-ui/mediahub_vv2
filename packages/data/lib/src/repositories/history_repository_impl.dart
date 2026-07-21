// =============================================================================
// MediaHub v2 — HistoryRepositoryImpl (Feature #3: History)
// Authority: ADR-002 (ACL), ADR-005 (Drift), ADR-009 (Either)
// =============================================================================

import 'package:mediahub_domain/mediahub_domain.dart';

import '../db/history_dao.dart';
import '../db/media_hub_database.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._dao);

  final HistoryDao _dao;

  @override
  Stream<List<HistoryEntry>> watchAll() {
    return _dao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, void>> add(MediaId mediaId, Duration position) async {
    try {
      await _dao.add(mediaId.value, position.inMilliseconds);
      return const Right(null);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to add history entry', cause: e),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clear() async {
    try {
      await _dao.clear();
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to clear history', cause: e));
    }
  }

  static HistoryEntry _toDomain(HistoryEntryRow row) {
    return HistoryEntry(
      id: row.id,
      mediaId: MediaId(row.mediaId),
      playedAt: row.playedAt,
      position: Duration(milliseconds: row.positionMs),
    );
  }
}
