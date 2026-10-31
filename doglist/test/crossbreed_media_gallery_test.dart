import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:doglist/businesslogic/crossbreed_gallery_bloc_cubit.dart';
import 'package:doglist/l10n/gen/app_localizations.dart';
import 'package:doglist/models/crossbreed_models.dart';
import 'package:doglist/pages/crossbreed_result_page.dart';
import 'package:doglist/repositories/crossbreed_repository.dart';
import 'package:doglist/services/crossbreed_image_cache_manager.dart';
import 'package:doglist/widgets/crossbreed_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

final Map<String, dynamic> _base = jsonDecode(
    File('test/fixtures/crossbreed/examples/valid/public/crossbreed-result/bulldog-husky.json').readAsStringSync());

/// Result [i]: newer results have higher [i] (gallery order is completedAt desc).
CrossbreedResult _result(int i) {
  final pairId = '3f6c1a52-8d4e-4b7a-9c21-6e0f5d2a7b${i.toRadixString(16).padLeft(2, '0')}';
  final json = jsonDecode(jsonEncode(_base)) as Map<String, dynamic>;
  json['pairId'] = pairId;
  json['imageUrl'] = 'https://media.example.test/crossbreeds/$pairId/original.png';
  json['thumbnailUrl'] = 'https://media.example.test/crossbreeds/$pairId/thumbnail.webp';
  json['completedAt'] = DateTime.utc(2026, 10, 1).add(Duration(minutes: i)).toIso8601String();
  return CrossbreedResult.fromJson(json);
}

const _notFound = CrossbreedApiException(code: 'NOT_FOUND', httpStatus: 404);

class _GalleryRepo implements CrossbreedRepository {
  final pages = <String?, CrossbreedGalleryPage>{};
  final hidden = <String>{};
  final details = <String>[];
  final listCalls = <(String?, List<String>?)>[];
  Object? listError;

  @override
  Future<CrossbreedGalleryPage> listGallery({int? limit, String? cursor, List<String>? dogIds}) async {
    listCalls.add((cursor, dogIds));
    if (listError != null) throw listError!;
    return pages[cursor]!;
  }

  @override
  Future<CrossbreedResult> getGalleryItem(String pairId) async {
    details.add(pairId);
    if (hidden.contains(pairId)) throw _notFound;
    return _result(0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _RecordingMedia extends CrossbreedMediaCache {
  final evicted = <String>[];

  @override
  Future<void> evict(CrossbreedResult result) async => evicted.add(result.pairId);
}

class _FakeCacheManager implements BaseCacheManager {
  final removed = <String>[];
  final requested = <String>[];

  @override
  Future<void> removeFile(String key) async => removed.add(key);

  @override
  Stream<FileResponse> getFileStream(String url, {String? key, Map<String, String>? headers, bool withProgress = false}) {
    requested.add(key ?? url);
    return Stream.error(const HttpExceptionWithStatus(503, 'unavailable'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

CrossbreedGalleryPage _page(List<int> ids, {String? next}) =>
    CrossbreedGalleryPage(items: [for (final i in ids) _result(i)], nextCursor: next, limit: 3);

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cache manager config is separate from the breed cache', () {
    expect(CrossbreedImageCacheManager.key, 'crossbreedImagesV1');
    expect(CrossbreedImageCacheManager.stalePeriod, const Duration(days: 30));
    expect(CrossbreedImageCacheManager.maxNrOfCacheObjects, 804);
  });

  test('eviction removes both roles by their absolute permanent URL', () async {
    final manager = _FakeCacheManager();
    final r = _result(1);
    await CrossbreedMediaCache(cacheManager: manager).evict(r);
    expect(manager.removed, [r.thumbnailUrl, r.imageUrl]);
  });

  testWidgets('thumbnail role loads the full thumbnail URL and retries the same URL', (tester) async {
    final manager = _FakeCacheManager();
    final r = _result(1);
    await tester.pumpWidget(_app(Center(
      child: SizedBox.square(
          dimension: 100, child: CrossbreedImage(result: r, role: CrossbreedImageRole.thumbnail, cacheManager: manager)),
    )));
    await tester.pumpAndSettle();
    expect(manager.requested, [r.thumbnailUrl]);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(manager.requested, [r.thumbnailUrl, r.thumbnailUrl]);
  });

  testWidgets('result page evicts and hides a pair the backend reports as not found', (tester) async {
    final repo = _GalleryRepo()..hidden.add(_result(1).pairId);
    final media = _RecordingMedia();
    String? reported;
    await tester.pumpWidget(_app(CrossbreedResultPage(
      result: _result(1),
      repository: repo,
      mediaCache: media,
      imageCacheManager: _FakeCacheManager(),
      onUnavailable: (id) => reported = id,
    )));
    await tester.pumpAndSettle();
    expect(media.evicted, [_result(1).pairId]);
    expect(reported, _result(1).pairId);
    expect(find.text('This crossbreed image is no longer available.'), findsOneWidget);
    expect(find.byType(CrossbreedImage), findsNothing);
  });

  group('gallery cubit', () {
    late _GalleryRepo repo;
    late _RecordingMedia media;
    CrossbreedGalleryCubit cubit() =>
        CrossbreedGalleryCubit(repository: repo, mediaCache: media, pageSize: 3, observeLifecycle: false);

    setUp(() {
      repo = _GalleryRepo();
      media = _RecordingMedia();
    });

    test('paginates without duplicates', () async {
      repo.pages[null] = _page([9, 8, 7], next: 'c1');
      repo.pages['c1'] = _page([7, 6], next: null);
      final c = cubit();
      await c.refresh();
      expect(c.state.hasMore, isTrue);
      await c.loadMore();
      expect(c.state.items.map((r) => r.pairId), [9, 8, 7, 6].map((i) => _result(i).pairId));
      expect(c.state.hasMore, isFalse);
      await c.close();
    });

    test('refresh error keeps the listed items', () async {
      repo.pages[null] = _page([9, 8]);
      final c = cubit();
      await c.refresh();
      repo.listError = const CrossbreedApiException(code: 'SERVICE_UNAVAILABLE', httpStatus: 503);
      await c.refresh();
      expect(c.state.items, hasLength(2));
      expect(c.state.errorCode, 'SERVICE_UNAVAILABLE');
      await c.close();
    });

    test('absence alone is not deletion; only in-range items confirmed hidden are evicted', () async {
      repo.pages[null] = _page([9, 8, 7], next: 'c1');
      repo.pages['c1'] = _page([6, 5]);
      final c = cubit();
      await c.refresh();
      await c.loadMore();
      // 8 hidden; 9 still exists but was missing from this response; 6 and 5 lie beyond the new page.
      repo.hidden.add(_result(8).pairId);
      repo.pages[null] = _page([10, 7, 6], next: 'c2');
      await c.refresh();
      expect(repo.details.toSet(), {_result(9).pairId, _result(8).pairId});
      expect(media.evicted, [_result(8).pairId]);
      expect(c.state.items.map((r) => r.pairId), [10, 7, 6].map((i) => _result(i).pairId));
      await c.close();
    });

    test('filter is sent and resets the list', () async {
      repo.pages[null] = _page([9]);
      final c = cubit();
      await c.refresh();
      await c.setFilter(['bulldog']);
      expect(repo.listCalls.last.$1, isNull);
      expect(repo.listCalls.last.$2, ['bulldog']);
      expect(media.evicted, isEmpty);
      c.removeUnavailable(_result(9).pairId);
      expect(c.state.isEmpty, isTrue);
      await c.close();
    });
  });
}
