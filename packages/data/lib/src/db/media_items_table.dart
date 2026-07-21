// =============================================================================
// MediaHub v2 — MediaItems Drift table (Feature #1: Media Library)
// Authority: ADR-005 (Drift), ADR-002 (data layer + ACL)
// =============================================================================
// Drift table definition for the media catalogue. Column types map to
// SQLite storage; the DAO + repository impl translate to/from domain
// MediaItem entities (Anti-Corruption Layer — ADR-002 Chapter 8).

import 'package:drift/drift.dart';

/// Drift table for media items.
///
/// Storage mapping:
///   - id          TEXT PRIMARY KEY  (MediaId.value)
///   - title       TEXT
///   - duration_ms INTEGER            (Duration.inMilliseconds)
///   - source      TEXT                (URI string)
///   - created_at  INTEGER            (DateTime.millisecondsSinceEpoch, UTC)
///
/// `@DataClassName('MediaItemRow')` renames the generated data class from
/// the default `MediaItem` to `MediaItemRow` to avoid a name collision with
/// the domain entity `MediaItem` (ADR-002 ACL — the two types must never be
/// confused; the row class is a data-layer concern only).
@DataClassName('MediaItemRow')
class MediaItems extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get durationMs => integer()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
