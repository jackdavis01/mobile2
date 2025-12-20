import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/navigation_drawer_bloc_cubit.dart';
import '../businesslogic/navigation_drawer_bloc_state.dart';
import '../businesslogic/user_preferences_bloc_cubit.dart';
import '../businesslogic/user_preferences_bloc_state.dart';
import '../businesslogic/settings_bloc_cubit.dart';
import '../widgets/feature_discovery_wrapper.dart';
import '../widgets/feature_overlays.dart';
import '../parameters/feature_ids.dart';
import '../parameters/netservices.dart';

class DogNavDrawer extends StatelessWidget {
  const DogNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationDrawerCubit(),
      child: Builder(
        builder: (context) {
          // Refresh best dog when drawer is built
          context.read<NavigationDrawerCubit>().loadBestDog();
          return FeatureDiscoveryWrapper(
            pageKey: 'navigation',
            featureIds: FeatureIds.navigationPageFeatures,
            onCompleted: () {
              context.read<SettingsCubit>().markNavigationPageDiscoveryCompleted();
            },
            child: const _DogNavDrawerContent(),
          );
        },
      ),
    );
  }
}

class _DogNavDrawerContent extends StatelessWidget {
  const _DogNavDrawerContent();

  void _navigateToSettingsPage(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToInfoPage(BuildContext context) {
    Navigator.pushNamed(context, '/info');
  }

  Future<void> _handleBestDogTap(BuildContext context, NavigationDrawerState drawerState) async {
    final NavigationDrawerCubit cubit = context.read<NavigationDrawerCubit>();

    if (drawerState.bestDogId != null) {
      // Have best dog - navigate to details page
      try {
        final allDogs = await cubit.getAllDogs();
        final bestDogIndex = allDogs.indexWhere((dog) => dog.id == drawerState.bestDogId);

        if (bestDogIndex >= 0 && context.mounted) {
          await Navigator.pushNamed(
            context,
            '/details',
            arguments: {
              'dogs': allDogs,
              'index': bestDogIndex,
            },
          );
        }
      } catch (e) {
        // If error, fall back to filter page
        if (context.mounted) {
          Navigator.pushNamed(context, '/filter');
        }
      }
    } else {
      // No best dog - navigate to filter page
      Navigator.pushNamed(context, '/filter');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final ScrollController scrollController = ScrollController();

    return MultiBlocListener(
      listeners: [
        BlocListener<UserPreferencesCubit, UserPreferencesState>(
          listener: (context, userPrefsState) {
            // Refresh drawer when best dog or favorites change
            context.read<NavigationDrawerCubit>().loadBestDog();
          },
        ),
      ],
      child: BlocBuilder<NavigationDrawerCubit, NavigationDrawerState>(
        builder: (BuildContext context, NavigationDrawerState drawerState) {
        final String displayName = drawerState.dogBreedName ?? appLocalizations.none;

        Widget drawerHeader = Container(
          padding: const EdgeInsets.only(right: 16),
          color: Theme.of(context).primaryColor,
          child: UserAccountsDrawerHeader(
            accountName: Text(appLocalizations.drawerFavourite(displayName), style: const TextStyle(fontSize: 18.0)),
            accountEmail: Text(appLocalizations.drawerLikes(drawerState.likes), style: const TextStyle(fontSize: 18.0)),
            currentAccountPictureSize: const Size.square(62.0),
            currentAccountPicture: NavigationBestDogDiscoveryOverlay(
              featureId: FeatureIds.navBestDog,
              child: GestureDetector(
                onTap: () => _handleBestDogTap(context, drawerState),
                child: drawerState.bestDogImageUrl != null
                    ? CircleAvatar(
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: NS.apiDogUrl + NS.apiDogImagesPage + drawerState.bestDogImageUrl!,
                            cacheManager: LongTermCacheManager(),
                            width: 62.0,
                            height: 62.0,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.blue,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
              ),
            ),
            margin: const EdgeInsets.only(bottom: 0),
            otherAccountsPictures: <Widget>[
              CircleAvatar(
                child: IconButton(
                  onPressed: () => _navigateToSettingsPage(context),
                  icon: const Icon(Icons.settings),
                ),
              ),
              CircleAvatar(
                child: IconButton(
                  onPressed: () => _navigateToInfoPage(context),
                  icon: const Icon(Icons.info),
                ),
              ),
            ],
          ),
        );

        final drawerItems = ListView(
          controller: scrollController,
          children: <Widget>[
            drawerHeader,
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.settings),
              minLeadingWidth: 0,
              title: Text(appLocalizations.settingsTitle, style: const TextStyle(fontSize: 18.0)),
              onTap: () => _navigateToSettingsPage(context),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              minLeadingWidth: 0,
              title: Text(appLocalizations.infoTitle, style: const TextStyle(fontSize: 18.0)),
              onTap: () => _navigateToInfoPage(context),
            ),
          ],
        );

        return SafeArea(
          child: Drawer(
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 10,
              radius: const Radius.circular(6),
              child: drawerItems,
            ),
          ),
        );
      },
      ),
    );
  }
}
