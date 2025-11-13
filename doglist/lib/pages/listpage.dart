import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/list_bloc_state.dart';
import '../businesslogic/list_bloc_cubit.dart';
import '../models/dog.dart';
import '../widgets/spinkitwidgets.dart';
import '../widgets/ad_banner.dart';
import '../widgets/quick_filter_buttons.dart';
import '../widgets/navigation_drawer.dart';
import '../widgets/dog_list_item.dart';
import '../parameters/ads_config.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
 
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return BlocProvider(
      create: (_) => ListCubit(),
      child: BlocBuilder<ListCubit, ListState>(
        builder: (BuildContext context, ListState listState) {
          final ListCubit listCubit = context.read<ListCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Text(appLocalizations.breedListTitle),
              centerTitle: true,
              leading: Builder(
                builder: (BuildContext context) {
                  return Center(
                    child: IconButton(
                      iconSize: 28,
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                    ),
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.filter_alt_outlined, size: 32, color: Colors.blue[800]),
                  onPressed: () async {
                    listCubit.markFilterAsOpened();
                    await Navigator.pushNamed(context, '/filter');
                    // Refresh favorites when returning from FilterPage
                    listCubit.refreshFavorites();
                  },
                ),
                IconButton(
                  icon: (listState.toggleFavoriteFilter) ? Icon(Icons.favorite, size: 28, color: Colors.red) : Icon(Icons.favorite_border, size: 28),
                  onPressed: listCubit.toggleFavoriteFilterAction,
                ),
              ],
            ),
            drawer: const DogNavDrawer(),
            body: Column(
              children: [
                // Quick Filter Buttons Stripe
                QuickFilterButtons(
                  visibility: QuickFilterVisibility.alwaysVisible,
                  hasOpenedFilter: listState.hasOpenedFilter,
                  onFilterTap: (filterId) async {
                    listCubit.markFilterAsOpened();
                    await Navigator.pushNamed(
                      context,
                      '/filter',
                      arguments: {'selectedQuickFilter': filterId},
                    );
                    listCubit.refreshFavorites();
                  },
                ),
                // Main content
                Expanded(
                  child: Stack(
                    children: [
                // Main content
                listState.loading
                  ? CustomSpinKitThreeInOut()
                  : listState.originalItems.isEmpty
                    ? Center(child:
                        listState.showError
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(padding: EdgeInsets.symmetric(horizontal: 36), child: Text(
                                  appLocalizations.internetConnectionError,
                                  style: TextStyle(fontSize: 18, color: Colors.red),
                                  textAlign: TextAlign.center,
                                )),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: listCubit.reloadData,
                                  child: Text(appLocalizations.reloadButton),
                                ),
                              ],
                            )
                          : CustomSpinKitThreeInOut(), // Show loading indicator
                      )
                    : Padding(
                        padding: EdgeInsets.only(bottom: AdsConfig.areAdsEnabled ? 60 : 0), // Space for banner ad only if ads enabled
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: listState.items.length,
                          itemBuilder: (context, index) {
                            final Dog item = listState.items[index];
                            final bool isFavorite = listState.favorites.any((fav) => fav.id == item.id);
                            
                            return DogListItem(
                              dog: item,
                              isFavorite: isFavorite,
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                              imageSize: 72.0,
                              onFavoritePressed: () async => await listCubit.toggleFavorite(item.id),
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/details',
                                  arguments: {
                                    'dogs': listState.items,
                                    'index': index,
                                  }
                                );
                                // Refresh favorites when returning from DetailsPage
                                listCubit.refreshFavorites();
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
        }
      ),
    );
  }
}
