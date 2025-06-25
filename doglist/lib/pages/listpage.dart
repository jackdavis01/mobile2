import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../parameters/netservices.dart';
import '../businesslogic/list_bloc_cubit.dart';
import '../models/dog.dart';
import '../widgets/spinkitwidgets.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListCubit(),
      child: BlocBuilder<ListCubit, ListState>(
        builder: (BuildContext context, ListState listState) {
          final ListCubit listCubit = context.read<ListCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Text('Dog Breed List'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: (listState.toggleFilter) ? Icon(Icons.filter_alt_outlined, size: 32) : Icon(Icons.filter_alt, size: 32),
                  onPressed: listCubit.toggleFilterAction,
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
                              'Please check your internet connection!',
                              style: TextStyle(fontSize: 18, color: Colors.red),
                              textAlign: TextAlign.center,
                            )),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: listCubit.reloadData,
                              child: Text('Reload'),
                            ),
                          ],
                        )
                      : CustomSpinKitThreeInOut(), // Show loading indicator
                  )
                : ListView.builder(
                    itemCount: listState.items.length,
                    itemBuilder: (context, index) {
                      final Dog item = listState.items[index];
                      final bool isFavorite = listState.favorites.contains(item);
                      Widget wLeading = Container();
                      Widget wTitle = Container();
                      Widget wSubtitle = Container();
                      try {
                        // Use CachedNetworkImage for automatic image caching and offline support.
                        wLeading = CachedNetworkImage(
                          imageUrl: NS.apiDogUrl + NS.apiDogImagesPage + item.images.smallOutdoors,
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
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                          onPressed: () => listCubit.toggleFavorite(item.id),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: {
                              'dogs': listState.items,
                              'index': index,
                            }
                          );
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
