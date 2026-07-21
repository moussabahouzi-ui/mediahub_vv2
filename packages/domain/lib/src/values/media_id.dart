// =============================================================================
// MediaHub v2 — MediaId value object
// Authority: ADR-002 (pure-Dart domain), ADR-009 (typed values)
// =============================================================================
// A strongly-typed identifier for a MediaItem. Using a dedicated value object
// (instead of a raw String) prevents accidental mixing of MediaId with other
// string identifiers (e.g. PlaylistId, UserId) — a common source of bugs.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_id.freezed.dart';
part 'media_id.g.dart';

@freezed
abstract class MediaId with _$MediaId {
  const factory MediaId(String value) = _MediaId;

  factory MediaId.fromJson(Map<String, dynamic> json) =>
      _$MediaIdFromJson(json);

  const MediaId._();

  @override
  String toString() => value;
}
