import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Public crossbreed contract fixtures synced from doglist-ai/contracts
/// (scripts/sync-contracts.sh). Part 5 mock repositories load these files.
const _root = 'test/fixtures/crossbreed';

final _uuidV4 = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

Map<String, dynamic> _load(String relative) =>
    jsonDecode(File('$_root/$relative').readAsStringSync()) as Map<String, dynamic>;

Iterable<File> _jsonFiles(String dir) => Directory('$_root/$dir')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.json') && !f.path.endsWith('INDEX.json'));

void _expectResult(Map<String, dynamic> result) {
  final pairId = result['pairId'] as String;
  expect(_uuidV4.hasMatch(pairId), isTrue);
  expect(_uuidV4.hasMatch(result['generationId'] as String), isTrue);
  final image = Uri.parse(result['imageUrl'] as String);
  final thumb = Uri.parse(result['thumbnailUrl'] as String);
  for (final uri in [image, thumb]) {
    expect(uri.scheme, 'https');
    expect(uri.hasQuery, isFalse, reason: 'permanent URLs carry no signature/expiry');
    expect(uri.pathSegments.take(2), ['crossbreeds', pairId]);
    expect(uri.pathSegments.length, 3, reason: 'no generation ID in public paths');
  }
  expect(image.pathSegments.last, 'original.png');
  expect(thumb.pathSegments.last, 'thumbnail.webp');
  expect([result['imageWidth'], result['imageHeight']], [1024, 1024]);
  expect([result['thumbnailWidth'], result['thumbnailHeight']], [256, 256]);
  expect(result['aiGenerated'], isTrue);
  expect(result.containsKey('mediaExpiresAt'), isFalse);
}

void main() {
  test('contract marker is present', () {
    final marker = File('$_root/CONTRACTS_SOURCE.txt').readAsStringSync();
    expect(marker, startsWith('crossbreed-contracts-v1'));
  });

  test('valid public examples decode and never expose media expiry', () {
    final files = _jsonFiles('examples/valid/public').toList();
    expect(files.length, greaterThanOrEqualTo(25));
    for (final file in files) {
      final text = file.readAsStringSync();
      expect(jsonDecode(text), isA<Map<String, dynamic>>(), reason: file.path);
      expect(text.contains('mediaExpiresAt'), isFalse, reason: file.path);
    }
  });

  test('results use permanent pair-only Hetzner URLs and exact dimensions', () {
    _expectResult(_load('examples/valid/public/crossbreed-result/bulldog-husky.json'));
    _expectResult(_load('examples/valid/public/redeem-response/reused-200.json')['result'] as Map<String, dynamic>);
    final page = _load('examples/valid/public/gallery-list-response/first-page.json');
    for (final item in page['items'] as List) {
      _expectResult(item as Map<String, dynamic>);
    }
  });

  test('generated and joined redemptions poll the same job without a result', () {
    for (final name in ['generated-202', 'joined-202']) {
      final body = _load('examples/valid/public/redeem-response/$name.json');
      expect(body['result'], isNull);
      expect(body['pollAfterSeconds'], 3);
      expect(['queued', 'processing'], contains(body['status']));
    }
  });

  test('unfulfilled intents carry no mapping; reward status allows same-intent recovery', () {
    final reported = _load('examples/valid/public/intent-response/reward-reported-unfulfilled.json');
    expect(reported['rewardStatus'], 'client_reported');
    expect(reported['pairId'], isNull);
    expect(reported['generationId'], isNull);
    final error = _load('examples/valid/public/error-response/source-version-changed.json');
    expect(error['success'], isFalse);
    expect(error['rewardStatus'], 'client_reported');
  });

  test('product scenarios reference existing public examples', () {
    final scenarios = (_load('fixtures/product-scenarios.json')['scenarios'] as List).cast<Map<String, dynamic>>();
    final ids = scenarios.map((s) => s['id']).toSet();
    expect(ids, containsAll(['ready-reuse', 'active-join', 'missing-pair-generate', 'local-cache-hit-still-needs-ad']));
    for (final s in scenarios) {
      for (final rel in (s['responses'] as List? ?? const [])) {
        expect(File('$_root/examples/valid/$rel').existsSync(), isTrue, reason: '$rel (${s['id']})');
      }
    }
  });

  test('invalid public examples are indexed', () {
    final files = _jsonFiles('examples/invalid/public').toList();
    expect(files, isNotEmpty);
    expect(files.any((f) => f.path.endsWith('media-expires-at.json')), isTrue);
  });
}
