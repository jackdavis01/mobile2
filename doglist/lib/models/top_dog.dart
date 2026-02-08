/// Model representing a top-ranked dog with its ID and total likes
class TopDog {
  final String dogId;
  final int totalLikes;

  TopDog({
    required this.dogId,
    required this.totalLikes,
  });

  factory TopDog.fromJson(Map<String, dynamic> json) {
    return TopDog(
      dogId: json['dogId'] as String,
      totalLikes: json['totalLikes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dogId': dogId,
      'totalLikes': totalLikes,
    };
  }
}
