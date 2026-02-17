import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/top_dogs_response.dart';
import '../parameters/env_config.dart';

/// API client for fetching top 3 most liked dogs.
/// Handles communication with the Quarkus Native backend.
class TopDogsApiClient {
  static final TopDogsApiClient _instance = TopDogsApiClient._internal();
  factory TopDogsApiClient() => _instance;
  TopDogsApiClient._internal();

  final String _baseUrl = EnvConfig.apiBaseUrl;
  final String _headerKey = EnvConfig.apiHeaderKey;

  /// Fetch the top 3 most liked dogs from the backend.
  /// Returns [TopDogsResponse] with success status and list of top dogs.
  Future<TopDogsResponse> getTop3Dogs() async {
    try {
      debugPrint('[TopDogsApiClient] Fetching top 3 dogs from: $_baseUrl/api/v1/likes/top3');
      
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/v1/likes/top3'),
            headers: {
              'X-API-Key': _headerKey,
            },
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('[TopDogsApiClient] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final topDogsResponse = TopDogsResponse.fromJson(
          json.decode(response.body),
        );
        debugPrint('[TopDogsApiClient] Successfully fetched ${topDogsResponse.dogs.length} top dogs');
        return topDogsResponse;
      } else if (response.statusCode == 429) {
        return TopDogsResponse(
          success: false,
          dogs: [],
          error: 'Too many requests. Please try again later.',
        );
      } else if (response.statusCode >= 500) {
        return TopDogsResponse(
          success: false,
          dogs: [],
          error: 'Server is temporarily unavailable. Please try again.',
        );
      } else {
        return TopDogsResponse(
          success: false,
          dogs: [],
          error: 'Unable to load top dogs (Error ${response.statusCode})',
        );
      }
    } on TimeoutException {
      debugPrint('[TopDogsApiClient] Request timed out');
      return TopDogsResponse(
        success: false,
        dogs: [],
        error: 'Request timed out. Please check your connection.',
      );
    } on http.ClientException catch (e) {
      debugPrint('[TopDogsApiClient] Network error: ${e.message}');
      return TopDogsResponse(
        success: false,
        dogs: [],
        error: 'Network error: ${e.message}',
      );
    } on FormatException {
      debugPrint('[TopDogsApiClient] Invalid server response');
      return TopDogsResponse(
        success: false,
        dogs: [],
        error: 'Invalid server response. Please try again.',
      );
    } catch (e) {
      debugPrint('[TopDogsApiClient] Unexpected error: $e');
      return TopDogsResponse(
        success: false,
        dogs: [],
        error: 'An unexpected error occurred',
      );
    }
  }
}
