// =============================================================================
// MediaHub v2 — MediaItems DAO (Feature #1: Media Library)
// Authority: ADR-005 (Drift), ADR-002 (data layer)
// =============================================================================
// Data-access object for the MediaItems table. Exposes a reactive `watchAll()`
// stream backed by Drift. The repository impl consumes this and maps to domain
// entities.

import 'package:drift/drift.dart';
import 'media_hub_database.dart';
import 'media_items_table.dart';

part 'media_items_dao.g.dart';

@DriftAccessor(tables: [MediaItems])
class MediaItemsDao extends DatabaseAccessor<MediaHubDatabase>
    with _$MediaItemsDaoMixin {
  MediaItemsDao(super.db);

  /// Reactive stream of all media items, ordered by createdAt descending
  /// (newest first — the natural order for a media library).
  Stream<List<MediaItemRow>> watchAll() {
    return (select(mediaItems)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  /// Fetches a single row by id. Returns null if not found.
  Future<MediaItemRow?> getById(String id) {
    return (select(mediaItems)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Inserts or replaces a media item row (upsert by primary key).
  Future<void> upsert(MediaItemsCompanion entry) {
    return into(mediaItems).insertOnConflictUpdate(entry);
  }
}
