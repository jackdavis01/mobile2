import 'dart:convert';
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
      } else {
        return LikeResponse(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      return LikeResponse(
        success: false,
        error: 'Network error: ${e.message}',
      );
    } catch (e) {
      return LikeResponse(
        success: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  /// Fetch all dog like counts in a single request.
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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final allLikesResponse = AllLikesResponse.fromJson(
          json.decode(response.body),
        );
        return allLikesResponse.likes;
      } else {
        throw Exception('Failed to fetch all likes: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching all likes: $e');
    }
  }

  /// Fetch like counts for specific dog breeds.
  /// Returns a map of dogId -> likeCount for the requested dogs.
  Future<Map<String, int>> getBulkLikes(List<String> dogIds) async {
    try {
      final dogIdsParam = dogIds.join(',');
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/v1/like/bulk?dogIds=$dogIdsParam'),
            headers: {
              'X-API-Key': _headerKey,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final bulkResponse = BulkLikesResponse.fromJson(
          json.decode(response.body),
        );
        return bulkResponse.likes;
      } else {
        throw Exception('Failed to fetch bulk likes: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching bulk likes: $e');
    }
  }
}
