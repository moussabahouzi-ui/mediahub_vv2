// =============================================================================
// MediaHub v2 — MediaRepository port (Feature #1: Media Library)
// Authority: ADR-002 (repository interfaces in domain), ADR-005 (Drift-backed),
//            ADR-009 (Either<Failure, T> for fallible operations)
// =============================================================================
// The repository port for the media catalogue. Declared in the domain;
// implemented in the data layer (MediaRepositoryImpl using Drift).
//
// Design notes (offline-first — ADR-006):
//   - `watchAll()` returns a raw Stream<List<MediaItem>>, NOT
//     Either<Failure, Stream<...>>. Drift streams don't fail per-emission;
//     errors surface as Stream errors and are caught by the Riverpod
//     provider, which converts them to AsyncValue.error.
//   - `getById()` and `save()` return Either<Failure, T> because they are
//     one-shot operations where the failure mode is actionable (the UI
//     can pattern-match on the Failure subclass).

import 'package:mediahub_domain/src/entities/media_item.dart';
import 'package:mediahub_domain/src/values/either.dart';
import 'package:mediahub_domain/src/values/failure.dart';
import 'package:mediahub_domain/src/values/media_id.dart';

abstract interface class MediaRepository {
  /// Watches all media items in the catalogue. Emits a new list whenever
  /// the underlying data changes (reactive — backed by Drift's watch()).
  Stream<List<MediaItem>> watchAll();

  /// Fetches a single media item by id. Returns Left(Failure) on miss/error.
  Future<Either<Failure, MediaItem>> getById(MediaId id);

  /// Saves (inserts or updates) a media item. Returns Left(Failure) on error.
  Future<Either<Failure, void>> save(MediaItem item);
}
