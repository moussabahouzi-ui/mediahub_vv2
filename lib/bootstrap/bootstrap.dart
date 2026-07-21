// =============================================================================
// MediaHub v2 — Bootstrap (composition root)
// Authority: ADR-002 (Clean Architecture DI), ADR-003 (Riverpod overrides),
//            ADR-005/006/007/010/011 — wiring of cross-cutting services.
// =============================================================================
// Features #1–#4: opens the Drift database and overrides all repository
// providers with their real implementations.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_application/mediahub_application.dart';
import 'package:mediahub_data/mediahub_data.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<ProviderContainer> bootstrap({List<Override>? overrides}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initLogging();
  await _initSecureStorage();

  final database = await _openDatabase();

  await _initSyncEngine();
  await _initPythonRuntime();

  return ProviderContainer(
    overrides: [
      mediaRepositoryProvider.overrideWithValue(
        MediaRepositoryImpl(database.mediaItemsDao),
      ),
      playlistRepositoryProvider.overrideWithValue(
        PlaylistRepositoryImpl(database.playlistsDao),
      ),
      historyRepositoryProvider.overrideWithValue(
        HistoryRepositoryImpl(database.historyDao),
      ),
      settingsRepositoryProvider.overrideWithValue(
        SettingsRepositoryImpl(database.settingsDao),
      ),
      ...?overrides,
    ],
  );
}

Future<void> _initLogging() async {}
Future<void> _initSecureStorage() async {}

Future<MediaHubDatabase> _openDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'mediahub.db'));
  return MediaHubDatabase(NativeDatabase(file));
}

Future<void> _initSyncEngine() async {}
Future<void> _initPythonRuntime() async {}
