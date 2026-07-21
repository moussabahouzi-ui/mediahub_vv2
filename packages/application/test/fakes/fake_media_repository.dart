// =============================================================================
// MediaHub v2 — FakeMediaRepository (application test double)
// Authority: ADR-002, ADR-017
// =============================================================================

import 'package:mediahub_domain/mediahub_domain.dart';

class FakeMediaRepository implements MediaRepository {
  FakeMediaRepository([List<MediaItem>? initial])
      : _items = initial ?? const [];

  final List<MediaItem> _items;

  @override
  Stream<List<MediaItem>> watchAll() {
    return Stream.value(List.unmodifiable(_items));
  }

  @override
  Future<Either<Failure, MediaItem>> getById(MediaId id) async {
    final item = _items.where((m) => m.id == id).firstOrNull;
    if (item == null) {
      return const Left(StorageFailure(message: 'not found'));
    }
    return Right(item);
  }

  @override
  Future<Either<Failure, void>> save(MediaItem item) async {
    final idx = _items.indexWhere((m) => m.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
    return const Right(null);
  }
}
