import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../parameters/netservices.dart';
import '../providers/detailsprovider.dart';
import '../models/dog.dart';
import '../widgets/imagewithcancel.dart';
import '../widgets/spinkitwidgets.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Dog item = ModalRoute.of(context)!.settings.arguments as Dog;

    Widget wTitle = Container();
    Widget wCoatStyle = Container();
    Widget wCoatTexture = Container();
    Widget wPersonalityTraits = Container();
    try {
      wTitle = Text("Breed: ${item.name}", style: TextStyle(fontSize: 24));
      wCoatStyle = Text("Coat style: ${item.coatStyle}", style: TextStyle(fontSize: 18));
      wCoatTexture = Text("Coat texture: ${item.coatTexture}", style: TextStyle(fontSize: 18));
      wPersonalityTraits = Column(children: [
        Text("Personality traits:", style: TextStyle(fontSize: 18)),
        Text(item.personalityTraits.join(", "), style: TextStyle(fontSize: 16))
      ]);
    } catch (e) {
      debugPrint("Error in incoming data: $e");
    }

    // List of Image types
    List<String> imageTypes = ["Outdoor", "Indoor", "Studio"];

    // List of Images
    List<String> imageUrls = [];
    try {
      imageUrls = [
        item.images.largeOutdoors.replaceAll(NS.apiDogOriginalUrl, NS.apiDogUrl),
        item.images.largeIndoors.replaceAll(NS.apiDogOriginalUrl, NS.apiDogUrl),
        item.images.largeStudio.replaceAll(NS.apiDogOriginalUrl, NS.apiDogUrl)
      ];
    } catch (e) {
      debugPrint("Error during loading pictures: $e");
    }

    return ChangeNotifierProvider(
      create: (_) {
        final provider = DetailsProvider();
        provider.updatePage(0); // Reset _currentPage to 0 when the page is opened
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(item.name), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 16.0, left: 16.0),
          child: Column(
            children: [
              Expanded(
                child: Consumer<DetailsProvider>(builder: (context, detailsProvider, child) {
                  return Stack(children: [
                    PageView.builder(
                      controller: detailsProvider.pageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        detailsProvider.updatePage(index); // Update the current page
                      },
                      itemBuilder: (context, index) {
                        // Start the timer if it hasn't already started.
                        if (!detailsProvider.showError(index)) {
                          detailsProvider.startErrorTimer(index);
                        }
                        final showError = detailsProvider.showError(index);
                        if (showError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 64),
                              child: Text(
                                "Error during loading picture, check the internet connection",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(imageTypes[index], style: TextStyle(fontSize: 20)),
                            ),
                            Expanded(
                              child: ImageWithCancel(
                                imageUrl: imageUrls[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    detailsProvider.cancelErrorTimer(index); // Cancel timer if image loads
                                    return child;
                                  }
                                  detailsProvider.startErrorTimer(index); // Start timer while loading
                                  return Center(
                                    child: CustomSpinKitThreeInOut(), // Show loading indicator
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  detailsProvider.cancelErrorTimer(index); // Cancel timer if error occurs
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 64),
                                      child: Text(
                                        "Error during loading picture, check the internet connection",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // Left arrow
                    if (detailsProvider.currentPage > 0)
                      Positioned(
                        left: 16,
                        top: 28,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, size: 32, color: Colors.white),
                          onPressed: () {
                            detailsProvider.pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    // Right arrow
                    if (detailsProvider.currentPage < imageUrls.length - 1)
                      Positioned(
                        right: 16,
                        top: 28,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward, size: 32, color: Colors.white),
                          onPressed: () {
                            detailsProvider.pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                  ]);
                },
              )),
              SizedBox(height: 16),
              wTitle,
              SizedBox(height: 8),
              wCoatStyle,
              SizedBox(height: 8),
              wCoatTexture,
              SizedBox(height: 8),
              wPersonalityTraits,
            ],
          ),
        ),
      ),
    );
  }
}
