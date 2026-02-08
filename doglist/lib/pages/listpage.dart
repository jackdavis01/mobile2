import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/list_bloc_state.dart';
import '../businesslogic/list_bloc_cubit.dart';
import '../businesslogic/user_preferences_bloc_cubit.dart';
import '../businesslogic/settings_bloc_cubit.dart';
import '../businesslogic/settings_bloc_state.dart';
import '../businesslogic/like_bloc_cubit.dart';
import '../models/dog.dart';
import '../widgets/spinkitwidgets.dart';
import '../widgets/ad_banner.dart';
import '../widgets/quick_filter_buttons.dart';
import '../widgets/navigation_drawer.dart';
import '../widgets/dog_list_item.dart';
import '../widgets/feature_discovery_wrapper.dart';
import '../widgets/feature_overlays.dart';
import '../parameters/feature_ids.dart';
import '../parameters/ads_config.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListCubit(),
      child: FeatureDiscoveryWrapper(
        pageKey: 'list',
        featureIds: FeatureIds.listPageFeatures,
        onCompleted: () {
          context.read<SettingsCubit>().markListPageDiscoveryCompleted();
        },
        delayDiscoveryUntilDrawerClosed: true,
        builder: (onDrawerClosed, onDrawerOpened) => _ListPageContent(
          onDrawerClosed: onDrawerClosed,
          onDrawerOpened: onDrawerOpened,
        ),
      ),
    );
  }
}

class _ListPageContent extends StatelessWidget {
  final VoidCallback? onDrawerClosed;
  final VoidCallback? onDrawerOpened;

  const _ListPageContent({this.onDrawerClosed, this.onDrawerOpened});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();

    return BlocBuilder<ListCubit, ListState>(
      buildWhen: (previous, current) {
        // Only rebuild when items or favorite filter toggle changes
        return previous.items != current.items ||
               previous.toggleFavoriteFilter != current.toggleFavoriteFilter;
      },
      builder: (BuildContext context, ListState listState) {
        final ListCubit listCubit = context.read<ListCubit>();
        final UserPreferencesCubit userPrefsCubit =
            context.read<UserPreferencesCubit>();

        // Update filtered items when favorites change (for favorite filter)
        // Only do this once per build, not on every UserPreferencesState change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          listCubit.updateFilteredItems(userPrefsCubit.state.favorites);
          // Load all like counts (guarded internally to prevent multiple loads)
          context.read<LikeCubit>().loadAllLikeCounts();
        });

        return Scaffold(
          appBar: AppBar(
            title: Text(appLocalizations.breedListTitle),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext context) {
                return Center(
                  child: NavigationMenuDiscoveryOverlay(
                    featureId: FeatureIds.navMenuIcon,
                    child: IconButton(
                      iconSize: 28,
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                    ),
                  ),
                );
              },
            ),
            actions: [
              ListFilterButtonDiscoveryOverlay(
                featureId: FeatureIds.listFilterButton,
                child: IconButton(
                  icon: Icon(Icons.filter_alt_outlined,
                      size: 32, color: Colors.blue[800]),
                  onPressed: () async {
                    listCubit.markFilterAsOpened();
                    await Navigator.pushNamed(context, '/filter');
                    // Refresh preferences when returning from FilterPage
                    if (context.mounted) {
                      await userPrefsCubit.refreshPreferences();
                    }
                  },
                ),
              ),
              ListFavoriteFilterButtonDiscoveryOverlay(
                featureId: FeatureIds.listFavoriteFilterButton,
                child: IconButton(
                  icon: (listState.toggleFavoriteFilter)
                      ? Icon(Icons.favorite, size: 28, color: Colors.red)
                      : Icon(Icons.favorite_border, size: 28),
                  onPressed: listCubit.toggleFavoriteFilterAction,
                ),
              ),
            ],
          ),
          onDrawerChanged: (isOpen) {
            if (isOpen && onDrawerOpened != null) {
              // Cancel auto-trigger when drawer opens
              onDrawerOpened!();
            } else if (!isOpen && onDrawerClosed != null) {
              // Trigger discovery when drawer closes
              onDrawerClosed!();
            }
          },
          drawer: const DogNavDrawer(),
          body: Column(
            children: [
              // Quick Filter Buttons Stripe
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  final SettingsCubit settingsCubit =
                      context.read<SettingsCubit>();

                  return QuickFilterDiscoveryOverlay(
                    featureId: FeatureIds.listQuickFilters,
                    child: QuickFilterButtons(
                      visibility: settingsState.quickFilterVisibility,
                      filterTapCount: listState.filterTapCount,
                      onFilterTap: (filterId) async {
                        listCubit.markFilterAsOpened();
                        await Navigator.pushNamed(
                          context,
                          '/filter',
                          arguments: {'selectedQuickFilter': filterId},
                        );
                        if (context.mounted) {
                          await userPrefsCubit.refreshPreferences();
                        }
                      },
                      onCheckboxTap: () async {
                        final result = await showDialog<String>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text(appLocalizations.quickFilterHideDialogTitle),
                              content: Text(
                                appLocalizations.quickFilterHideDialogMessage,
                                style: const TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop('hide'),
                                  child: Text(
                                    appLocalizations.quickFilterHideYes,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop('always'),
                                  child: Text(
                                    appLocalizations.quickFilterHideNo,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop('cancel'),
                                  child: Text(
                                    appLocalizations.quickFilterCancel,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (result != null && result != 'cancel') {
                          if (result == 'hide') {
                            await settingsCubit.setQuickFilterVisibility(
                                QuickFilterVisibility.switchedOff);
                            await settingsCubit.setFirstXTimesDisabled(true);
                          } else if (result == 'always') {
                            await settingsCubit.setQuickFilterVisibility(
                                QuickFilterVisibility.alwaysVisible);
                            await settingsCubit.setFirstXTimesDisabled(true);
                          }
                        }
                      },
                    ),
                  );
                },
              ),
              // Main content
              Expanded(
                child: Stack(
                  children: [
                    // Main content list
                    listState.loading
                        ? CustomSpinKitThreeInOut()
                        : listState.originalItems.isEmpty
                            ? Center(
                                child: listState.showError
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 36),
                                              child: Text(
                                                appLocalizations
                                                    .internetConnectionError,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.red),
                                                textAlign: TextAlign.center,
                                              )),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: listCubit.reloadData,
                                            child: Text(
                                                appLocalizations.reloadButton),
                                          ),
                                        ],
                                      )
                                    : CustomSpinKitThreeInOut(), // Show loading indicator
                              )
                            : listState.items.isEmpty &&
                                    listState.toggleFavoriteFilter
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.favorite_border,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            appLocalizations
                                                .filterMatchesCount(0),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                        bottom: AdsConfig.areAdsEnabled
                                            ? 60
                                            : 0), // Space for banner ad only if ads enabled
                                    child: ListView.builder(
                                      padding: MediaQuery.of(context)
                                                  .padding
                                                  .bottom >
                                              0
                                          ? EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .padding
                                                  .bottom)
                                          : EdgeInsets.zero,
                                      itemCount: listState.items.length,
                                      itemBuilder: (context, index) {
                                        final Dog item = listState.items[index];

                                        return DogListItem(
                                          dog: item,
                                          type: DogListItemType.list, // Show like button instead of best star
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 4.0),
                                          imageSize: 72.0,
                                          enableDiscovery: index ==
                                              2, // Enable discovery for third item
                                          onFavoriteToggled: () async =>
                                              await userPrefsCubit
                                                  .refreshPreferences(),
                                          onTap: () async {
                                            await Navigator.pushNamed(
                                                context, '/details',
                                                arguments: {
                                                  'dogs': listState.items,
                                                  'index': index,
                                                });
                                            // Refresh preferences when returning from DetailsPage
                                            if (context.mounted) {
                                              await userPrefsCubit
                                                  .refreshPreferences();
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                    // Banner ad positioned at the bottom
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AdBanner(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
