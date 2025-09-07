class DogImages {
  final String smallOutdoors;
  final String largeOutdoors;
  final String largeIndoors;
  final String largeStudio;

  DogImages({
    required this.smallOutdoors,
    required this.largeOutdoors,
    required this.largeIndoors,
    required this.largeStudio,
  });

  factory DogImages.fromMap(Map<String, dynamic> map) {
    return DogImages(
      smallOutdoors: map['small']['outdoors'] as String,
      largeOutdoors: map['large']['outdoors'] as String,
      largeIndoors: map['large']['indoors'] as String,
      largeStudio: map['large']['studio'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'small': {
        'outdoors': smallOutdoors,
      },
      'large': {
        'outdoors': largeOutdoors,
        'indoors': largeIndoors,
        'studio': largeStudio,
      },
    };
  }
}
