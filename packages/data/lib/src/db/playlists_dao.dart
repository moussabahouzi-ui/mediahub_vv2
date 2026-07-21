// =============================================================================
// MediaHub v2 — PlaylistsDao (Feature #2: Playlists)
// Authority: ADR-005 (Drift), ADR-002 (data layer)
// =============================================================================

import 'package:drift/drift.dart';
import 'media_hub_database.dart';
import 'playlists_table.dart';

part 'playlists_dao.g.dart';

@DriftAccessor(tables: [Playlists, PlaylistItems])
class PlaylistsDao extends DatabaseAccessor<MediaHubDatabase>
    with _$PlaylistsDaoMixin {
  PlaylistsDao(super.db);

  /// Watches all playlists (without their items — items are loaded on demand).
  Stream<List<PlaylistRow>> watchAll() {
    return (select(playlists)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  /// Fetches a single playlist row by id.
  Future<PlaylistRow?> getById(String id) {
    return (select(playlists)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watches the ordered media ids for a playlist.
  Stream<List<PlaylistItemRow>> watchItems(String playlistId) {
    return (select(playlistItems)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  /// Fetches the ordered media ids for a playlist (one-shot).
  Future<List<PlaylistItemRow>> getItems(String playlistId) {
    return (select(playlistItems)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
  }

  /// Inserts or updates a playlist row.
  Future<void> upsertPlaylist(PlaylistsCompanion entry) {
    return into(playlists).insertOnConflictUpdate(entry);
  }

  /// Replaces all items for a playlist (deletes existing, inserts new).
  Future<void> replaceItems(String playlistId, List<String> mediaIds) async {
    await (delete(playlistItems)
      ..where((t) => t.playlistId.equals(playlistId))).go();
    for (var i = 0; i < mediaIds.length; i++) {
      await into(playlistItems).insert(
        PlaylistItemsCompanion.insert(
          playlistId: playlistId,
          mediaId: mediaIds[i],
          position: i,
        ),
      );
    }
  }

  /// Adds a single media item to the end of a playlist.
  Future<void> addItem(String playlistId, String mediaId) async {
    final count =
        await (playlistItems.selectOnly()
              ..addColumns([playlistItems.position.max()])
              ..where(playlistItems.playlistId.equals(playlistId)))
            .getSingle();
    final nextPos = count.read(playlistItems.position.max()) ?? -1;
    await into(playlistItems).insert(
      PlaylistItemsCompanion.insert(
        playlistId: playlistId,
        mediaId: mediaId,
        position: nextPos + 1,
      ),
    );
  }

  /// Deletes a playlist and all its items.
  Future<void> deletePlaylist(String id) async {
    await (delete(playlistItems)..where((t) => t.playlistId.equals(id))).go();
    await (delete(playlists)..where((t) => t.id.equals(id))).go();
  }
}
