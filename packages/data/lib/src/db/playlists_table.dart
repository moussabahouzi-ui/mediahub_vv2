// =============================================================================
// MediaHub v2 — Playlists + PlaylistItems Drift tables (Feature #2)
// Authority: ADR-005 (Drift), ADR-002 (data layer)
// =============================================================================
// Two tables:
//   - playlists:        id, name, created_at
//   - playlist_items:   playlist_id (FK), media_id, position
//
// The join table stores the ordered list of media ids per playlist.

import 'package:drift/drift.dart';

@DataClassName('PlaylistRow')
class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlaylistItemRow')
class PlaylistItems extends Table {
  TextColumn get playlistId => text()();
  TextColumn get mediaId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, position};
}
