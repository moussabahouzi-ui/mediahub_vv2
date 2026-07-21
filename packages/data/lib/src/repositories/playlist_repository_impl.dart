// =============================================================================
// MediaHub v2 — PlaylistRepositoryImpl (Feature #2: Playlists)
// Authority: ADR-002 (ACL), ADR-005 (Drift), ADR-009 (Either)
// =============================================================================
// Maps between Drift rows (PlaylistRow + PlaylistItemRow) and the domain
// Playlist entity. Errors are caught and mapped to StorageFailure.

import 'package:drift/drift.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

import '../db/media_hub_database.dart';
import '../db/playlists_dao.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl(this._dao);

  final PlaylistsDao _dao;

  @override
  Stream<List<Playlist>> watchAll() {
    return _dao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, Playlist>> getById(PlaylistId id) async {
    try {
      final row = await _dao.getById(id.value);
      if (row == null) {
        return const Left(StorageFailure(message: 'Playlist not found'));
      }
      final items = await _dao.getItems(id.value);
      return Right(_toDomainWithItems(row, items));
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to fetch playlist', cause: e),
      );
    }
  }

  @override
  Future<Either<Failure, void>> save(Playlist playlist) async {
    try {
      await _dao.upsertPlaylist(
        PlaylistsCompanion.insert(
          id: playlist.id.value,
          name: playlist.name,
          createdAt: Value(playlist.createdAt),
        ),
      );
      await _dao.replaceItems(
        playlist.id.value,
        playlist.itemIds.map((m) => m.value).toList(),
      );
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to save playlist', cause: e));
    }
  }

  @override
  Future<Either<Failure, void>> addItem(
    PlaylistId playlistId,
    MediaId mediaId,
  ) async {
    try {
      await _dao.addItem(playlistId.value, mediaId.value);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to add item', cause: e));
    }
  }

  @override
  Future<Either<Failure, void>> removeItemAt(
    PlaylistId playlistId,
    int index,
  ) async {
    try {
      final items = await _dao.getItems(playlistId.value);
      if (index < 0 || index >= items.length) {
        return const Left(StorageFailure(message: 'Index out of range'));
      }
      // Delete the item at the given position and re-number remaining items.
      final remaining = items.where((_) => true).toList();
      remaining.removeAt(index);
      await _dao.replaceItems(
        playlistId.value,
        remaining.map((e) => e.mediaId).toList(),
      );
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to remove item', cause: e));
    }
  }

  @override
  Future<Either<Failure, void>> delete(PlaylistId id) async {
    try {
      await _dao.deletePlaylist(id.value);
      return const Right(null);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to delete playlist', cause: e),
      );
    }
  }

  // ── ACL mappers ────────────────────────────────────────────────────────────

  static Playlist _toDomain(PlaylistRow row) {
    return Playlist(
      id: PlaylistId(row.id),
      name: row.name,
      itemIds: const [], // watchAll() doesn't load items; use getById().
      createdAt: row.createdAt,
    );
  }

  static Playlist _toDomainWithItems(
    PlaylistRow row,
    List<PlaylistItemRow> items,
  ) {
    return Playlist(
      id: PlaylistId(row.id),
      name: row.name,
      itemIds: items.map((e) => MediaId(e.mediaId)).toList(),
      createdAt: row.createdAt,
    );
  }
}
