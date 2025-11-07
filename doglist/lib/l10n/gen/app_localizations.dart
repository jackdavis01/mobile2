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
