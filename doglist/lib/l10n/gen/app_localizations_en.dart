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
}
