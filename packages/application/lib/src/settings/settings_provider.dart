// =============================================================================
// MediaHub v2 — settingsProvider (Feature #4: Settings)
// Authority: ADR-003 (Riverpod)
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_repository_provider.dart';

/// Stream of all settings as a Map for O(1) key lookup.
final settingsProvider = StreamProvider<Map<String, String>>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchAll().map(
    (settings) =>
        Map.fromEntries(settings.map((s) => MapEntry(s.key, s.value))),
  );
});

/// Convenience provider for a single boolean setting.
final settingBoolProvider = Provider.family.autoDispose<bool, String>((
  ref,
  key,
) {
  final settings = ref.watch(settingsProvider).valueOrNull ?? {};
  return settings[key]?.toLowerCase() == 'true' || settings[key] == '1';
});
