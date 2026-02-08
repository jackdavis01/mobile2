/// Response from POST /api/v1/like endpoint.
/// Contains the result of a like operation.
class LikeResponse {
  final bool success;
  final String? dogId;
  final int? totalLikes;
  final DateTime? canLikeAgainAt;
  final String? error;
  final int? remainingSeconds;

  LikeResponse({
    required this.success,
    this.dogId,
    this.totalLikes,
    this.canLikeAgainAt,
    this.error,
    this.remainingSeconds,
  });

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    return LikeResponse(
      success: json['success'] as bool,
      dogId: json['dogId'] as String?,
      totalLikes: json['totalLikes'] as int?,
      canLikeAgainAt: json['canLikeAgainAt'] != null
          ? DateTime.parse(json['canLikeAgainAt'] as String).toUtc()
          : null,
      error: json['error'] as String?,
      remainingSeconds: json['remainingSeconds'] as int?,
    );
  }

  @override
  String toString() => 'LikeResponse(success: $success, dogId: $dogId, '
      'totalLikes: $totalLikes, error: $error)';
}
