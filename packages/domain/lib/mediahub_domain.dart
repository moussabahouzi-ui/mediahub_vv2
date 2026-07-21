// =============================================================================
// MediaHub v2 — domain package public surface
// Authority: ADR-002 (Clean Architecture), ADR-009 (typed Failure)
// =============================================================================
// Feature #1 (Media Library): MediaItem, MediaId, MediaRepository
// Feature #2 (Playlists):    Playlist, PlaylistId, PlaylistRepository
// Feature #3 (History):      HistoryEntry, HistoryRepository
// Feature #4 (Settings):     Setting, SettingsRepository

export 'src/entities/history_entry.dart';
export 'src/entities/media_item.dart';
export 'src/entities/playlist.dart';
export 'src/entities/setting.dart';
export 'src/repositories/history_repository.dart';
export 'src/repositories/media_repository.dart';
export 'src/repositories/playlist_repository.dart';
export 'src/repositories/settings_repository.dart';
export 'src/values/either.dart';
export 'src/values/failure.dart';
export 'src/values/media_id.dart';
export 'src/values/playlist_id.dart';
