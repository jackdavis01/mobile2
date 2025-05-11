import 'dog_images.dart';

class Dog {
  final String id;
  final String name;
  final String coatStyle;
  final String coatTexture;
  final List<String> personalityTraits;
  final DogImages images;

  Dog({
    required this.id,
    required this.name,
    required this.coatStyle,
    required this.coatTexture,
    required this.personalityTraits,
    required this.images,
  });

  factory Dog.fromMap(Map<String, dynamic> map) {
    return Dog(
      id: map['id'] as String,
      name: map['general']['name'] as String,
      coatStyle: map['physical']['coatStyle'] as String,
      coatTexture: map['physical']['coatTexture'] as String,
      personalityTraits: List<String>.from(map['general']['personalityTraits']),
      images: DogImages.fromMap(map['images'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'general': {
        'name': name,
        'personalityTraits': personalityTraits,
      },
      'physical': {
        'coatStyle': coatStyle,
        'coatTexture': coatTexture,
      },
      'images': images.toMap(),
    };
  }
}