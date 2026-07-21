// =============================================================================
// MediaHub v2 — SettingsScreen (Feature #4: Settings)
// Authority: ADR-002 (presentation layer), ADR-003 (Riverpod)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_application/mediahub_application.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        data:
            (settings) => ListView(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use a dark colour scheme'),
                  value: settings['darkMode'] == 'true',
                  onChanged: (v) => _update(ref, 'darkMode', v.toString()),
                ),
                SwitchListTile(
                  title: const Text('Autoplay'),
                  subtitle: const Text('Automatically play next media'),
                  value: settings['autoplay'] != 'false',
                  onChanged: (v) => _update(ref, 'autoplay', v.toString()),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  subtitle: const Text('MediaHub v2 — Phase 1'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'MediaHub',
                      applicationVersion: '0.0.1',
                    );
                  },
                ),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _update(WidgetRef ref, String key, String value) {
    ref.read(settingsRepositoryProvider).set(Setting(key: key, value: value));
  }
}
