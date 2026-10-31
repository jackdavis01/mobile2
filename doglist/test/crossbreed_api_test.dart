import 'dart:convert';
import 'dart:io';

import 'package:doglist/models/crossbreed_models.dart';
import 'package:doglist/repositories/crossbreed_repository.dart';
import 'package:doglist/services/crossbreed_api_client.dart';
import 'package:doglist/services/crossbreed_token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _root = 'test/fixtures/crossbreed/examples';

String _read(String relative) => File('$_root/$relative').readAsStringSync();
Map<String, dynamic> _json(String relative) => jsonDecode(_read(relative)) as Map<String, dynamic>;
Iterable<String> _names(String dir) => Directory('$_root/$dir')
    .listSync()
    .whereType<File>()
    .where((f) => f.path.endsWith('.json'))
    .map((f) => f.uri.pathSegments.last);

final Map<String, Object Function(Map<String, dynamic>)> _parsers = {
  'crossbreed-result': CrossbreedResult.fromJson,
  'gallery-list-response': CrossbreedGalleryPage.fromJson,
  'installation-create-response': CrossbreedInstallation.fromJson,
  'intent-response': CrossbreedIntent.fromJson,
  'job-status-response': CrossbreedJob.fromJson,
  'redeem-response': CrossbreedRedeemResult.fromJson,
  'source-preview-response': CrossbreedSourcePreview.fromJson,
};

const _installationJson = '{"installationId":"0b6c2f4e-8a1d-4c3b-9e7f-5a2d1c0b9e8f",'
    '"installationToken":"tok-new-abcdefghijklmnopqrstuvwxyz012345","tokenType":"Bearer"}';

void main() {
  group('strict models', () {
    for (final entry in _parsers.entries) {
      for (final name in _names('valid/public/${entry.key}')) {
        test('accepts valid ${entry.key}/$name', () {
          expect(() => entry.value(_json('valid/public/${entry.key}/$name')), returnsNormally);
        });
      }
      final invalidDir = Directory('$_root/invalid/public/${entry.key}');
      if (!invalidDir.existsSync()) continue;
      for (final name in _names('invalid/public/${entry.key}')) {
        test('rejects invalid ${entry.key}/$name', () {
          expect(() => entry.value(_json('invalid/public/${entry.key}/$name')),
              throwsA(isA<CrossbreedFormatException>()));
        });
      }
    }

    test('result keeps dimensions, canonical order and reuse/join/generated kinds', () {
      final result = CrossbreedResult.fromJson(_json('valid/public/crossbreed-result/bulldog-husky.json'));
      expect([result.imageWidth, result.imageHeight, result.thumbnailWidth, result.thumbnailHeight], [1024, 1024, 256, 256]);
      expect(compareDogIds(result.dogIds[0], result.dogIds[1]), lessThan(0));
      expect(CrossbreedRedeemResult.fromJson(_json('valid/public/redeem-response/reused-200.json')).fulfillment,
          FulfillmentKind.reused);
      expect(CrossbreedRedeemResult.fromJson(_json('valid/public/redeem-response/joined-202.json')).fulfillment,
          FulfillmentKind.joined);
      expect(CrossbreedRedeemResult.fromJson(_json('valid/public/redeem-response/generated-202.json')).fulfillment,
          FulfillmentKind.generated);
    });

    test('error bodies map to safe exceptions', () {
      final e = CrossbreedApiException.fromResponse(503, _read('valid/public/error-response/service-unavailable.json'));
      expect(e.code, 'SERVICE_UNAVAILABLE');
      expect(e.isTransient, isTrue);
      final html = CrossbreedApiException.fromResponse(502, '<html>bad gateway</html>');
      expect(html.code, 'SERVICE_UNAVAILABLE');
      expect(CrossbreedApiException.fromResponse(400, 'nope').code, CrossbreedApiException.invalidResponse);
    });
  });

  group('api client', () {
    test('sends api key, bearer and idempotency key; accepts 201 and 200 replay', () async {
      final seen = <http.Request>[];
      var calls = 0;
      final client = CrossbreedApiClient(
        baseUrl: 'https://api.example',
        apiKey: 'k',
        httpClient: MockClient((r) async {
          seen.add(r);
          return http.Response(_read('valid/public/intent-response/created.json'), calls++ == 0 ? 201 : 200);
        }),
      );
      for (var i = 0; i < 2; i++) {
        await client.createIntent(
            installationToken: 'secret', clientIntentId: 'c1', dogIds: const ['a', 'b'], catalogVersion: 'v1');
      }
      final r = seen.first;
      expect(r.url.toString(), 'https://api.example/api/v1/crossbreed-intents');
      expect(r.headers['X-API-Key'], 'k');
      expect(r.headers['Authorization'], 'Bearer secret');
      expect(r.headers['Idempotency-Key'], 'c1');
      expect(jsonDecode(r.body), {'dogIds': ['a', 'b'], 'catalogVersion': 'v1'});
    });

    test('gallery and sources never send the installation token', () async {
      final seen = <http.Request>[];
      final client = CrossbreedApiClient(
        baseUrl: 'https://api.example',
        apiKey: 'k',
        httpClient: MockClient((r) async {
          seen.add(r);
          final file = r.url.path.endsWith('crossbreeds')
              ? 'valid/public/gallery-list-response/first-page.json'
              : 'valid/public/source-preview-response/eligible-reversed-selection.json';
          return http.Response(_read(file), 200);
        }),
      );
      await client.listGallery(limit: 20, dogIds: const ['x', 'y']);
      await client.previewSources('x', 'y');
      expect(seen.every((r) => !r.headers.containsKey('Authorization')), isTrue);
      expect(seen.first.url.queryParameters, {'limit': '20', 'dogIds': 'x,y'});
      expect(seen.last.url.queryParameters, {'dogIds': 'x,y'});
    });

    test('maps contract errors, network failures and invalid bodies', () async {
      Future<CrossbreedApiException> fail(MockClient http) async {
        try {
          await CrossbreedApiClient(baseUrl: 'https://api.example', apiKey: 'k', httpClient: http)
              .getGalleryItem('p');
        } on CrossbreedApiException catch (e) {
          return e;
        }
        throw StateError('expected failure');
      }

      final conflict = await fail(MockClient((_) async =>
          http.Response(_read('valid/public/error-response/source-version-changed.json'), 409)));
      expect(conflict.code, 'SOURCE_VERSION_CHANGED');
      expect(conflict.currentCatalogVersion, isNotNull);
      expect((await fail(MockClient((_) async => throw http.ClientException('down')))).code,
          CrossbreedApiException.network);
      expect((await fail(MockClient((_) async => http.Response('[]', 200)))).code, CrossbreedApiException.invalidResponse);
      expect(
          (await fail(MockClient(
                  (_) async => http.Response(_read('invalid/public/crossbreed-result/signed-url-query.json'), 200))))
              .code,
          CrossbreedApiException.invalidResponse);
    });
  });

  group('repository installation', () {
    test('bootstraps once, then re-bootstraps after INSTALLATION_UNAUTHORIZED for a new intent', () async {
      final store = InMemoryCrossbreedTokenStore();
      await store.write(const CrossbreedInstallation(
          installationId: '1b6c2f4e-8a1d-4c3b-9e7f-5a2d1c0b9e8f', installationToken: 'tok-old'));
      final bearers = <String?>[];
      var installs = 0;
      final repo = ApiCrossbreedRepository(
        tokenStore: store,
        appVersion: () async => '1.2.3',
        platform: () => 'android',
        client: CrossbreedApiClient(
          baseUrl: 'https://api.example',
          apiKey: 'k',
          httpClient: MockClient((r) async {
            if (r.url.path.endsWith('crossbreed-installations')) {
              installs++;
              expect(jsonDecode(r.body), {'platform': 'android', 'appVersion': '1.2.3'});
              return http.Response(_installationJson, 201);
            }
            bearers.add(r.headers['Authorization']);
            if (r.headers['Authorization'] == 'Bearer tok-old') {
              return http.Response('{"success":false,"error":"INSTALLATION_UNAUTHORIZED"}', 401);
            }
            return http.Response(_read('valid/public/intent-response/created.json'), 201);
          }),
        ),
      );
      await repo.createIntent(clientIntentId: 'c', dogIds: const ['a', 'b'], catalogVersion: 'v');
      await repo.createIntent(clientIntentId: 'd', dogIds: const ['a', 'b'], catalogVersion: 'v');
      expect(installs, 1);
      expect(bearers, ['Bearer tok-old', 'Bearer tok-new-abcdefghijklmnopqrstuvwxyz012345', 'Bearer tok-new-abcdefghijklmnopqrstuvwxyz012345']);
      expect((await store.read())!.installationToken, startsWith('tok-new'));
    });
  });

  group('secure token store', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('keeps the token out of SharedPreferences', () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final store = SecureCrossbreedTokenStore();
      final installation = CrossbreedInstallation.fromJson(jsonDecode(_installationJson) as Map<String, dynamic>);
      await store.write(installation);
      expect((await store.read())!.installationToken, installation.installationToken);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().any((k) => '${prefs.get(k)}'.contains(installation.installationToken)), isFalse);
      await store.clear();
      expect(await store.read(), isNull);
    });
  });
}
