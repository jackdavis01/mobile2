/// Request payload for rewarded liking a dog.
/// Sent to POST /api/v1/like/rewarded
class RewardedLikeRequest {
  final String apiKey;
  final String apiKeyRewarded;
  final String udid;
  final String dogId;

  RewardedLikeRequest({
    required this.apiKey,
    required this.apiKeyRewarded,
    required this.udid,
    required this.dogId,
  });

  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'apiKeyRewarded': apiKeyRewarded,
        'udid': udid,
        'dogId': dogId,
      };
}
