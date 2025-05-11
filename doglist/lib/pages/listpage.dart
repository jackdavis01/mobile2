import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../parameters/netservices.dart';
import '../providers/listprovider.dart';
import '../models/dog.dart';
import '../widgets/spinkitwidgets.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: (listProvider.toggleFilter) ? Icon(Icons.filter_alt_outlined, size: 32) : Icon(Icons.filter_alt, size: 32),
            onPressed: listProvider.toggleFilterAction,
          ),
        ],
      ),
      body: listProvider.originalItems.isEmpty
          ? Center(
              child: listProvider.showError
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
                          onPressed: listProvider.reloadData,
                          child: Text('Reload'),
                        ),
                      ],
                    )
                  : CustomSpinKitThreeInOut(), // Show loading indicator
            )
        :  ListView.builder(
          itemCount: listProvider.items.length,
          itemBuilder: (context, index) {
            final Dog item = listProvider.items[index];
            final isFavorite = listProvider.favorites.contains(item);
            Widget wLeading = Container();
            Widget wTitle = Container();
            Widget wSubtitle = Container();
            try {
              // Use CachedNetworkImage for automatic image caching and offline support.
              wLeading = CachedNetworkImage(
                imageUrl: item.images.smallOutdoors.replaceAll(NS.apiDogOriginalUrl, NS.apiDogUrl),
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
              wTitle = Text("Breed: ${item.name}");
              wSubtitle = Text("Coat style: ${item.coatStyle}");
            } catch (e) {
              debugPrint("Error in the incoming data: $e");
            }
            return ListTile(
              leading: wLeading,
              title: wTitle,
              subtitle: wSubtitle,
              trailing: IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => listProvider.toggleFavorite(item.id),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/details',
                  arguments: item,
                );
              },
            );
          },
        ),
    );
  }
}
