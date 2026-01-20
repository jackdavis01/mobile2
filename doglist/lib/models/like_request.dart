/// Request payload for liking a dog.
/// Sent to POST /api/v1/like
class LikeRequest {
  final String apiKey;
  final String udid;
  final String dogId;

  LikeRequest({
    required this.apiKey,
    required this.udid,
    required this.dogId,
  });

  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'udid': udid,
        'dogId': dogId,
      };
}
