// =============================================================================
// MediaHub v2 — mediaListProvider (Feature #1: Media Library)
// Authority: ADR-002 (application layer), ADR-003 (Riverpod), ADR-006 (offline-first)
// =============================================================================
// A StreamProvider that watches the MediaRepository for the full media list.
// The presentation layer watches this provider and renders the list.
//
// Offline-first (ADR-006): reads come from the local Drift DB via the
// repository; no network call is made for browsing.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

import 'media_repository_provider.dart';

/// StreamProvider for the full media list.
///
/// Emits `AsyncValue<List<MediaItem>>`. The UI pattern-matches on:
///   - AsyncData  → render the list
///   - AsyncLoading → render a spinner
///   - AsyncError  → render an error state
final mediaListProvider = StreamProvider<List<MediaItem>>((ref) {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.watchAll();
});
