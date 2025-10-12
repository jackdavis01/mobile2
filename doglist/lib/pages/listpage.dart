import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../parameters/netservices.dart';
import '../businesslogic/list_bloc_state.dart';
import '../businesslogic/list_bloc_cubit.dart';
import '../models/dog.dart';
import '../widgets/spinkitwidgets.dart';

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
              actions: [
                IconButton(
                  icon: Icon(Icons.filter_alt_outlined, size: 32, color: Colors.blue[800]),
                  onPressed: () async {
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
            body: listState.loading
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
                : ListView.builder(
                    itemCount: listState.items.length,
                    itemBuilder: (context, index) {
                      final Dog item = listState.items[index];
                      final bool isFavorite = listState.favorites.any((fav) => fav.id == item.id);
                      Widget wLeading = Container();
                      Widget wTitle = Container();
                      Widget wSubtitle = Container();
                      try {
                        // Use CachedNetworkImage for automatic image caching and offline support.
                        wLeading = CachedNetworkImage(
                          imageUrl: NS.apiDogUrl + NS.apiDogImagesPage + item.images.smallOutdoors,
                          cacheManager: LongTermCacheManager(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SizedBox(
                            width: 56,
                            height: 56,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Center(
                                child: CustomSpinKitThreeInOut(), // Show a loading indicator while loading
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => FittedBox(
                            fit: BoxFit.contain,
                            child: Icon(
                              Icons.image, // Default image icon
                              size: 56,
                              color: Colors.grey,
                            ),
                          ),
                        );
                        wTitle = Text(item.name);
                        wSubtitle = Text("${item.coatStyle}, ${item.coatTexture}");
                      } catch (e) {
                        debugPrint("Error in the incoming data: $e");
                      }
                      return ListTile(
                        leading: wLeading,
                        title: wTitle,
                        subtitle: wSubtitle,
                        trailing: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () async => await listCubit.toggleFavorite(item.id),
                        ),
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
          );
        }
      ),
    );
  }
}
