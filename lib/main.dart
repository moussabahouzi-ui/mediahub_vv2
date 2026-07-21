// =============================================================================
// MediaHub v2 — App entry point (Features #1–#4)
// Authority: ADR-001 (Flutter), ADR-003 (Riverpod), ADR-009 (ErrorBoundary)
// =============================================================================
// Bottom navigation: Library, Playlists, History, Settings.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap/bootstrap.dart';
import 'presentation/error_boundary.dart';
import 'presentation/history/history_screen.dart';
import 'presentation/media/media_list_screen.dart';
import 'presentation/playlists/playlists_screen.dart';
import 'presentation/settings/settings_screen.dart';

Future<void> main() async {
  final container = await bootstrap();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ErrorBoundary(child: _MediaHubRoot()),
    ),
  );
}

class _MediaHubRoot extends StatelessWidget {
  const _MediaHubRoot();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediaHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF524C38),
      ),
      home: const _MainShell(),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;

  static const _screens = [
    MediaListScreen(),
    PlaylistsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.queue_music_outlined),
            selectedIcon: Icon(Icons.queue_music),
            label: 'Playlists',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
