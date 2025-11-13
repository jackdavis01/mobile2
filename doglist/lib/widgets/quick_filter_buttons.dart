import 'package:flutter/material.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';

enum QuickFilterVisibility {
  switchedOff,
  onlyBeforeFirstFilterTap,
  alwaysVisible,
}

class QuickFilterButtons extends StatelessWidget {
  final QuickFilterVisibility visibility;
  final bool hasOpenedFilter;
  final Function(String filterId) onFilterTap;

  const QuickFilterButtons({
    super.key,
    required this.visibility,
    required this.hasOpenedFilter,
    required this.onFilterTap,
  });

  bool get shouldShow {
    switch (visibility) {
      case QuickFilterVisibility.switchedOff:
        return false;
      case QuickFilterVisibility.onlyBeforeFirstFilterTap:
        return !hasOpenedFilter;
      case QuickFilterVisibility.alwaysVisible:
        return true;
    }
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
