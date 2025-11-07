class DogExtendedInfo {
  final String id; // Reference to Dog
  
  // General information
  final String group;
  final String shortDescription;
  final String longDescription;
  final int popularity;
  final int height;
  final int weight;
  final int lifespan;
  final bool rare;
  
  // Physical details (extended - excluding fields already in Dog)
  final int lifespanCategory;
  final int droolingFrequency;
  final int coatLength;
  final bool doubleCoat;
  
  // Behavior ratings (excluding childFriendly and barkingFrequency already in Dog)
  final int familyAffection;
  final int dogSociability;
  final int friendlinessToStrangers;
  final int playfulness;
  final int protectiveInstincts;
  final int adaptability;
  
  // Care requirements (excluding fields already in Dog)
  final int sheddingAmount;
  final int mentalStimulationNeeds;

  DogExtendedInfo({
    required this.id,
    required this.group,
    required this.shortDescription,
    required this.longDescription,
    required this.popularity,
    required this.height,
    required this.weight,
    required this.lifespan,
    required this.rare,
    required this.lifespanCategory,
    required this.droolingFrequency,
    required this.coatLength,
    required this.doubleCoat,
    required this.familyAffection,
    required this.dogSociability,
    required this.friendlinessToStrangers,
    required this.playfulness,
    required this.protectiveInstincts,
    required this.adaptability,
    required this.sheddingAmount,
    required this.mentalStimulationNeeds,
  });

  factory DogExtendedInfo.fromMap(String id, Map<String, dynamic> map) {
    
    return DogExtendedInfo(
      id: id,
      // General
      group: map['general']['group'] as String? ?? '',
      shortDescription: map['general']['shortDescription'] as String? ?? '',
      longDescription: map['general']['longDescription'] as String? ?? '',
      popularity: map['general']['popularity'] as int? ?? 3,
      height: map['general']['height'] as int? ?? 0,
      weight: map['general']['weight'] as int? ?? 0,
      lifespan: map['general']['lifespan'] as int? ?? 0,
      rare: map['general']['rare'] as bool? ?? false,
      // Physical
      lifespanCategory: map['physical']['lifespan'] as int? ?? 3,
      droolingFrequency: map['physical']['droolingFrequency'] as int? ?? 1,
      coatLength: map['physical']['coatLength'] as int? ?? 3,
      doubleCoat: map['physical']['doubleCoat'] as bool? ?? false,
      // Behavior
      familyAffection: map['behavior']['familyAffection'] as int? ?? 3,
      dogSociability: map['behavior']['dogSociability'] as int? ?? 3,
      friendlinessToStrangers: map['behavior']['friendlinessToStrangers'] as int? ?? 3,
      playfulness: map['behavior']['playfulness'] as int? ?? 3,
      protectiveInstincts: map['behavior']['protectiveInstincts'] as int? ?? 3,
      adaptability: map['behavior']['adaptability'] as int? ?? 3,
      // Care
      sheddingAmount: map['care']['sheddingAmount'] as int? ?? 3,
      mentalStimulationNeeds: map['care']['mentalStimulationNeeds'] as int? ?? 3,
    );
  }
}
