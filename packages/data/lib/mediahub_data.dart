// =============================================================================
// MediaHub v2 — data package public surface
// Authority: ADR-002 (Anti-Corruption Layer lives in data)
// =============================================================================
// Feature #1 (Media Library): MediaHubDatabase, MediaRepositoryImpl
// Feature #2 (Playlists):    PlaylistRepositoryImpl
// Feature #3 (History):      HistoryRepositoryImpl
// Feature #4 (Settings):     SettingsRepositoryImpl

export 'src/db/media_hub_database.dart';
export 'src/repositories/history_repository_impl.dart';
export 'src/repositories/media_repository_impl.dart';
export 'src/repositories/playlist_repository_impl.dart';
export 'src/repositories/settings_repository_impl.dart';
