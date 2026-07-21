// =============================================================================
// MediaHub v2 — MediaItem entity (Feature #1: Media Library)
// Authority: ADR-002 (pure-Dart domain), ADR-004 (freezed codegen),
//            ADR-009 (typed values)
// =============================================================================
// The core domain entity for the media catalogue. A MediaItem represents
// any playable media (local file, remote stream, podcast episode, etc.).
//
// Design notes:
//   - `id` is a MediaId value object (strongly typed).
//   - `source` is a URI string — local file path or remote URL. Phase 2+
//     may introduce a MediaSource value object with kind + url.
//   - `duration` is a Dart Duration (stored as ms in the data layer).
//   - `createdAt` is the time the item was added to the local catalogue
//     (NOT the publication date — that's a Phase 2 metadata concern).

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mediahub_domain/src/values/media_id.dart';

part 'media_item.freezed.dart';
part 'media_item.g.dart';

@freezed
abstract class MediaItem with _$MediaItem {
  const factory MediaItem({
    required MediaId id,
    required String title,
    required Duration duration,
    required String source,
    required DateTime createdAt,
  }) = _MediaItem;

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);
}
