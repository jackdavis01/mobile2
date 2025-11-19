import 'package:flutter/material.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';

enum QuickFilterVisibility {
  switchedOff,
  onlyBeforeXTap,
  alwaysVisible,
}

class QuickFilterButtons extends StatelessWidget {
  final QuickFilterVisibility visibility;
  final int filterTapCount;
  final Function(String filterId) onFilterTap;
  final VoidCallback? onCheckboxTap;
  static const int tapThreshold = 3;

  const QuickFilterButtons({
    super.key,
    required this.visibility,
    required this.filterTapCount,
    required this.onFilterTap,
    this.onCheckboxTap,
  });

  bool get shouldShow {
    switch (visibility) {
      case QuickFilterVisibility.switchedOff:
        return false;
      case QuickFilterVisibility.onlyBeforeXTap:
        return true; // Always show when this mode is enabled
      case QuickFilterVisibility.alwaysVisible:
        return true;
    }
  }

  bool get shouldShowCheckbox {
    return visibility == QuickFilterVisibility.onlyBeforeXTap && 
           filterTapCount >= tapThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade200, width: 1),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          if (shouldShowCheckbox && onCheckboxTap != null) ...[
            InkWell(
              onTap: onCheckboxTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300, width: 1),
                ),
                child: Icon(
                  Icons.check_box,
                  color: Colors.blue.shade800,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          _buildFilterButton(
            context,
            'family-friendly',
            appLocalizations.familyFriendly,
            Icons.family_restroom,
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            context,
            'low-maintenance',
            appLocalizations.lowMaintenance,
            Icons.check_circle_outline,
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            context,
            'active-dogs',
            appLocalizations.activeDogs,
            Icons.directions_run,
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            context,
            'apartment-friendly',
            appLocalizations.apartmentFriendly,
            Icons.apartment,
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            context,
            'first-time-owners',
            appLocalizations.firstTimeOwners,
            Icons.person_outline,
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            context,
            'clean-tidy',
            appLocalizations.cleanTidy,
            Icons.cleaning_services,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String filterId,
    String label,
    IconData icon,
  ) {
    return ElevatedButton.icon(
      onPressed: () => onFilterTap(filterId),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blue.shade300, width: 1),
        ),
      ),
    );
  }
}
