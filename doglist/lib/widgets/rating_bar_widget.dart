import 'package:flutter/material.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';

/// Color mode for rating bars to handle different property semantics
enum RatingColorMode {
  /// Normal mode: higher values are better (green for 4-5, red for 1-2)
  normal,
  /// Reversed mode: lower values are better (green for 1-2, red for 4-5)
  reversed,
  /// Neutral mode: no good/bad judgment (blue for all values)
  neutral,
}

/// A widget that displays a rating from 1-5 as a visual indicator
/// with color coding based on the semantic meaning of the property
class RatingBarWidget extends StatelessWidget {
  final String label;
  final int rating;
  final int maxRating;
  final RatingColorMode colorMode;

  const RatingBarWidget({
    super.key,
    required this.label,
    required this.rating,
    this.maxRating = 5,
    this.colorMode = RatingColorMode.normal,
  });

  Color _getRatingColor() {
    switch (colorMode) {
      case RatingColorMode.normal:
        // Higher is better: green for high values, red for low
        if (rating <= 2) {
          return Colors.red.shade400;
        } else if (rating == 3) {
          return Colors.orange.shade400;
        } else {
          return Colors.green.shade400;
        }
      case RatingColorMode.reversed:
        // Lower is better: green for low values, red for high
        if (rating <= 2) {
          return Colors.green.shade400;
        } else if (rating == 3) {
          return Colors.orange.shade400;
        } else {
          return Colors.red.shade400;
        }
      case RatingColorMode.neutral:
        // No judgment: blue for all values
        return Colors.blue.shade400;
    }
  }

  String _getRatingText(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    if (rating == 1) return appLocalizations.ratingVeryLow;
    if (rating == 2) return appLocalizations.ratingLow;
    if (rating == 3) return appLocalizations.ratingModerate;
    if (rating == 4) return appLocalizations.ratingHigh;
    if (rating == 5) return appLocalizations.ratingVeryHigh;
    return appLocalizations.unknown;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          // Label
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8.0),
          // Rating indicator
          Expanded(
            flex: 4,
            child: Row(
              children: [
                // Colored bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rating / maxRating,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(_getRatingColor()),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                // Rating text
                SizedBox(
                  width: 74,
                  child: Text(
                    _getRatingText(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getRatingColor(),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
