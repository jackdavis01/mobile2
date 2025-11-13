import 'dog_images.dart';

class Dog {
  // Display fields (current)
  final String id;
  final String name;
  final String coatStyle;
  final String coatTexture;
  final List<String> personalityTraits;
  final DogImages images;
  
  // Hybrid fields: Add filtering fields for quick filters and basic info
  final int childFriendly;        // For "Family-Friendly" filter
  final int groomingFrequency;    // For "Low Maintenance" filter
  final int exerciseNeeds;        // For "Active Dogs" filter
  final int size;                 // For "Apartment-Friendly" filter
  final int barkingFrequency;     // For "Apartment-Friendly" filter
  final int trainingDifficulty;   // For "First-Time Owners" filter
  final int sheddingAmount;       // For "Clean & Tidy" filter
  final int droolingFrequency;    // For "Clean & Tidy" filter

  Dog({
    required this.id,
    required this.name,
    required this.coatStyle,
    required this.coatTexture,
    required this.personalityTraits,
    required this.images,
    required this.childFriendly,
    required this.groomingFrequency,
    required this.exerciseNeeds,
    required this.size,
    required this.barkingFrequency,
    required this.trainingDifficulty,
    required this.sheddingAmount,
    required this.droolingFrequency,
  });

  factory Dog.fromMap(Map<String, dynamic> map) {
    // Helper function to safely get int with default value
    int safeGetInt(Map<String, dynamic> data, List<String> keys, int defaultValue) {
      try {
        dynamic value = data;
        for (String key in keys) {
          if (value is Map<String, dynamic> && value.containsKey(key)) {
            value = value[key];
          } else {
            return defaultValue;
          }
        }
        return value is int ? value : defaultValue;
      } catch (e) {
        return defaultValue;
      }
    }

    return Dog(
      id: map['id'] as String,
      name: map['general']['name'] as String,
      coatStyle: map['physical']['coatStyle'] as String,
      coatTexture: map['physical']['coatTexture'] as String,
      personalityTraits: List<String>.from(map['general']['personalityTraits']),
      images: DogImages.fromMap(map['images'] as Map<String, dynamic>),
      // Hybrid fields from JSON with safe parsing
      childFriendly: safeGetInt(map, ['behavior', 'childFriendly'], 3),
      groomingFrequency: safeGetInt(map, ['care', 'groomingFrequency'], 3),
      exerciseNeeds: safeGetInt(map, ['care', 'exerciseNeeds'], 3),
      size: safeGetInt(map, ['physical', 'size'], 3),
      barkingFrequency: safeGetInt(map, ['behavior', 'barkingFrequency'], 3),
      trainingDifficulty: safeGetInt(map, ['care', 'trainingDifficulty'], 3),
      sheddingAmount: safeGetInt(map, ['care', 'sheddingAmount'], 3),
      droolingFrequency: safeGetInt(map, ['physical', 'droolingFrequency'], 3),
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
        'size': size,
        'droolingFrequency': droolingFrequency,
      },
      'behavior': {
        'childFriendly': childFriendly,
        'barkingFrequency': barkingFrequency,
      },
      'care': {
        'groomingFrequency': groomingFrequency,
        'exerciseNeeds': exerciseNeeds,
        'trainingDifficulty': trainingDifficulty,
        'sheddingAmount': sheddingAmount,
      },
      'images': images.toMap(),
    };
  }
}