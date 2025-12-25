import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The title for the App
  ///
  /// In en, this message translates to:
  /// **'Dog List'**
  String get materialAppTitle;

  /// The title for the main list page
  ///
  /// In en, this message translates to:
  /// **'Dog Breed List'**
  String get breedListTitle;

  /// The title for the filter page
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// Message for the internet connection issues
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection!'**
  String get internetConnectionError;

  /// Text on the Reload button
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reloadButton;

  /// Message for the picture loading error
  ///
  /// In en, this message translates to:
  /// **'Error during loading picture, check the internet connection'**
  String get pictureLoadingError;

  /// A generic title for an error page
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Error message shown when dog details cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Dog details are not available.'**
  String get dogDetailsNotAvailableError;

  /// Hint text for the filter search input field
  ///
  /// In en, this message translates to:
  /// **'Search for dog breed...'**
  String get filterSearchHint;

  /// Error message when search input is less than 3 characters
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 3 characters to search'**
  String get filterErrorMinLength;

  /// Shows the number of matching results
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No matches found} =1{1 match found} other{{count} matches found}}'**
  String filterMatchesCount(int count);

  /// Button text to clear all filters
  ///
  /// In en, this message translates to:
  /// **'Clear All Filters'**
  String get clearAllFilters;

  /// Error message when breed information is not available
  ///
  /// In en, this message translates to:
  /// **'Dog information not available'**
  String get breedInfoNotAvailable;

  /// Error message when extended breed information fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load extended information'**
  String get breedInfoLoadError;

  /// Error message with details when loading information fails
  ///
  /// In en, this message translates to:
  /// **'Error loading information: {error}'**
  String breedInfoLoadErrorDetails(String error);

  /// Section title for quick overview
  ///
  /// In en, this message translates to:
  /// **'Quick Overview'**
  String get quickOverview;

  /// Section title for breed description
  ///
  /// In en, this message translates to:
  /// **'About This Breed'**
  String get aboutThisBreed;

  /// Section title for physical traits
  ///
  /// In en, this message translates to:
  /// **'Physical Traits'**
  String get physicalTraits;

  /// Section title for behavior profile
  ///
  /// In en, this message translates to:
  /// **'Behavior Profile'**
  String get behaviorProfile;

  /// Section title for care requirements
  ///
  /// In en, this message translates to:
  /// **'Care Requirements'**
  String get careRequirements;

  /// Label for rare breeds
  ///
  /// In en, this message translates to:
  /// **'Rare Breed'**
  String get rareBreed;

  /// Label for height measurement
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// Label for weight measurement
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Label for lifespan
  ///
  /// In en, this message translates to:
  /// **'Lifespan'**
  String get lifespan;

  /// Label for size trait
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// Label for coat style trait
  ///
  /// In en, this message translates to:
  /// **'Coat Style'**
  String get coatStyle;

  /// Label for coat texture trait
  ///
  /// In en, this message translates to:
  /// **'Coat Texture'**
  String get coatTexture;

  /// Label for coat length trait
  ///
  /// In en, this message translates to:
  /// **'Coat Length'**
  String get coatLength;

  /// Label for double coat trait
  ///
  /// In en, this message translates to:
  /// **'Double Coat'**
  String get doubleCoat;

  /// Yes answer
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No answer
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Label for drooling rating
  ///
  /// In en, this message translates to:
  /// **'Drooling'**
  String get drooling;

  /// Label for family affection rating
  ///
  /// In en, this message translates to:
  /// **'Family Affection'**
  String get familyAffection;

  /// Label for child friendly rating
  ///
  /// In en, this message translates to:
  /// **'Child Friendly'**
  String get childFriendly;

  /// Label for dog sociability rating
  ///
  /// In en, this message translates to:
  /// **'Dog Sociability'**
  String get dogSociability;

  /// Label for friendliness to strangers rating
  ///
  /// In en, this message translates to:
  /// **'Friendly to Strangers'**
  String get friendlyToStrangers;

  /// Label for playfulness rating
  ///
  /// In en, this message translates to:
  /// **'Playfulness'**
  String get playfulness;

  /// Label for protective instincts rating
  ///
  /// In en, this message translates to:
  /// **'Protective Instincts'**
  String get protectiveInstincts;

  /// Label for adaptability rating
  ///
  /// In en, this message translates to:
  /// **'Adaptability'**
  String get adaptability;

  /// Label for barking frequency rating
  ///
  /// In en, this message translates to:
  /// **'Barking Frequency'**
  String get barkingFrequency;

  /// Label for shedding amount rating
  ///
  /// In en, this message translates to:
  /// **'Shedding Amount'**
  String get sheddingAmount;

  /// Label for grooming frequency rating
  ///
  /// In en, this message translates to:
  /// **'Grooming Frequency'**
  String get groomingFrequency;

  /// Label for exercise needs rating
  ///
  /// In en, this message translates to:
  /// **'Exercise Needs'**
  String get exerciseNeeds;

  /// Label for mental stimulation rating
  ///
  /// In en, this message translates to:
  /// **'Mental Stimulation'**
  String get mentalStimulation;

  /// Label for training difficulty rating
  ///
  /// In en, this message translates to:
  /// **'Training Difficulty'**
  String get trainingDifficulty;

  /// Size category: extra small
  ///
  /// In en, this message translates to:
  /// **'Extra Small (< 10 lbs)'**
  String get sizeExtraSmall;

  /// Size category: small
  ///
  /// In en, this message translates to:
  /// **'Small (10-25 lbs)'**
  String get sizeSmall;

  /// Size category: medium
  ///
  /// In en, this message translates to:
  /// **'Medium (25-50 lbs)'**
  String get sizeMedium;

  /// Size category: large
  ///
  /// In en, this message translates to:
  /// **'Large (50-100 lbs)'**
  String get sizeLarge;

  /// Size category: extra large
  ///
  /// In en, this message translates to:
  /// **'Extra Large (100+ lbs)'**
  String get sizeExtraLarge;

  /// Coat length: very short
  ///
  /// In en, this message translates to:
  /// **'Very Short'**
  String get coatLengthVeryShort;

  /// Coat length: short
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get coatLengthShort;

  /// Coat length: medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get coatLengthMedium;

  /// Coat length: long
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get coatLengthLong;

  /// Coat length: very long
  ///
  /// In en, this message translates to:
  /// **'Very Long'**
  String get coatLengthVeryLong;

  /// Unknown value
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Rating level: very low
  ///
  /// In en, this message translates to:
  /// **'Very Low'**
  String get ratingVeryLow;

  /// Rating level: low
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get ratingLow;

  /// Rating level: moderate
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get ratingModerate;

  /// Rating level: high
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get ratingHigh;

  /// Rating level: very high
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get ratingVeryHigh;

  /// Quick filters section title
  ///
  /// In en, this message translates to:
  /// **'Quick Filters (select 0-3):'**
  String get quickFilters;

  /// Quick filter: family friendly dogs
  ///
  /// In en, this message translates to:
  /// **'Family-Friendly'**
  String get familyFriendly;

  /// Quick filter: low maintenance dogs
  ///
  /// In en, this message translates to:
  /// **'Low Maintenance'**
  String get lowMaintenance;

  /// Quick filter: active dogs
  ///
  /// In en, this message translates to:
  /// **'Active Dogs'**
  String get activeDogs;

  /// Quick filter: apartment friendly dogs
  ///
  /// In en, this message translates to:
  /// **'Apartment-Friendly'**
  String get apartmentFriendly;

  /// Quick filter: suitable for first-time owners
  ///
  /// In en, this message translates to:
  /// **'First-Time Owners'**
  String get firstTimeOwners;

  /// Quick filter: low shedding and minimal drooling dogs
  ///
  /// In en, this message translates to:
  /// **'Clean & Tidy'**
  String get cleanTidy;

  /// Navigation drawer header: best breed
  ///
  /// In en, this message translates to:
  /// **'Best: {breedName}'**
  String drawerFavourite(String breedName);

  /// Navigation drawer header: number of likes
  ///
  /// In en, this message translates to:
  /// **'Likes: {count}'**
  String drawerLikes(int count);

  /// Title for the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title for the info page
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTitle;

  /// Placeholder message for settings page
  ///
  /// In en, this message translates to:
  /// **'Settings Page - Coming Soon'**
  String get settingsComingSoon;

  /// Placeholder message for info page
  ///
  /// In en, this message translates to:
  /// **'Info Page - Coming Soon'**
  String get infoComingSoon;

  /// Displayed when there is no value
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Settings label for quick filter visibility
  ///
  /// In en, this message translates to:
  /// **'Quick Filter Chips Visibility'**
  String get quickFilterVisibilitySetting;

  /// Quick filter visibility option: none
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get quickFilterNone;

  /// Quick filter visibility option: first 3 times
  ///
  /// In en, this message translates to:
  /// **'First 3 Times'**
  String get quickFilterFirstXTimes;

  /// Quick filter visibility option: always
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get quickFilterAlways;

  /// Dialog title for hiding quick filter bar
  ///
  /// In en, this message translates to:
  /// **'Quick Filter Preferences'**
  String get quickFilterHideDialogTitle;

  /// Dialog message explaining quick filter hiding
  ///
  /// In en, this message translates to:
  /// **'Choose your preference for the quick filter bar. You can change this anytime in Settings.'**
  String get quickFilterHideDialogMessage;

  /// Dialog button to hide quick filters
  ///
  /// In en, this message translates to:
  /// **'Hide filters'**
  String get quickFilterHideYes;

  /// Dialog button to make quick filters always visible
  ///
  /// In en, this message translates to:
  /// **'Always show'**
  String get quickFilterHideNo;

  /// Dialog button to cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get quickFilterCancel;

  /// Info page section title
  ///
  /// In en, this message translates to:
  /// **'Application Information'**
  String get infoApplicationInformation;

  /// Info page application name label
  ///
  /// In en, this message translates to:
  /// **'Application name:'**
  String get infoApplicationName;

  /// Info page package name label
  ///
  /// In en, this message translates to:
  /// **'Package name:'**
  String get infoPackageName;

  /// Info page version number label
  ///
  /// In en, this message translates to:
  /// **'Version number:'**
  String get infoVersionNumber;

  /// Info page build number label
  ///
  /// In en, this message translates to:
  /// **'Build number:'**
  String get infoBuildNumber;

  /// Info page build mode label
  ///
  /// In en, this message translates to:
  /// **'Build mode:'**
  String get infoBuildMode;

  /// Info page platform label
  ///
  /// In en, this message translates to:
  /// **'Platform:'**
  String get infoPlatform;

  /// Info page prerelease label
  ///
  /// In en, this message translates to:
  /// **'Prerelease:'**
  String get infoPrerelease;

  /// Info page channel label
  ///
  /// In en, this message translates to:
  /// **'Channel:'**
  String get infoChannel;

  /// Info page author label
  ///
  /// In en, this message translates to:
  /// **'Author:'**
  String get infoAuthor;

  /// Feature discovery title for quick filters on list page
  ///
  /// In en, this message translates to:
  /// **'Quick Filters'**
  String get discoveryQuickFiltersTitle;

  /// Feature discovery description for quick filters
  ///
  /// In en, this message translates to:
  /// **'Tap filter chips to quickly find dogs by specific traits like family-friendly or low-maintenance.'**
  String get discoveryQuickFiltersDescription;

  /// Feature discovery title for filter button on list page
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get discoveryListFilterButtonTitle;

  /// Feature discovery description for filter button on list page
  ///
  /// In en, this message translates to:
  /// **'Tap here to access advanced search and filtering options to find your perfect breed.'**
  String get discoveryListFilterButtonDescription;

  /// Feature discovery title for favorite button on list page
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get discoveryListFavoriteTitle;

  /// Feature discovery description for favorite button on list page
  ///
  /// In en, this message translates to:
  /// **'Tap the heart to save your favorite dog breeds for quick access.'**
  String get discoveryListFavoriteDescription;

  /// Feature discovery title for favorite filter button on list page
  ///
  /// In en, this message translates to:
  /// **'Show Favorites Only'**
  String get discoveryListFavoriteFilterTitle;

  /// Feature discovery description for favorite filter button on list page
  ///
  /// In en, this message translates to:
  /// **'Tap this heart icon to filter and show only your favorited breeds.'**
  String get discoveryListFavoriteFilterDescription;

  /// Feature discovery title for zoom icon on details page
  ///
  /// In en, this message translates to:
  /// **'Zoom Images'**
  String get discoveryDetailsZoomTitle;

  /// Feature discovery description for zoom icon on details page
  ///
  /// In en, this message translates to:
  /// **'Tap this icon to zoom in and out of the dog breed images for a closer look.'**
  String get discoveryDetailsZoomDescription;

  /// Feature discovery title for favorite button on details page
  ///
  /// In en, this message translates to:
  /// **'Favorite This Breed'**
  String get discoveryDetailsFavoriteTitle;

  /// Feature discovery description for favorite button on details page
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon to add or remove this breed from your favorites list.'**
  String get discoveryDetailsFavoriteDescription;

  /// Feature discovery title for navigation arrow on details page
  ///
  /// In en, this message translates to:
  /// **'Browse Picture Types'**
  String get discoveryDetailsNavigateArrowTitle;

  /// Feature discovery description for navigation arrow on details page
  ///
  /// In en, this message translates to:
  /// **'Each dog has three types of pictures: Outdoor, Indoor, and Studio. Swipe left or right, or use these arrows to navigate between them.'**
  String get discoveryDetailsNavigateArrowDescription;

  /// Feature discovery title for vertical paging on details page
  ///
  /// In en, this message translates to:
  /// **'Browse Between Breeds'**
  String get discoveryDetailsVerticalPagingTitle;

  /// Feature discovery description for vertical paging on details page
  ///
  /// In en, this message translates to:
  /// **'Swipe up or down on this page to quickly browse through different dog breeds without going back to the list.'**
  String get discoveryDetailsVerticalPagingDescription;

  /// Feature discovery title for search bar on filter page
  ///
  /// In en, this message translates to:
  /// **'Search Breeds'**
  String get discoverySearchBarTitle;

  /// Feature discovery description for search bar
  ///
  /// In en, this message translates to:
  /// **'Type a breed name to quickly find specific dogs.'**
  String get discoverySearchBarDescription;

  /// Feature discovery title for advanced filters on filter page
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get discoveryAdvancedFiltersTitle;

  /// Feature discovery description for advanced filters
  ///
  /// In en, this message translates to:
  /// **'Expand sections to filter by size, weight, temperament, and more.'**
  String get discoveryAdvancedFiltersDescription;

  /// Feature discovery title for best dog on navigation drawer
  ///
  /// In en, this message translates to:
  /// **'Your Best Dog'**
  String get discoveryNavBestDogTitle;

  /// Feature discovery description for best dog
  ///
  /// In en, this message translates to:
  /// **'Your favorite breed appears here. Tap it to view details.'**
  String get discoveryNavBestDogDescription;

  /// Feature discovery title for navigation menu icon
  ///
  /// In en, this message translates to:
  /// **'Navigation Menu'**
  String get discoveryNavMenuTitle;

  /// Feature discovery description for navigation menu
  ///
  /// In en, this message translates to:
  /// **'Add or modify best dog, access settings and app information from this menu.'**
  String get discoveryNavMenuDescription;

  /// Section title for feature discovery settings
  ///
  /// In en, this message translates to:
  /// **'Feature Discovery'**
  String get featureDiscoverySection;

  /// Switch label for list page feature discovery
  ///
  /// In en, this message translates to:
  /// **'List Page'**
  String get listPageDiscovery;

  /// Switch label for details page feature discovery
  ///
  /// In en, this message translates to:
  /// **'Details Page'**
  String get detailsPageDiscovery;

  /// Switch label for filter page feature discovery
  ///
  /// In en, this message translates to:
  /// **'Filter Page'**
  String get filterPageDiscovery;

  /// Switch label for navigation drawer feature discovery
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigationPageDiscovery;

  /// Help text explaining feature discovery switches
  ///
  /// In en, this message translates to:
  /// **'Enable tutorials to see helpful tips on each page. Tutorials automatically hide after completion but can be re-enabled here.'**
  String get featureDiscoveryHelpText;

  /// Title for onboarding screen 1
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dog List!'**
  String get onboardingScreen1Title;

  /// Description for onboarding screen 1
  ///
  /// In en, this message translates to:
  /// **'Discover 209 dog breeds and find your perfect companion. Explore detailed information, beautiful photos, and comprehensive breed characteristics.'**
  String get onboardingScreen1Description;

  /// Title for onboarding screen 2
  ///
  /// In en, this message translates to:
  /// **'Browse Dog Breeds'**
  String get onboardingScreen2Title;

  /// Description for onboarding screen 2
  ///
  /// In en, this message translates to:
  /// **'Scroll through all dog breeds with ease. Use quick filters and favorites to find exactly what you\'re looking for.'**
  String get onboardingScreen2Description;

  /// Feature 1 for onboarding screen 2
  ///
  /// In en, this message translates to:
  /// **'Mark favorites'**
  String get onboardingScreen2Feature1;

  /// Feature 2 for onboarding screen 2
  ///
  /// In en, this message translates to:
  /// **'Advanced filtering'**
  String get onboardingScreen2Feature2;

  /// Feature 3 for onboarding screen 2
  ///
  /// In en, this message translates to:
  /// **'Quick filter chips'**
  String get onboardingScreen2Feature3;

  /// Title for onboarding screen 3
  ///
  /// In en, this message translates to:
  /// **'Advanced Filtering'**
  String get onboardingScreen3Title;

  /// Description for onboarding screen 3
  ///
  /// In en, this message translates to:
  /// **'Filter breeds by size, temperament, coat type, and more. Find the perfect match for your lifestyle.'**
  String get onboardingScreen3Description;

  /// Feature 1 for onboarding screen 3
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get onboardingScreen3Feature1;

  /// Feature 2 for onboarding screen 3
  ///
  /// In en, this message translates to:
  /// **'Filter by traits'**
  String get onboardingScreen3Feature2;

  /// Feature 3 for onboarding screen 3
  ///
  /// In en, this message translates to:
  /// **'Temperament filters'**
  String get onboardingScreen3Feature3;

  /// Title for onboarding screen 4
  ///
  /// In en, this message translates to:
  /// **'Detailed Breed Information'**
  String get onboardingScreen4Title;

  /// Description for onboarding screen 4
  ///
  /// In en, this message translates to:
  /// **'View stunning photos of each breed in three picture types: Outdoor, Indoor, and Studio. Swipe between breeds and images effortlessly.'**
  String get onboardingScreen4Description;

  /// Feature 1 for onboarding screen 4
  ///
  /// In en, this message translates to:
  /// **'Swipe through photos'**
  String get onboardingScreen4Feature1;

  /// Feature 2 for onboarding screen 4
  ///
  /// In en, this message translates to:
  /// **'Zoom images'**
  String get onboardingScreen4Feature2;

  /// Feature 3 for onboarding screen 4
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get onboardingScreen4Feature3;

  /// Title for onboarding screen 5
  ///
  /// In en, this message translates to:
  /// **'Deep Dive Into Breeds'**
  String get onboardingScreen5Title;

  /// Description for onboarding screen 5
  ///
  /// In en, this message translates to:
  /// **'Learn everything about each breed including physical traits, behavior profile, care requirements, and fascinating facts.'**
  String get onboardingScreen5Description;

  /// Feature 1 for onboarding screen 5
  ///
  /// In en, this message translates to:
  /// **'Physical traits'**
  String get onboardingScreen5Feature1;

  /// Feature 2 for onboarding screen 5
  ///
  /// In en, this message translates to:
  /// **'Behavior profile'**
  String get onboardingScreen5Feature2;

  /// Feature 3 for onboarding screen 5
  ///
  /// In en, this message translates to:
  /// **'Did You Know facts'**
  String get onboardingScreen5Feature3;

  /// Title for onboarding screen 6
  ///
  /// In en, this message translates to:
  /// **'Easy Navigation'**
  String get onboardingScreen6Title;

  /// Description for onboarding screen 6
  ///
  /// In en, this message translates to:
  /// **'Access all features quickly from the navigation drawer. Set your best dog and jump to any section with ease.'**
  String get onboardingScreen6Description;

  /// Feature 1 for onboarding screen 6
  ///
  /// In en, this message translates to:
  /// **'Best dog suggestion'**
  String get onboardingScreen6Feature1;

  /// Feature 2 for onboarding screen 6
  ///
  /// In en, this message translates to:
  /// **'Quick filter access'**
  String get onboardingScreen6Feature2;

  /// Feature 3 for onboarding screen 6
  ///
  /// In en, this message translates to:
  /// **'Settings & info'**
  String get onboardingScreen6Feature3;

  /// Title for onboarding screen 7
  ///
  /// In en, this message translates to:
  /// **'Customize Your Experience'**
  String get onboardingScreen7Title;

  /// Description for onboarding screen 7
  ///
  /// In en, this message translates to:
  /// **'Personalize the app to your preferences. Control quick filter visibility, feature discovery, and more.'**
  String get onboardingScreen7Description;

  /// Feature 1 for onboarding screen 7
  ///
  /// In en, this message translates to:
  /// **'Quick filter options'**
  String get onboardingScreen7Feature1;

  /// Feature 2 for onboarding screen 7
  ///
  /// In en, this message translates to:
  /// **'Feature discovery'**
  String get onboardingScreen7Feature2;

  /// Feature 3 for onboarding screen 7
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get onboardingScreen7Feature3;

  /// Title for onboarding screen 8
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get onboardingScreen8Title;

  /// Description for onboarding screen 8
  ///
  /// In en, this message translates to:
  /// **'Access app information, version details, and developer info. You can replay this tour anytime from the Info page.'**
  String get onboardingScreen8Description;

  /// Feature 1 for onboarding screen 8
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get onboardingScreen8Feature1;

  /// Feature 2 for onboarding screen 8
  ///
  /// In en, this message translates to:
  /// **'Version details'**
  String get onboardingScreen8Feature2;

  /// Feature 3 for onboarding screen 8
  ///
  /// In en, this message translates to:
  /// **'Replay tour anytime'**
  String get onboardingScreen8Feature3;

  /// Skip button text for onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Next button text for onboarding
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Get Started button text for onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// Section title for onboarding screens in info page
  ///
  /// In en, this message translates to:
  /// **'Onboarding Screens'**
  String get onboardingScreensSection;

  /// Button text to start onboarding from info page
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingScreensStart;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
