// =============================================================================
// MediaHub v2 — PlaylistRepository port (Feature #2: Playlists)
// Authority: ADR-002 (repository interfaces in domain), ADR-009 (Either)
// =============================================================================

import 'package:mediahub_domain/src/entities/playlist.dart';
import 'package:mediahub_domain/src/values/either.dart';
import 'package:mediahub_domain/src/values/failure.dart';
import 'package:mediahub_domain/src/values/media_id.dart';
import 'package:mediahub_domain/src/values/playlist_id.dart';

abstract interface class PlaylistRepository {
  /// Watches all playlists. Emits a new list whenever data changes.
  Stream<List<Playlist>> watchAll();

  /// Fetches a single playlist by id (including its ordered item ids).
  Future<Either<Failure, Playlist>> getById(PlaylistId id);

  /// Creates or updates a playlist. Returns Left(Failure) on error.
  Future<Either<Failure, void>> save(Playlist playlist);

  /// Adds a media item to the end of a playlist.
  Future<Either<Failure, void>> addItem(PlaylistId playlistId, MediaId mediaId);

  /// Removes a media item from a playlist by position.
  Future<Either<Failure, void>> removeItemAt(PlaylistId playlistId, int index);

  /// Deletes a playlist.
  Future<Either<Failure, void>> delete(PlaylistId id);
}
