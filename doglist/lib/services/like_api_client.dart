import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/like_request.dart';
import '../models/like_response.dart';
import '../models/bulk_likes_response.dart';
import '../models/all_likes_response.dart';
import '../parameters/env_config.dart';

/// API client for dog liking feature.
/// Handles communication with the Quarkus Native backend.
class LikeApiClient {
  static final LikeApiClient _instance = LikeApiClient._internal();
  factory LikeApiClient() => _instance;
  LikeApiClient._internal();

  final String _baseUrl = EnvConfig.apiBaseUrl;
  final String _headerKey = EnvConfig.apiHeaderKey;
  final String _bodyKey = EnvConfig.apiBodyKey;

  /// Like a specific dog breed.
  /// Returns [LikeResponse] with success status and like count.
  Future<LikeResponse> likeDog(String dogId, String udid) async {
    try {
      final request = LikeRequest(
        apiKey: _bodyKey,
        udid: udid,
        dogId: dogId,
      );

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/like'),
            headers: {
              'Content-Type': 'application/json',
              'X-API-Key': _headerKey,
            },
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return LikeResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 429) {
        return LikeResponse(
          success: false,
          error: 'Too many requests. Please try again later.',
        );
      } else if (response.statusCode >= 500) {
        return LikeResponse(
          success: false,
          error: 'Server is temporarily unavailable. Please try again.',
        );
      } else {
        return LikeResponse(
          success: false,
          error: 'Unable to like this dog (Error ${response.statusCode})',
        );
      }
    } on TimeoutException {
      return LikeResponse(
        success: false,
        error: 'Request timed out. Please check your connection.',
      );
    } on http.ClientException catch (e) {
      return LikeResponse(
        success: false,
        error: 'Network error: ${e.message}',
      );
    } on FormatException {
      return LikeResponse(
        success: false,
        error: 'Invalid server response. Please try again.',
      );
    } catch (e) {
      return LikeResponse(
        success: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Fetch all like counts for all dog breeds.
  /// Returns a map of dogId -> likeCount.
  /// No parameters required, but requires X-API-Key header.
  Future<Map<String, int>> getAllLikes() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/v1/likes/all'),
            headers: {
              'X-API-Key': _headerKey,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final allLikesResponse = AllLikesResponse.fromJson(
          json.decode(response.body),
        );
        return allLikesResponse.likes;
      } else if (response.statusCode >= 500) {
        throw Exception('Server temporarily unavailable');
      } else {
        throw Exception('Failed to load like counts (Error ${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your network.');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException {
      throw Exception('Invalid server response');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Unable to load like counts');
    }
  }

  /// Fetch like counts for specific dog breeds.
  /// Returns a map of dogId -> likeCount for the requested dogs.
  Future<Map<String, int>> getBulkLikes(List<String> dogIds) async {
    try {
      final dogIdsParam = dogIds.join(',');
      final url = '$_baseUrl/api/v1/likes/bulk?dogIds=$dogIdsParam';
      
      debugPrint('[LikeApiClient] Calling getBulkLikes for ${dogIds.length} dogs');
      debugPrint('[LikeApiClient] URL: $url');
      debugPrint('[LikeApiClient] DogIds: $dogIdsParam');
      
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'X-API-Key': _headerKey,
            },
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('[LikeApiClient] Response status: ${response.statusCode}');
      debugPrint('[LikeApiClient] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final bulkResponse = BulkLikesResponse.fromJson(
          json.decode(response.body),
        );
        debugPrint('[LikeApiClient] Successfully parsed ${bulkResponse.likes.length} like counts');
        return bulkResponse.likes;
      } else if (response.statusCode >= 500) {
        throw Exception('Server temporarily unavailable');
      } else {
        throw Exception('Failed to load like counts (Error ${response.statusCode})');
      }
    } on TimeoutException {
      debugPrint('[LikeApiClient] Request timed out');
      throw Exception('Connection timed out');
    } on http.ClientException catch (e) {
      debugPrint('[LikeApiClient] Client exception: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('[LikeApiClient] Format exception: $e');
      throw Exception('Invalid server response');
    } catch (e) {
      debugPrint('[LikeApiClient] Unexpected error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Unable to load like counts');
    }
  }
}
