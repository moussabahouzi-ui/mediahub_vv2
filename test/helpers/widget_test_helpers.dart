// =============================================================================
// MediaHub v2 — Widget test helpers (Feature #1)
// Authority: ADR-017 (testing strategy)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mediahub_v2/presentation/media/media_list_screen.dart';

Widget makeAppUnderTest({
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: const _TestApp(),
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF524C38),
      ),
      home: const MediaListScreen(),
    );
  }
}
