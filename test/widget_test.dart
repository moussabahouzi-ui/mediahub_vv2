// =============================================================================
// MediaHub v2 — App widget test (Feature #1: Media Library)
// Authority: ADR-017 (widget test tier)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediahub_application/mediahub_application.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

import 'fakes/fake_media_repository.dart';
import 'helpers/widget_test_helpers.dart' show makeAppUnderTest;

void main() {
  group('MediaListScreen', () {
    testWidgets('renders loading indicator then the media list', (tester) async {
      final items = [
        MediaItem(
          id: const MediaId('w-001'),
          title: 'Widget Test Item',
          duration: const Duration(minutes: 2),
          source: 'https://example.com/widget.mp3',
          createdAt: DateTime.utc(2025, 1, 1),
        ),
      ];

      await tester.pumpWidget(
        makeAppUnderTest(
          overrides: [
            mediaRepositoryProvider
                .overrideWithValue(FakeMediaRepository(items)),
          ],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Widget Test Item'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('renders empty state when the list is empty', (tester) async {
      await tester.pumpWidget(
        makeAppUnderTest(
          overrides: [
            mediaRepositoryProvider.overrideWithValue(FakeMediaRepository()),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your library is empty'), findsOneWidget);
    });

    testWidgets('renders multiple items in a ListView', (tester) async {
      final items = [
        for (var i = 1; i <= 5; i++)
          MediaItem(
            id: MediaId('multi-$i'),
            title: 'Item $i',
            duration: Duration(seconds: i * 10),
            source: 'https://example.com/item-$i.mp3',
            createdAt: DateTime.utc(2025, 1, i),
          ),
      ];

      await tester.pumpWidget(
        makeAppUnderTest(
          overrides: [
            mediaRepositoryProvider
                .overrideWithValue(FakeMediaRepository(items)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(5));
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);
    });

    testWidgets('renders the Python test button on the left', (tester) async {
      await tester.pumpWidget(
        makeAppUnderTest(
          overrides: [
            mediaRepositoryProvider.overrideWithValue(FakeMediaRepository()),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Python'), findsOneWidget);
      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    });
  });
}
