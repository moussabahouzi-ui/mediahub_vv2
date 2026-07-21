// =============================================================================
// MediaHub v2 — MediaListScreen (Feature #1: Media Library + Feature #5 test)
// Authority: ADR-002 (presentation layer), ADR-003 (Riverpod),
//            ADR-009 (ErrorBoundary + AsyncValue), ADR-008 (Python IPC)
// =============================================================================
// The main screen of the Media Library feature. Watches the mediaListProvider
// and renders:
//   - AsyncData  → ListView of MediaListTile
//   - AsyncLoading → centered spinner
//   - AsyncError  → error state with retry
//   - empty data  → empty-state message
//
// Phase 2 Feature #5: added a floating "Python test" button on the LEFT side
// that calls verifyRuntime() to test the embedded Python runtime end-to-end.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediahub_application/mediahub_application.dart';
import 'package:mediahub_domain/mediahub_domain.dart';
import 'package:mediahub_python_bridge/mediahub_python_bridge.dart';

import 'media_list_tile.dart';

class MediaListScreen extends ConsumerStatefulWidget {
  const MediaListScreen({super.key});

  @override
  ConsumerState<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends ConsumerState<MediaListScreen> {
  final _pythonClient = PythonApiClient();
  bool _testing = false;

  Future<void> _testPythonRuntime() async {
    setState(() => _testing = true);
    final result = await _pythonClient.verifyRuntime();
    if (!mounted) return;
    setState(() => _testing = false);

    switch (result) {
      case Left(:final value):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Python FAILED: ${value.message}'),
            backgroundColor: Colors.red,
          ),
        );
      case Right(:final value):
        unawaited(
          showDialog<void>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Python Runtime OK'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Python: ${value.pythonVersion ?? "?"}'),
                      Text('MediaHub: ${value.mediahubVersion ?? "?"}'),
                      Text('Timestamp: ${value.timestampMs ?? "?"}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaListAsync = ref.watch(mediaListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Media Library')),
      body: mediaListAsync.when(
        data:
            (items) =>
                items.isEmpty
                    ? const _EmptyState(
                      icon: Icons.library_music_outlined,
                      title: 'Your library is empty',
                      subtitle: 'Media items you add will appear here.',
                    )
                    : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return MediaListTile(
                          item: item,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tapped: ${item.title}')),
                            );
                          },
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => _ErrorState(
              error: error,
              onRetry: () => ref.invalidate(mediaListProvider),
            ),
      ),
      // ── Python runtime test button (LEFT side) ──────────────────────────
      // Phase 2 Feature #5: verifies the embedded Python runtime is alive.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _testing ? null : _testPythonRuntime,
        icon:
            _testing
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.science_outlined),
        label: Text(_testing ? 'Testing...' : 'Test Python'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Something went wrong', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
