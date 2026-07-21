// =============================================================================
// MediaHub v2 — HistoryEntry entity (Feature #3: History)
// Authority: ADR-002 (pure-Dart domain), ADR-004 (freezed codegen)
// =============================================================================
// Records that a media item was played at a certain time, up to a certain
// position. Used to populate the History screen and to support "resume
// playback" in Phase 2.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mediahub_domain/src/values/media_id.dart';

part 'history_entry.freezed.dart';
part 'history_entry.g.dart';

@freezed
abstract class HistoryEntry with _$HistoryEntry {
  const factory HistoryEntry({
    required int id,
    required MediaId mediaId,
    required DateTime playedAt,
    required Duration position,
  }) = _HistoryEntry;

  factory HistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$HistoryEntryFromJson(json);
}
