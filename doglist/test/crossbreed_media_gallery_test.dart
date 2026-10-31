import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:doglist/businesslogic/crossbreed_gallery_bloc_cubit.dart';
import 'package:doglist/l10n/gen/app_localizations.dart';
import 'package:doglist/models/crossbreed_models.dart';
import 'package:doglist/pages/crossbreed_gallery_page.dart';
import 'package:doglist/pages/crossbreed_result_page.dart';
import 'package:doglist/repositories/crossbreed_repository.dart';
import 'package:doglist/services/crossbreed_image_cache_manager.dart';
import 'package:doglist/widgets/ad_banner.dart';
import 'package:doglist/widgets/crossbreed_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  group('gallery page', () {
    late _GalleryRepo repo;
    late _RecordingMedia media;

    Future<void> pumpGallery(WidgetTester tester, {List<String>? dogIds, List<String>? names}) async {
      await tester.pumpWidget(_app(CrossbreedGalleryScreen(
        dogIds: dogIds,
        names: names,
        repository: repo,
        mediaCache: media,
        imageCacheManager: _FakeCacheManager(),
      )));
      await tester.pumpAndSettle();
    }

    setUp(() {
      repo = _GalleryRepo();
      media = _RecordingMedia();
    });

    testWidgets('shows disclosure, AI tiles and the banner in the bottom navigation slot', (tester) async {
      repo.pages[null] = _page([3, 2, 1]);
      await pumpGallery(tester);

      expect(find.text('All images in this gallery are AI-generated and do not show real dogs.'), findsOneWidget);
      expect(find.byType(CrossbreedImage), findsNWidgets(3));
      expect(find.byIcon(Icons.auto_awesome), findsNWidgets(3));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(find.descendant(of: find.byWidget(scaffold.bottomNavigationBar!), matching: find.byType(AdBanner)),
          findsOneWidget);
      expect(find.byType(AdBanner), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('empty, filtered-empty and error with retry states', (tester) async {
      repo.pages[null] = _page([]);
      await pumpGallery(tester);
      expect(find.text('No AI crossbreeds yet. Create one from Compare Breeds.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());

      await pumpGallery(tester, dogIds: ['bulldog', 'husky'], names: ['Bulldog', 'Husky']);
      expect(find.text('No AI crossbreed for this pair yet.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());

      repo.listError = const CrossbreedApiException(code: 'SERVICE_UNAVAILABLE', httpStatus: 503);
      await pumpGallery(tester);
      expect(find.text("Couldn't load the gallery."), findsOneWidget);
      repo.listError = null;
      repo.pages[null] = _page([1]);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(CrossbreedImage), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('pair filter is sent to the API and can be cleared', (tester) async {
      repo.pages[null] = _page([2, 1]);
      await pumpGallery(tester, dogIds: ['bulldog', 'husky'], names: ['Bulldog', 'Husky']);
      expect(repo.listCalls.single.$2, ['bulldog', 'husky']);
      expect(find.text('Bulldog × Husky'), findsOneWidget);

      await tester.tap(find.descendant(of: find.byType(InputChip), matching: find.byType(Icon)).last);
      await tester.pumpAndSettle();
      expect(repo.listCalls.last.$2, isNull);
      expect(find.byType(InputChip), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('tile opens the result page and a hidden pair is removed from the grid', (tester) async {
      repo.pages[null] = _page([2, 1]);
      repo.hidden.add(_result(2).pairId);
      await pumpGallery(tester);

      await tester.tap(find.text(_result(2).breedNames.join(' × ')).first);
      await tester.pumpAndSettle();
      expect(find.byType(CrossbreedResultPage), findsOneWidget);
      expect(media.evicted, [_result(2).pairId]);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(CrossbreedImage), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('banner never covers the last row, pagination or snackbars and stays one instance', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.reset);

      repo.pages[null] = _page([for (var i = 40; i > 20; i--) i], next: 'c1');
      repo.pages['c1'] = _page([for (var i = 20; i > 0; i--) i]);
      await pumpGallery(tester);
      final bannerState = tester.state(find.byType(AdBanner));
      final placeholder = tester.renderObject<RenderConstrainedBox>(
        find.descendant(of: find.byType(AdBanner), matching: find.byType(SizedBox)),
      );

      for (final adHeight in [0.0, 50.0, 90.0]) {
        placeholder.additionalConstraints = BoxConstraints.tightFor(height: adHeight == 0 ? 0 : adHeight + 34);
        await tester.pump();
        await tester.fling(find.byType(CustomScrollView), const Offset(0, -20000), 5000);
        await tester.pumpAndSettle();

        final bannerTop = tester.getRect(find.byType(AdBanner)).top;
        expect(tester.getRect(find.byType(CustomScrollView)).bottom, lessThanOrEqualTo(bannerTop));
        final lastTile = find.byType(CrossbreedImage).last;
        expect(tester.getRect(lastTile).bottom, lessThanOrEqualTo(bannerTop));
        expect(lastTile.hitTestable(), findsOneWidget);
      }
      expect(repo.listCalls.map((c) => c.$1), [null, 'c1']);
      expect(find.byType(CrossbreedImage), findsWidgets);
      expect(tester.state(find.byType(AdBanner)), same(bannerState));

      ScaffoldMessenger.of(tester.element(find.byType(CustomScrollView)))
          .showSnackBar(const SnackBar(content: Text('note')));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(SnackBar)).bottom,
          lessThanOrEqualTo(tester.getRect(find.byType(AdBanner)).top));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
