// =============================================================================
// MediaHub v2 — Playlist entity (Feature #2: Playlists)
// Authority: ADR-002 (pure-Dart domain), ADR-004 (freezed codegen)
// =============================================================================
// A Playlist is a named, ordered collection of MediaItems. The ordering is
// stored as a list of MediaIds in the domain entity; the data layer persists
// it via a join table with a `position` column (ADR-005).

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mediahub_domain/src/values/media_id.dart';
import 'package:mediahub_domain/src/values/playlist_id.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({
    required PlaylistId id,
    required String name,
    required List<MediaId> itemIds,
    required DateTime createdAt,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
}
