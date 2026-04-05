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
import '../platform/platform_info.dart';
import 'top_dogs_page.dart';

class ListPage extends StatelessWidget {
  final bool showTopDogsOnStart;

  const ListPage({super.key, this.showTopDogsOnStart = false});

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
          showTopDogsOnStart: showTopDogsOnStart,
        ),
      ),
    );
  }
}

class _ListPageContent extends StatefulWidget {
  final VoidCallback? onDrawerClosed;
  final VoidCallback? onDrawerOpened;
  final bool showTopDogsOnStart;

  const _ListPageContent({this.onDrawerClosed, this.onDrawerOpened, this.showTopDogsOnStart = false});

  @override
  State<_ListPageContent> createState() => _ListPageContentState();
}

class _ListPageContentState extends State<_ListPageContent> with SingleTickerProviderStateMixin {
  static const double _topDogsSnapThreshold = 0.5;
  static const double _topDogsFlingVelocity = 700.0;
  static const int _topDogsFlingDuration = 360;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _topDogsAnimationController;
  late final Animation<Offset> _topDogsSlideAnimation;
  bool _isTopDogsVisible = false;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _topDogsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _topDogsFlingDuration),
    );
    _topDogsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(_topDogsAnimationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.showTopDogsOnStart && !PlatformInfo.isWeb) {
        _showTopDogsOverlay();
      } else {
        _notifyDiscoveryReadyIfUnblocked();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ListPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.onDrawerClosed != widget.onDrawerClosed ||
        oldWidget.onDrawerOpened != widget.onDrawerOpened ||
        oldWidget.showTopDogsOnStart != widget.showTopDogsOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _notifyDiscoveryReadyIfUnblocked();
        }
      });
    }
  }

  @override
  void dispose() {
    _topDogsAnimationController.dispose();
    super.dispose();
  }

  void _notifyDiscoveryReadyIfUnblocked() {
    final bool isDrawerActuallyOpen = _scaffoldKey.currentState?.isDrawerOpen ?? _isDrawerOpen;

    if (!_isTopDogsVisible && !isDrawerActuallyOpen) {
      widget.onDrawerClosed?.call();
    }
  }

  Future<void> _showTopDogsOverlay() async {
    widget.onDrawerOpened?.call();

    if (!_isTopDogsVisible) {
      setState(() {
        _isTopDogsVisible = true;
      });
    }

    if (_topDogsAnimationController.value >= 1.0) return;

    await _topDogsAnimationController.animateTo(1.0, curve: Curves.easeOutCubic);
  }

  Future<void> _hideTopDogsOverlay({bool openFilter = false}) async {
    if (_isTopDogsVisible || _topDogsAnimationController.value > 0.0) {
      await _topDogsAnimationController.animateBack(0.0, curve: Curves.easeOutCubic);
      if (!mounted) return;
      setState(() {
        _isTopDogsVisible = false;
      });

      final bool isDrawerStillOpen = _scaffoldKey.currentState?.isDrawerOpen ?? _isDrawerOpen;
      if (!isDrawerStillOpen) {
        widget.onDrawerClosed?.call();
      }
    }

    if (openFilter && mounted) {
      final ListCubit listCubit = context.read<ListCubit>();
      final UserPreferencesCubit userPrefsCubit = context.read<UserPreferencesCubit>();

      listCubit.markFilterAsOpened();
      await Navigator.pushNamed(context, '/filter');
      if (mounted) {
        await userPrefsCubit.refreshPreferences();
      }
    }
  }

  void _handleTopDogsDrawerTap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showTopDogsOverlay();
      }
    });
  }

  void _handleTopDogsDragStart(DragStartDetails details) {
    _topDogsAnimationController.stop();
  }

  void _handleTopDogsDragUpdate(DragUpdateDetails details) {
    final double screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight <= 0) return;

    final double delta = details.primaryDelta ?? 0.0;
    final double nextValue = (_topDogsAnimationController.value + (delta / screenHeight)).clamp(0.0, 1.0).toDouble();

    _topDogsAnimationController.value = nextValue;
  }

  void _handleTopDogsDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0.0;

    if (velocity <= -_topDogsFlingVelocity) {
      _hideTopDogsOverlay();
      return;
    }

    if (velocity >= _topDogsFlingVelocity) {
      _showTopDogsOverlay();
      return;
    }

    if (_topDogsAnimationController.value < _topDogsSnapThreshold) {
      _hideTopDogsOverlay();
    } else {
      _showTopDogsOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return BlocBuilder<ListCubit, ListState>(
      buildWhen: (previous, current) {
        // Only rebuild when items or favorite filter toggle changes
        return previous.items != current.items || previous.toggleFavoriteFilter != current.toggleFavoriteFilter;
      },
      builder: (BuildContext context, ListState listState) {
        final ListCubit listCubit = context.read<ListCubit>();
        final UserPreferencesCubit userPrefsCubit = context.read<UserPreferencesCubit>();

        // Update filtered items when favorites change (for favorite filter)
        // Only do this once per build, not on every UserPreferencesState change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          listCubit.updateFilteredItems(userPrefsCubit.state.favorites);
          // Load all like counts (guarded internally to prevent multiple loads)
          context.read<LikeCubit>().loadAllLikeCounts();
        });

        return Stack(
          children: [
            Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(appLocalizations.breedListTitle),
                centerTitle: true,
                leadingWidth: !PlatformInfo.isWeb ? 104 : null,
                leading: Builder(
                  builder: (BuildContext context) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Center(
                            child: NavigationMenuDiscoveryOverlay(
                              featureId: FeatureIds.navMenuIcon,
                              child: IconButton(
                                iconSize: 28,
                                icon: const Icon(Icons.menu_rounded),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                              ),
                            ),
                          ),
                        ),
                        if (!PlatformInfo.isWeb)
                          IconButton(
                            iconSize: 28,
                            icon: const Icon(Icons.emoji_events, color: Colors.orange),
                            onPressed: () {
                              _showTopDogsOverlay();
                            },
                            tooltip: appLocalizations.topDogsTitle,
                          ),
                      ],
                    );
                  },
                ),
                actions: [
                  ListFilterButtonDiscoveryOverlay(
                    featureId: FeatureIds.listFilterButton,
                    child: IconButton(
                      icon: Icon(Icons.filter_alt_outlined, size: 32, color: Colors.blue[800]),
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
                _isDrawerOpen = isOpen;

                if (isOpen && widget.onDrawerOpened != null) {
                  // Cancel auto-trigger when drawer opens
                  widget.onDrawerOpened!();
                } else if (!isOpen && widget.onDrawerClosed != null) {
                  // Trigger discovery when drawer closes
                  widget.onDrawerClosed!();
                }
              },
              drawer: DogNavDrawer(onTopDogsTap: _handleTopDogsDrawerTap),
              body: Column(
                children: [
                  // Quick Filter Buttons Stripe
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settingsState) {
                      final SettingsCubit settingsCubit = context.read<SettingsCubit>();

                      return QuickFilterDiscoveryOverlay(
                        featureId: FeatureIds.listQuickFilters,
                        child: QuickFilterButtons(
                          visibility: settingsState.quickFilterVisibility,
                          filterTapCount: listState.filterTapCount,
                          onFilterTap: (filterId) async {
                            listCubit.markFilterAsOpened();
                            await Navigator.pushNamed(context, '/filter', arguments: {'selectedQuickFilter': filterId});
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
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop('always'),
                                      child: Text(
                                        appLocalizations.quickFilterHideNo,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop('cancel'),
                                      child: Text(
                                        appLocalizations.quickFilterCancel,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (result != null && result != 'cancel') {
                              if (result == 'hide') {
                                await settingsCubit.setQuickFilterVisibility(QuickFilterVisibility.switchedOff);
                                await settingsCubit.setFirstXTimesDisabled(true);
                              } else if (result == 'always') {
                                await settingsCubit.setQuickFilterVisibility(QuickFilterVisibility.alwaysVisible);
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
                            ? const CustomSpinKitThreeInOut()
                            : listState.originalItems.isEmpty
                            ? Center(
                                child: listState.showError
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 36),
                                            child: Text(
                                              appLocalizations.internetConnectionError,
                                              style: const TextStyle(fontSize: 18, color: Colors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: listCubit.reloadData,
                                            child: Text(appLocalizations.reloadButton),
                                          ),
                                        ],
                                      )
                                    : const CustomSpinKitThreeInOut(),
                              )
                            : listState.items.isEmpty && listState.toggleFavoriteFilter
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.favorite_border, size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 12),
                                      Text(
                                        appLocalizations.filterMatchesCount(0),
                                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.only(
                                  bottom: AdsConfig.areAdsEnabled && (PlatformInfo.isAndroid || PlatformInfo.isIOS)
                                      ? 64
                                      : 0,
                                ),
                                child: ListView.builder(
                                  padding: MediaQuery.of(context).padding.bottom > 0
                                      ? EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)
                                      : EdgeInsets.zero,
                                  itemCount: listState.items.length,
                                  itemBuilder: (context, index) {
                                    final Dog item = listState.items[index];

                                    return DogListItem(
                                      dog: item,
                                      type: DogListItemType.list,
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                      imageSize: 72.0,
                                      enableDiscovery: index == 2,
                                      onFavoriteToggled: () async => await userPrefsCubit.refreshPreferences(),
                                      onTap: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          '/details',
                                          arguments: {'dogs': listState.items, 'index': index},
                                        );
                                        if (context.mounted) {
                                          await userPrefsCubit.refreshPreferences();
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                        const Positioned(left: 0, right: 0, bottom: 0, child: AdBanner()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isTopDogsVisible || _topDogsAnimationController.isAnimating)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: _handleTopDogsDragStart,
                  onVerticalDragUpdate: _handleTopDogsDragUpdate,
                  onVerticalDragEnd: _handleTopDogsDragEnd,
                  child: SlideTransition(
                    position: _topDogsSlideAnimation,
                    child: TopDogsPage(
                      onCloseToList: () {
                        _hideTopDogsOverlay();
                      },
                      onOpenFilter: () {
                        _hideTopDogsOverlay(openFilter: true);
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
