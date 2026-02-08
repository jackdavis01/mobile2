import 'top_dog.dart';

/// API response model for top 3 most liked dogs
class TopDogsResponse {
  final bool success;
  final List<TopDog> dogs;
  final DateTime? cachedUntil;
  final String? error;

  TopDogsResponse({
    required this.success,
    required this.dogs,
    this.cachedUntil,
    this.error,
  });

  factory TopDogsResponse.fromJson(Map<String, dynamic> json) {
    final dogsList = (json['dogs'] as List<dynamic>?)
        ?.map((dogJson) => TopDog.fromJson(dogJson as Map<String, dynamic>))
        .toList() ?? [];

    DateTime? parsedCachedUntil;
    if (json['cachedUntil'] != null) {
      try {
        parsedCachedUntil = DateTime.parse(json['cachedUntil'] as String);
      } catch (e) {
        // If parsing fails, leave as null
      }
    }

    return TopDogsResponse(
      success: json['success'] as bool? ?? false,
      dogs: dogsList,
      cachedUntil: parsedCachedUntil,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'dogs': dogs.map((dog) => dog.toJson()).toList(),
      'cachedUntil': cachedUntil?.toIso8601String(),
      if (error != null) 'error': error,
    };
  }
}
