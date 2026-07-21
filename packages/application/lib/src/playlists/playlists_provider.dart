// =============================================================================
// MediaHub v2 — playlistsProvider (Feature #2: Playlists)
// Authority: ADR-003 (Riverpod), ADR-006 (offline-first)
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

import 'playlist_repository_provider.dart';

final playlistsProvider = StreamProvider<List<Playlist>>((ref) {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.watchAll();
});
