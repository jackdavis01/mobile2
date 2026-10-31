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
  String get internetConnectionError => 'Please check your internet connection!';

  @override
  String get reloadButton => 'Reload';

  @override
  String get pictureLoadingError => 'Error during loading picture, check the internet connection';

  @override
  String get errorTitle => 'Error';

  @override
  String get dogDetailsNotAvailableError => 'Dog details are not available.';

  @override
  String get filterSearchHint => 'Search for dog breed...';

  @override
  String get filterErrorMinLength => 'Please enter at least 3 characters to search';

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
    return 'Best: $breedName';
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

  @override
  String get discoveryQuickFiltersTitle => 'Quick Filters';

  @override
  String get discoveryQuickFiltersDescription =>
      'Tap filter chips to quickly find dogs by specific traits like family-friendly or low-maintenance.';

  @override
  String get discoveryListLikeButtonTitle => 'Like Dogs';

  @override
  String get discoveryListLikeButtonDescription =>
      'Tap the thumbs up to like a dog breed. You can give each dog one free like per day.';

  @override
  String get discoveryListFilterButtonTitle => 'Advanced Filters';

  @override
  String get discoveryListFilterButtonDescription =>
      'Tap here to access advanced search and filtering options to find your perfect breed.';

  @override
  String get discoveryListFavoriteTitle => 'Add to Favorites';

  @override
  String get discoveryListFavoriteDescription => 'Tap the heart to save your favorite dog breeds for quick access.';

  @override
  String get discoveryListFavoriteFilterTitle => 'Show Favorites Only';

  @override
  String get discoveryListFavoriteFilterDescription =>
      'Tap this heart icon to filter and show only your favorited breeds.';

  @override
  String get discoveryDetailsZoomTitle => 'Zoom Images';

  @override
  String get discoveryDetailsZoomDescription =>
      'Tap this icon to zoom in and out of the dog breed images for a closer look.';

  @override
  String get discoveryDetailsFavoriteTitle => 'Favorite This Breed';

  @override
  String get discoveryDetailsFavoriteDescription =>
      'Tap the heart icon to add or remove this breed from your favorites list.';

  @override
  String get discoveryDetailsNavigateArrowTitle => 'Browse Picture Types';

  @override
  String get discoveryDetailsNavigateArrowDescription =>
      'Each dog has three types of pictures: Outdoor, Indoor, and Studio. Swipe left or right, or use these arrows to navigate between them.';

  @override
  String get discoveryDetailsVerticalPagingTitle => 'Browse Between Breeds';

  @override
  String get discoveryDetailsVerticalPagingDescription =>
      'Swipe up or down on this page to quickly browse through different dog breeds without going back to the list.';

  @override
  String get discoverySearchBarTitle => 'Search Breeds';

  @override
  String get discoverySearchBarDescription => 'Type a breed name to quickly find specific dogs.';

  @override
  String get discoveryAdvancedFiltersTitle => 'Advanced Filters';

  @override
  String get discoveryAdvancedFiltersDescription => 'Expand sections to filter by size, weight, temperament, and more.';

  @override
  String get discoveryNavBestDogTitle => 'Your Best Dog';

  @override
  String get discoveryNavBestDogDescription => 'Your favorite breed appears here. Tap it to view details.';

  @override
  String get discoveryNavMenuTitle => 'Navigation Menu';

  @override
  String get discoveryNavMenuDescription =>
      'Add or modify best dog, access settings and app information from this menu.';

  @override
  String get featureDiscoverySection => 'Feature Discovery';

  @override
  String get listPageDiscovery => 'List Page';

  @override
  String get detailsPageDiscovery => 'Details Page';

  @override
  String get filterPageDiscovery => 'Filter Page';

  @override
  String get navigationPageDiscovery => 'Navigation';

  @override
  String get featureDiscoveryHelpText =>
      'Enable tutorials to see helpful tips on each page. Tutorials automatically hide after completion but can be re-enabled here.';

  @override
  String get onboardingScreen1Title => 'Welcome to Dog List!';

  @override
  String get onboardingScreen1Description =>
      'Discover 209 dog breeds and find your perfect companion. Explore detailed information, beautiful photos, and comprehensive breed characteristics.';

  @override
  String get onboardingScreen2Title => 'Browse Dog Breeds';

  @override
  String get onboardingScreen2Description =>
      'Scroll through all dog breeds with ease. Use quick filters and favorites to find exactly what you\'re looking for.';

  @override
  String get onboardingScreen2Feature1 => 'Mark favorites';

  @override
  String get onboardingScreen2Feature2 => 'Advanced filtering';

  @override
  String get onboardingScreen2Feature3 => 'Quick filter chips';

  @override
  String get onboardingTopDogsTitle => 'Top 3 Most-Liked Breeds';

  @override
  String get onboardingTopDogsDescription =>
      'See the three breeds with the most likes. Tap a photo to explore a breed, or continue to the list and filters.';

  @override
  String get onboardingTopDogsFeature1 => 'Ranked by community likes';

  @override
  String get onboardingTopDogsFeature2 => 'Tap a photo for breed details';

  @override
  String get onboardingTopDogsFeature3 => 'Browse or filter all breeds';

  @override
  String get onboardingScreen3Title => 'Advanced Filtering';

  @override
  String get onboardingScreen3Description =>
      'Filter breeds by size, temperament, coat type, and more. Find the perfect match for your lifestyle.';

  @override
  String get onboardingScreen3Feature1 => 'Search by name';

  @override
  String get onboardingScreen3Feature2 => 'Filter by traits';

  @override
  String get onboardingScreen3Feature3 => 'Temperament filters';

  @override
  String get onboardingScreen4Title => 'Detailed Breed Information';

  @override
  String get onboardingScreen4Description =>
      'View stunning photos of each breed in three picture types: Outdoor, Indoor, and Studio. Swipe between breeds and images effortlessly.';

  @override
  String get onboardingScreen4Feature1 => 'Swipe through photos';

  @override
  String get onboardingScreen4Feature2 => 'Zoom images';

  @override
  String get onboardingScreen4Feature3 => 'Add to favorites';

  @override
  String get onboardingScreen5Title => 'Deep Dive Into Breeds';

  @override
  String get onboardingScreen5Description =>
      'Learn everything about each breed including physical traits, behavior profile, care requirements, and fascinating facts.';

  @override
  String get onboardingScreen5Feature1 => 'Physical traits';

  @override
  String get onboardingScreen5Feature2 => 'Behavior profile';

  @override
  String get onboardingScreen5Feature3 => 'Did You Know facts';

  @override
  String get onboardingScreen6Title => 'Easy Navigation';

  @override
  String get onboardingScreen6Description =>
      'Access app features quickly from the navigation drawer and keep your selected Best Dog close at hand.';

  @override
  String get onboardingScreen6Feature1 => 'Your selected Best Dog';

  @override
  String get onboardingScreen6Feature2 => 'Quick filter access';

  @override
  String get onboardingScreen6Feature3 => 'Settings & info';

  @override
  String get onboardingCompareTitle => 'Compare Breeds';

  @override
  String get onboardingCompareDescription =>
      'Pin two breeds to compare them side by side. Your pinned breeds stay at the top as you browse.';

  @override
  String get onboardingCompareFeature1 => 'Sort by name, likes, or size';

  @override
  String get onboardingCompareFeature2 => 'Choose either sort direction';

  @override
  String get onboardingCompareFeature3 => 'Tap a photo to open breed details';

  @override
  String get onboardingScreen7Title => 'Customize Your Experience';

  @override
  String get onboardingScreen7Description =>
      'Personalize the app to your preferences. Control quick filter visibility, feature discovery, and more.';

  @override
  String get onboardingScreen7Feature1 => 'Quick filter options';

  @override
  String get onboardingScreen7Feature2 => 'Feature discovery';

  @override
  String get onboardingScreen7Feature3 => 'Personalization';

  @override
  String get onboardingScreen8Title => 'Learn More';

  @override
  String get onboardingScreen8Description =>
      'Access app information, version details, and developer info. You can replay this tour anytime from the Info page.';

  @override
  String get onboardingScreen8Feature1 => 'App information';

  @override
  String get onboardingScreen8Feature2 => 'Version details';

  @override
  String get onboardingScreen8Feature3 => 'Replay tour anytime';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingScreensSection => 'Onboarding Screens';

  @override
  String get onboardingScreensStart => 'Start';

  @override
  String get likeAlreadyLikedTitle => 'Already Liked!';

  @override
  String likeAlreadyLikedMessage(String dogName) {
    return 'You\'ve already liked $dogName today.';
  }

  @override
  String get likeCanLikeSoon => 'You can like this dog again soon!';

  @override
  String get likeCanLikeAgainIn => 'You can like again in:';

  @override
  String likeComeBackAt(String time) {
    return 'Come back at $time to like again!';
  }

  @override
  String get likeDialogOk => 'OK';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
      zero: '0 likes',
    );
    return '$_temp0';
  }

  @override
  String likeFailedToLike(String dogName) {
    return 'Failed to like $dogName';
  }

  @override
  String get likeRetry => 'Retry';

  @override
  String likeSuccess(String dogName) {
    return 'Liked $dogName! 👍';
  }

  @override
  String likeFailedToLoadCounts(String error) {
    return 'Failed to load like counts: $error';
  }

  @override
  String likeFailedToLoadSpecificCounts(String error) {
    return 'Failed to load specific like counts: $error';
  }

  @override
  String get likeFailedGeneric => 'Failed to like this dog';

  @override
  String get likeUnexpectedError => 'An unexpected error occurred';

  @override
  String get likeWebDialogTitle => 'Download the App';

  @override
  String get likeWebDialogMessage =>
      'If you want to like the dogs, please download the App from the Google Play Store or from the Apple App Store.';

  @override
  String get likeRewardedDialogTitle => 'Already Liked Today!';

  @override
  String get likeRewardedWatchAdButton => 'Watch Ad to Like Now';

  @override
  String get likeRewardedLoading => 'Loading...';

  @override
  String get likeRewardedProcessing => 'Processing...';

  @override
  String get likeRewardedNotNow => 'Not Now';

  @override
  String get likeRewardedClose => 'Close';

  @override
  String get likeRewardedAdNotReady => 'Ad not ready yet. Please try again in a moment.';

  @override
  String get likeRewardedFailed => 'Failed to submit like. Please try again.';

  @override
  String get likeRewardedIncomplete => 'You need to watch the full ad to like this dog again.';

  @override
  String get topDogsTitle => 'Top 3 dogs';

  @override
  String get topDogsNoDataAvailable => 'No top dogs available';

  @override
  String get topDogsRetry => 'Retry';

  @override
  String get topDogsGoToList => 'Go to Dog List';

  @override
  String get topDogsBreedsButton => 'Dog breeds';

  @override
  String get topDogsFilterButton => 'Filter breeds';

  @override
  String topDogsRank(int rank) {
    return 'Top $rank';
  }

  @override
  String get topDogsDogNotFound => 'Dog not found';

  @override
  String get topDogsOfflineCache => 'Showing cached data (offline)';

  @override
  String topDogsLoadError(String error) {
    return 'Failed to load top dogs: $error';
  }

  @override
  String get topDogsUnableToLoad => 'Unable to load top dogs';

  @override
  String get compareTitle => 'Compare Breeds';

  @override
  String get compareButton => 'Compare';

  @override
  String get compareInstructions => 'Pin 2 breeds to compare them side by side.';

  @override
  String get compareMaxReached => 'You can pin only 2 breeds. Unpin one to pick another.';

  @override
  String get temperament => 'Temperament';

  @override
  String get compareUnpin => 'Unpin';

  @override
  String get compareSortTitle => 'Sort breeds';

  @override
  String get compareSortUnsorted => 'Unsorted';

  @override
  String get compareSortAlphabetical => 'Alphabetical';

  @override
  String get compareSortLikes => 'Number of likes';

  @override
  String get compareSortNamesAscending => 'A-Z';

  @override
  String get compareSortNamesDescending => 'Z-A';

  @override
  String get compareSortLikesAscending => 'Fewest first';

  @override
  String get compareSortLikesDescending => 'Most first';

  @override
  String get compareSortSizeAscending => 'Smallest first';

  @override
  String get compareSortSizeDescending => 'Largest first';

  @override
  String get compareSortDone => 'Done';

  @override
  String get crossbreedButton => 'Create AI crossbreed';

  @override
  String get crossbreedTitle => 'AI crossbreed';

  @override
  String get crossbreedExplanation =>
      'Watch a short rewarded ad to get an AI-generated image of a crossbreed of these two breeds. If this pair was created before, the existing image is shown again.';

  @override
  String get crossbreedAiLabel => 'AI-generated image';

  @override
  String get crossbreedGenerate => 'Watch ad and create';

  @override
  String get crossbreedWatchAdAgain => 'Watch ad again';

  @override
  String get crossbreedRetry => 'Retry';

  @override
  String get crossbreedCancel => 'Cancel';

  @override
  String get crossbreedClose => 'Close';

  @override
  String get crossbreedLoadingPreview => 'Loading breed photos…';

  @override
  String get crossbreedPreviewError => 'Could not load the breed photos. Check your connection and try again.';

  @override
  String get crossbreedPreparing => 'Preparing your request…';

  @override
  String get crossbreedLoadingAd => 'Loading the ad…';

  @override
  String get crossbreedRedeeming => 'Checking your reward…';

  @override
  String get crossbreedGenerating =>
      'Creating the crossbreed image. This can take a minute; you can leave this screen.';

  @override
  String get crossbreedReady => 'Your crossbreed is ready';

  @override
  String get crossbreedAdNotCompleted => 'The ad was closed before the reward. Watch the full ad to create the image.';

  @override
  String get crossbreedAdUnavailable => 'No ad is available right now. Please try again a little later.';

  @override
  String get crossbreedAdsUnsupported => 'Creating crossbreeds needs rewarded ads, which are not available here.';

  @override
  String get crossbreedGenerationPaused => 'Creating new crossbreeds is paused right now.';

  @override
  String get crossbreedNotAvailable => 'A crossbreed can\'t be created for this pair right now.';

  @override
  String get crossbreedLimitReached => 'The crossbreed limit was reached for now. Please try again later.';

  @override
  String get crossbreedTemporaryError =>
      'The service is temporarily unavailable. Your reward is kept, so you can retry without another ad.';

  @override
  String get crossbreedFailed => 'The image could not be created. You can try again with a new ad.';

  @override
  String get crossbreedPairUnavailable => 'This crossbreed is not available.';

  @override
  String get crossbreedSourceChanged => 'The breed photos were updated. Please review them and try again.';

  @override
  String get crossbreedExpired => 'This request expired. Please start again.';

  @override
  String get crossbreedOtherPending => 'Another crossbreed is still in progress.';

  @override
  String get crossbreedPhotoUnavailable => 'Photo unavailable';

  @override
  String get crossbreedImageRetry => 'Retry image';

  @override
  String get crossbreedOpenResult => 'View image';

  @override
  String get crossbreedQueued => 'Waiting in line to create the image…';

  @override
  String get crossbreedProcessing => 'Creating the image…';

  @override
  String get crossbreedJoinedNote => 'This pair was already being created, so your request joined it.';

  @override
  String get crossbreedReusedNote => 'This image was created earlier for this pair and is shown again.';

  @override
  String get crossbreedNoLongerAvailable => 'This crossbreed image is no longer available.';

  @override
  String crossbreedBasedOn(String first, String second) {
    return 'Based on photos of $first and $second';
  }

  @override
  String get crossbreedCancelOther => 'Cancel the other request';
}
