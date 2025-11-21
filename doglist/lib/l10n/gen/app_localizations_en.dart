// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get materialAppTitle => 'Dog List';

  @override
  String get breedListTitle => 'Dog Breed List';

  @override
  String get filterTitle => 'Filter';

  @override
  String get internetConnectionError =>
      'Please check your internet connection!';

  @override
  String get reloadButton => 'Reload';

  @override
  String get pictureLoadingError =>
      'Error during loading picture, check the internet connection';

  @override
  String get errorTitle => 'Error';

  @override
  String get dogDetailsNotAvailableError => 'Dog details are not available.';

  @override
  String get filterSearchHint => 'Search for dog breed...';

  @override
  String get filterErrorMinLength =>
      'Please enter at least 3 characters to search';

  @override
  String filterMatchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches found',
      one: '1 match found',
      zero: 'No matches found',
    );
    return '$_temp0';
  }

  @override
  String get clearAllFilters => 'Clear All Filters';

  @override
  String get breedInfoNotAvailable => 'Dog information not available';

  @override
  String get breedInfoLoadError => 'Could not load extended information';

  @override
  String breedInfoLoadErrorDetails(String error) {
    return 'Error loading information: $error';
  }

  @override
  String get quickOverview => 'Quick Overview';

  @override
  String get aboutThisBreed => 'About This Breed';

  @override
  String get physicalTraits => 'Physical Traits';

  @override
  String get behaviorProfile => 'Behavior Profile';

  @override
  String get careRequirements => 'Care Requirements';

  @override
  String get rareBreed => 'Rare Breed';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get lifespan => 'Lifespan';

  @override
  String get size => 'Size';

  @override
  String get coatStyle => 'Coat Style';

  @override
  String get coatTexture => 'Coat Texture';

  @override
  String get coatLength => 'Coat Length';

  @override
  String get doubleCoat => 'Double Coat';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get drooling => 'Drooling';

  @override
  String get familyAffection => 'Family Affection';

  @override
  String get childFriendly => 'Child Friendly';

  @override
  String get dogSociability => 'Dog Sociability';

  @override
  String get friendlyToStrangers => 'Friendly to Strangers';

  @override
  String get playfulness => 'Playfulness';

  @override
  String get protectiveInstincts => 'Protective Instincts';

  @override
  String get adaptability => 'Adaptability';

  @override
  String get barkingFrequency => 'Barking Frequency';

  @override
  String get sheddingAmount => 'Shedding Amount';

  @override
  String get groomingFrequency => 'Grooming Frequency';

  @override
  String get exerciseNeeds => 'Exercise Needs';

  @override
  String get mentalStimulation => 'Mental Stimulation';

  @override
  String get trainingDifficulty => 'Training Difficulty';

  @override
  String get sizeExtraSmall => 'Extra Small (< 10 lbs)';

  @override
  String get sizeSmall => 'Small (10-25 lbs)';

  @override
  String get sizeMedium => 'Medium (25-50 lbs)';

  @override
  String get sizeLarge => 'Large (50-100 lbs)';

  @override
  String get sizeExtraLarge => 'Extra Large (100+ lbs)';

  @override
  String get coatLengthVeryShort => 'Very Short';

  @override
  String get coatLengthShort => 'Short';

  @override
  String get coatLengthMedium => 'Medium';

  @override
  String get coatLengthLong => 'Long';

  @override
  String get coatLengthVeryLong => 'Very Long';

  @override
  String get unknown => 'Unknown';

  @override
  String get ratingVeryLow => 'Very Low';

  @override
  String get ratingLow => 'Low';

  @override
  String get ratingModerate => 'Moderate';

  @override
  String get ratingHigh => 'High';

  @override
  String get ratingVeryHigh => 'Very High';

  @override
  String get quickFilters => 'Quick Filters (select 0-3):';

  @override
  String get familyFriendly => 'Family-Friendly';

  @override
  String get lowMaintenance => 'Low Maintenance';

  @override
  String get activeDogs => 'Active Dogs';

  @override
  String get apartmentFriendly => 'Apartment-Friendly';

  @override
  String get firstTimeOwners => 'First-Time Owners';

  @override
  String get cleanTidy => 'Clean & Tidy';

  @override
  String drawerFavourite(String breedName) {
    return 'Favorite: $breedName';
  }

  @override
  String drawerLikes(int count) {
    return 'Likes: $count';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get infoTitle => 'Info';

  @override
  String get settingsComingSoon => 'Settings Page - Coming Soon';

  @override
  String get infoComingSoon => 'Info Page - Coming Soon';

  @override
  String get none => 'None';

  @override
  String get quickFilterVisibilitySetting => 'Quick Filter Chips Visibility';

  @override
  String get quickFilterNone => 'None';

  @override
  String get quickFilterFirstXTimes => 'First 3 Times';

  @override
  String get quickFilterAlways => 'Always';

  @override
  String get quickFilterHideDialogTitle => 'Quick Filter Preferences';

  @override
  String get quickFilterHideDialogMessage =>
      'Choose your preference for the quick filter bar. You can change this anytime in Settings.';

  @override
  String get quickFilterHideYes => 'Hide filters';

  @override
  String get quickFilterHideNo => 'Always show';

  @override
  String get quickFilterCancel => 'Cancel';

  @override
  String get infoApplicationInformation => 'Application Information';

  @override
  String get infoApplicationName => 'Application name:';

  @override
  String get infoPackageName => 'Package name:';

  @override
  String get infoVersionNumber => 'Version number:';

  @override
  String get infoBuildNumber => 'Build number:';

  @override
  String get infoBuildMode => 'Build mode:';

  @override
  String get infoPlatform => 'Platform:';

  @override
  String get infoPrerelease => 'Prerelease:';

  @override
  String get infoChannel => 'Channel:';

  @override
  String get infoAuthor => 'Author:';
}
