import 'package:flutter/material.dart';
import 'package:feature_discovery/feature_discovery.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';

// List Page - Quick Filter Chips
class QuickFilterDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const QuickFilterDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade300, width: 1),
        ),
        child:
            Icon(Icons.family_restroom, size: 18, color: Colors.blue.shade800),
      ),
      contentLocation: ContentLocation.below,
      overflowMode: OverflowMode.wrapBackground,
      title: Text(appLocalizations.discoveryQuickFiltersTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoveryQuickFiltersDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}

// List Page - Filter Button
class ListFilterButtonDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const ListFilterButtonDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget:
          Icon(Icons.filter_alt_outlined, size: 32, color: Colors.blue[800]),
      contentLocation: ContentLocation.below,
      title: Text(appLocalizations.discoveryListFilterButtonTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoveryListFilterButtonDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}

// List Page - Favorite Button
class ListFavoriteButtonDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const ListFavoriteButtonDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: const Icon(Icons.favorite, size: 24, color: Colors.red),
      contentLocation: ContentLocation.below,
      title: Text(appLocalizations.discoveryListFavoriteTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoveryListFavoriteDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}

// List Page - Favorite Filter Button
class ListFavoriteFilterButtonDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const ListFavoriteFilterButtonDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: const Icon(Icons.favorite, size: 28, color: Colors.red),
      contentLocation: ContentLocation.below,
      title: Text(appLocalizations.discoveryListFavoriteFilterTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoveryListFavoriteFilterDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}

// Details Page - Zoom Icon
class DetailsZoomIconDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const DetailsZoomIconDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(4),
        child: const Icon(Icons.zoom_in, size: 42, color: Colors.white),
      ),
      contentLocation: ContentLocation.below,
      title: Text(appLocalizations.discoveryDetailsZoomTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoveryDetailsZoomDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}

// Details Page - Favorite Heart Button
class DetailsFavoriteButtonDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const DetailsFavoriteButtonDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: const Icon(Icons.favorite, size: 24, color: Colors.red),
      contentLocation: ContentLocation.below,
      title: Text(appLocalizations.discoveryDetailsFavoriteTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoveryDetailsFavoriteDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}

// Filter Page - Search Bar
class SearchBarDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const SearchBarDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: const Icon(Icons.search, size: 28),
      contentLocation: ContentLocation.below,
      title: Text(appLocalizations.discoverySearchBarTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoverySearchBarDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}

// Filter Page - Advanced Filters
class AdvancedFiltersDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const AdvancedFiltersDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: const Icon(Icons.expand_more, size: 28),
      contentLocation: ContentLocation.below,
      title: Text(appLocalizations.discoveryAdvancedFiltersTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoveryAdvancedFiltersDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}

// Navigation Drawer - Best Dog Display
class NavigationBestDogDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const NavigationBestDogDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: const Icon(Icons.add, size: 40, color: Colors.blue),
      contentLocation: ContentLocation.below,
      title: Text(appLocalizations.discoveryNavBestDogTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoveryNavBestDogDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}

// Navigation Drawer - Menu Icon
class NavigationMenuDiscoveryOverlay extends StatelessWidget {
  final String featureId;
  final Widget child;

  const NavigationMenuDiscoveryOverlay({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: const Icon(Icons.menu, size: 28),
      contentLocation: ContentLocation.below,
      title: Text(appLocalizations.discoveryNavMenuTitle,
          style: const TextStyle(fontSize: 18)),
      description: Text(
        appLocalizations.discoveryNavMenuDescription,
        style: const TextStyle(fontSize: 17),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      child: child,
    );
  }
}
