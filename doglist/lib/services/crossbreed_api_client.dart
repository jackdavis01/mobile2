import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/crossbreed_models.dart';
import '../parameters/env_config.dart';

/// Typed client for the public crossbreed JSON API on the DogList backend.
/// Never logs the installation token, headers or bodies.
class CrossbreedApiClient {
  CrossbreedApiClient({http.Client? httpClient, String? baseUrl, String? apiKey, this.timeout = const Duration(seconds: 15)})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? EnvConfig.apiBaseUrl,
        _apiKey = apiKey ?? EnvConfig.apiHeaderKey;

  final http.Client _http;
  final String _baseUrl;
  final String _apiKey;
  final Duration timeout;

  Map<String, String> _headers({String? bearer, String? idempotencyKey, bool json = false}) => {
        'X-API-Key': _apiKey,
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        if (bearer != null) 'Authorization': 'Bearer $bearer',
        if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
      };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query == null || query.isEmpty ? null : query);

  Future<Map<String, dynamic>> _send(
    String method,
    Uri uri, {
    required Set<int> ok,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers ?? const {});
      if (body != null) request.body = jsonEncode(body);
      response = await http.Response.fromStream(await _http.send(request).timeout(timeout)).timeout(timeout);
    } on TimeoutException {
      throw const CrossbreedApiException(code: CrossbreedApiException.timeout);
    } on http.ClientException {
      throw const CrossbreedApiException(code: CrossbreedApiException.network);
    }
    debugPrint('[CrossbreedApi] $method ${uri.path} -> ${response.statusCode}');
    if (!ok.contains(response.statusCode)) {
      throw CrossbreedApiException.fromResponse(response.statusCode, response.body);
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // handled below
    }
    throw CrossbreedApiException(httpStatus: response.statusCode, code: CrossbreedApiException.invalidResponse);
  }

  T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on CrossbreedFormatException catch (e) {
      debugPrint('[CrossbreedApi] rejected response: ${e.message}');
      throw const CrossbreedApiException(code: CrossbreedApiException.invalidResponse);
    } on TypeError {
      throw const CrossbreedApiException(code: CrossbreedApiException.invalidResponse);
    }
  }

  Future<CrossbreedInstallation> createInstallation({required String platform, String? appVersion}) async {
    final json = await _send('POST', _uri('/api/v1/crossbreed-installations'),
        ok: {201},
        headers: _headers(json: true),
        body: {'platform': platform, if (appVersion != null) 'appVersion': appVersion});
    return _parse(() => CrossbreedInstallation.fromJson(json));
  }

  Future<CrossbreedSourcePreview> previewSources(String firstDogId, String secondDogId) async {
    final json = await _send('GET', _uri('/api/v1/crossbreed-sources', {'dogIds': '$firstDogId,$secondDogId'}),
        ok: {200}, headers: _headers());
    return _parse(() => CrossbreedSourcePreview.fromJson(json));
  }

  Future<CrossbreedIntent> createIntent({
    required String installationToken,
    required String clientIntentId,
    required List<String> dogIds,
    required String catalogVersion,
  }) async {
    final json = await _send('POST', _uri('/api/v1/crossbreed-intents'),
        ok: {200, 201},
        headers: _headers(bearer: installationToken, idempotencyKey: clientIntentId, json: true),
        body: {'dogIds': dogIds, 'catalogVersion': catalogVersion});
    return _parse(() => CrossbreedIntent.fromJson(json));
  }

  Future<CrossbreedIntent> getIntent({required String installationToken, required String intentId}) async {
    final json = await _send('GET', _uri('/api/v1/crossbreed-intents/$intentId'),
        ok: {200}, headers: _headers(bearer: installationToken));
    return _parse(() => CrossbreedIntent.fromJson(json));
  }

  Future<CrossbreedRedeemResult> redeem({
    required String installationToken,
    required String intentId,
    required String clientAdAttemptId,
    required String confirmedCatalogVersion,
  }) async {
    final json = await _send('POST', _uri('/api/v1/crossbreed-intents/$intentId/redeem'),
        ok: {200, 202},
        headers: _headers(bearer: installationToken, json: true),
        body: {
          'clientAdAttemptId': clientAdAttemptId,
          'rewardedAdCompleted': true,
          'confirmedCatalogVersion': confirmedCatalogVersion,
        });
    return _parse(() => CrossbreedRedeemResult.fromJson(json));
  }

  Future<CrossbreedJob> getJob({required String installationToken, required String generationId}) async {
    final json = await _send('GET', _uri('/api/v1/crossbreed-jobs/$generationId'),
        ok: {200}, headers: _headers(bearer: installationToken));
    return _parse(() => CrossbreedJob.fromJson(json));
  }

  Future<CrossbreedGalleryPage> listGallery({int? limit, String? cursor, List<String>? dogIds}) async {
    final json = await _send(
        'GET',
        _uri('/api/v1/crossbreeds', {
          if (limit != null) 'limit': '$limit',
          if (cursor != null) 'cursor': cursor,
          if (dogIds != null) 'dogIds': dogIds.join(','),
        }),
        ok: {200},
        headers: _headers());
    return _parse(() => CrossbreedGalleryPage.fromJson(json));
  }

  Future<CrossbreedResult> getGalleryItem(String pairId) async {
    final json = await _send('GET', _uri('/api/v1/crossbreeds/$pairId'), ok: {200}, headers: _headers());
    return _parse(() => CrossbreedResult.fromJson(json));
  }
}
