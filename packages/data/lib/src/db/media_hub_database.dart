// =============================================================================
// MediaHub v2 — MediaHub Drift database (Features #1–#4)
// Authority: ADR-005 (Drift + versioned migrations), ADR-014 (reproducibility)
// =============================================================================
// schemaVersion = 4 (Feature #4 adds Settings table).

import 'package:drift/drift.dart';
import 'history_dao.dart';
import 'history_entries_table.dart';
import 'media_items_dao.dart';
import 'media_items_table.dart';
import 'playlists_dao.dart';
import 'playlists_table.dart';
import 'settings_dao.dart';
import 'settings_table.dart';

part 'media_hub_database.g.dart';

@DriftDatabase(
  tables: [MediaItems, Playlists, PlaylistItems, HistoryEntries, Settings],
  daos: [MediaItemsDao, PlaylistsDao, HistoryDao, SettingsDao],
)
class MediaHubDatabase extends _$MediaHubDatabase {
  MediaHubDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _seedSampleData();
        await _seedDefaultSettings();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(playlists);
          await m.createTable(playlistItems);
        }
        if (from < 3) {
          await m.createTable(historyEntries);
        }
        if (from < 4) {
          await m.createTable(settings);
          await _seedDefaultSettings();
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _seedSampleData() async {
    final now = DateTime.now().toUtc();
    final samples = [
      (
        id: 'sample-001',
        title: 'Introduction to MediaHub',
        durationMs: 222000,
        source: 'https://example.com/intro.mp3',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      (
        id: 'sample-002',
        title: 'Architecture Deep Dive',
        durationMs: 1845000,
        source: 'https://example.com/architecture.mp4',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      (
        id: 'sample-003',
        title: 'Flutter Weekly Recap',
        durationMs: 615000,
        source: 'https://example.com/flutter-weekly.mp3',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
    for (final s in samples) {
      await into(mediaItems).insert(
        MediaItemsCompanion.insert(
          id: s.id,
          title: s.title,
          durationMs: s.durationMs,
          source: s.source,
          createdAt: Value(s.createdAt),
        ),
      );
    }
  }

  /// Seeds default settings on first launch (Feature #4).
  Future<void> _seedDefaultSettings() async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: 'darkMode', value: 'false'),
    );
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: 'autoplay', value: 'true'),
    );
  }
}
