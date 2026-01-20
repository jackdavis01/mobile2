/// Response from GET /api/v1/likes/all endpoint.
/// Contains like counts for all dog breeds.
class AllLikesResponse {
  final bool success;
  final Map<String, int> likes;
  final DateTime? cachedUntil;

  AllLikesResponse({
    required this.success,
    required this.likes,
    this.cachedUntil,
  });

  factory AllLikesResponse.fromJson(Map<String, dynamic> json) {
    final likesMap = <String, int>{};
    final likesData = json['likes'] as Map<String, dynamic>?;
    
    if (likesData != null) {
      likesData.forEach((key, value) {
        likesMap[key] = value as int;
      });
    }
    
    return AllLikesResponse(
      success: json['success'] as bool,
      likes: likesMap,
      cachedUntil: json['cachedUntil'] != null
          ? DateTime.parse(json['cachedUntil'] as String)
          : null,
    );
  }

  @override
  String toString() => 'AllLikesResponse(success: $success, '
      'count: ${likes.length} dogs, cachedUntil: $cachedUntil)';
}
