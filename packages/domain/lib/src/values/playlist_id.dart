// =============================================================================
// MediaHub v2 — PlaylistId value object (Feature #2: Playlists)
// Authority: ADR-002 (pure-Dart domain), ADR-009 (typed values)
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_id.freezed.dart';
part 'playlist_id.g.dart';

@freezed
abstract class PlaylistId with _$PlaylistId {
  const factory PlaylistId(String value) = _PlaylistId;

  factory PlaylistId.fromJson(Map<String, dynamic> json) =>
      _$PlaylistIdFromJson(json);

  const PlaylistId._();

  @override
  String toString() => value;
}
