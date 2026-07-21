// =============================================================================
// MediaHub v2 — playlistRepositoryProvider (Feature #2: Playlists)
// Authority: ADR-002 (application layer), ADR-003 (Riverpod)
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  throw UnimplementedError(
    'playlistRepositoryProvider must be overridden in bootstrap (lib/bootstrap/).',
  );
});
