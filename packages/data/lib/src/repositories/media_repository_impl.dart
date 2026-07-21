// =============================================================================
// MediaHub v2 — MediaRepositoryImpl (Feature #1: Media Library)
// Authority: ADR-002 (Anti-Corruption Layer), ADR-005 (Drift), ADR-009 (Either)
// =============================================================================
// The data-layer implementation of the domain's MediaRepository port.
// Translates between Drift rows (MediaItemRow) and domain entities (MediaItem)
// at the boundary — no Drift type ever crosses into the application/domain.
//
// Error handling (ADR-009): Drift exceptions are caught and mapped to typed
// Failures. The UI pattern-matches on the Failure subclass (ADR-009).

import 'package:drift/drift.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

import '../db/media_hub_database.dart';
import '../db/media_items_dao.dart';

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl(this._dao);

  final MediaItemsDao _dao;

  @override
  Stream<List<MediaItem>> watchAll() {
    // Drift streams don't fail per-emission; errors surface as stream errors.
    // The application-layer provider catches them via AsyncValue.error.
    return _dao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, MediaItem>> getById(MediaId id) async {
    try {
      final row = await _dao.getById(id.value);
      if (row == null) {
        return const Left(StorageFailure(message: 'Media item not found'));
      }
      return Right(_toDomain(row));
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to fetch media item', cause: e),
      );
    }
  }

  @override
  Future<Either<Failure, void>> save(MediaItem item) async {
    try {
      await _dao.upsert(_toCompanion(item));
      return const Right(null);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to save media item', cause: e),
      );
    }
  }

  // ── ACL mappers (ADR-002 Chapter 8) ───────────────────────────────────────
  // These are the ONLY place where Drift rows ↔ domain entities are translated.

  static MediaItem _toDomain(MediaItemRow row) {
    return MediaItem(
      id: MediaId(row.id),
      title: row.title,
      duration: Duration(milliseconds: row.durationMs),
      source: row.source,
      createdAt: row.createdAt,
    );
  }

  static MediaItemsCompanion _toCompanion(MediaItem item) {
    return MediaItemsCompanion.insert(
      id: item.id.value,
      title: item.title,
      durationMs: item.duration.inMilliseconds,
      source: item.source,
      createdAt: Value(item.createdAt),
    );
  }
}
