/// Response from GET /api/v1/like/bulk endpoint.
/// Contains like counts for a specific set of dog breeds.
class BulkLikesResponse {
  final Map<String, int> likes;

  BulkLikesResponse({required this.likes});

  factory BulkLikesResponse.fromJson(Map<String, dynamic> json) {
    final likesMap = <String, int>{};
    final likesData = json['likes'] as Map<String, dynamic>?;
    
    if (likesData != null) {
      likesData.forEach((key, value) {
        likesMap[key] = value as int;
      });
    }
    
    return BulkLikesResponse(likes: likesMap);
  }

  @override
  String toString() => 'BulkLikesResponse(count: ${likes.length} dogs)';
}
