import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../parameters/netservices.dart';
import '../models/dog.dart';
import '../businesslogic/details_vertical_bloc_state.dart';
import '../businesslogic/details_vertical_bloc_cubit.dart';
import '../businesslogic/details_image_bloc_state.dart';
import '../businesslogic/details_image_bloc_cubit.dart';
import '../widgets/imagewithcancel.dart';
import '../widgets/spinkitwidgets.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
 
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    final Object? arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is! Map || !arguments.containsKey('dogs') || !arguments.containsKey('index')) {
      return Scaffold(
        appBar: AppBar(title: Text(appLocalizations.errorTitle)),
        body: Center(child: Text(appLocalizations.dogDetailsNotAvailableError)),
      );
    }

    final List<Dog> dogs = arguments['dogs'] as List<Dog>;
    final int initialDogIndex = arguments['index'] as int;

    return BlocProvider<DetailsVerticalCubit>(
      create: (_) => DetailsVerticalCubit(initialDogIndex: initialDogIndex),
      child: BlocBuilder<DetailsVerticalCubit, DetailsVerticalState>(
        builder: (context, detailsVerticalState) {
          final DetailsVerticalCubit detailsVerticalCubit = context.read<DetailsVerticalCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Text(dogs[detailsVerticalState.currentDogIndex].name), 
              centerTitle: true,
              actions: [
                BlocBuilder<DetailsVerticalCubit, DetailsVerticalState>(
                  builder: (context, state) {
                    final Dog currentDog = dogs[state.currentDogIndex];
                    final bool isFavorite = detailsVerticalCubit.isFavorite(currentDog);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: () => detailsVerticalCubit.toggleFavorite(currentDog),
                    );
                  },
                ),
              ],
            ),
            body: PageView.builder(
              scrollDirection: Axis.vertical,
              physics: detailsVerticalState.currentImagePageIsZoomed
                ? NeverScrollableScrollPhysics()
                : BouncingScrollPhysics(),
              controller: detailsVerticalCubit.verticalPageController,
              itemCount: dogs.length,
              onPageChanged: detailsVerticalCubit.updateDogIndex,
              itemBuilder: (context, dogIndex) {
                final Dog dog = dogs[dogIndex];

                Widget wTitle = Container();
                Widget wCoatStyle = Container();
                Widget wCoatTexture = Container();
                Widget wPersonalityTraits = Container();

                try {
                  wTitle = Text(
                    "Breed: ${dog.name}",
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  );
                  wCoatStyle = Text("Coat style: ${dog.coatStyle}", style: TextStyle(fontSize: 18));
                  wCoatTexture = Text("Coat texture: ${dog.coatTexture}", style: TextStyle(fontSize: 18));
                  wPersonalityTraits = Column(children: [
                    Text("Personality traits:", style: TextStyle(fontSize: 18)),
                    Text(dog.personalityTraits.join(", "), style: TextStyle(fontSize: 16))
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
                    dog.images.largeOutdoors,
                    dog.images.largeIndoors,
                    dog.images.largeStudio,
                  ];
                } catch (e) {
                  debugPrint("Error during loading pictures: $e");
                }

                return BlocProvider<DetailsImageCubit>(
                  create: (_) => DetailsImageCubit(
                    initialDogIndex: dogIndex,
                    onZoomChanged: (isZoomed) {
                      context.read<DetailsVerticalCubit>().setCurrentImagePageIsZoomed(isZoomed);
                    },
                  ),
                  child:  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: BlocBuilder<DetailsImageCubit, DetailsImageState>(
                            builder: (BuildContext context, DetailsImageState detailsImageState) {
                              final DetailsImageCubit detailsImageCubit = context.read<DetailsImageCubit>();
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  PageView.builder(
                                    controller: detailsImageCubit.horizontalPageController,
                                    itemCount: imageUrls.length,
                                    physics: detailsImageState.currentPageIsZoomed
                                      ? NeverScrollableScrollPhysics()
                                      : BouncingScrollPhysics(),
                                    onPageChanged: (pIndex) {
                                      detailsImageCubit.updateHorizontalPage(pIndex); // Update the current page
                                    },
                                    itemBuilder: (context, pageIndex) {
                                      // final double screenWidth = MediaQuery.of(context).size.width;
                                      // Start the timer if it hasn't already started.
                                      final bool showError = detailsImageCubit.showError();
                                      if (!showError) {
                                        detailsImageCubit.startErrorTimer();
                                      } else {
                                        return Center(
                                          child: SizedBox(width: 180, child: Text(
                                            appLocalizations.pictureLoadingError,
                                            style: TextStyle(fontSize: 16.0),
                                            textAlign: TextAlign.center,
                                          )),
                                        );
                                      }
                                      return Stack(children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 16.0, bottom: 8, left: 16.0),
                                              child: Text(imageTypes[pageIndex], style: TextStyle(fontSize: 20)),
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minHeight: 0,
                                                maxHeight: 32,
                                              ),
                                              child: SizedBox.shrink(),
                                            ),
                                            Expanded(
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  detailsImageCubit.updateViewerSize(
                                                    List<Size>.from(detailsImageState.lViewerSize)
                                                      ..[pageIndex] = Size(constraints.maxWidth, constraints.maxHeight)
                                                  );
                                                  return InteractiveViewer(
                                                    maxScale: 16,
                                                    transformationController: detailsImageCubit.lTransformationController[pageIndex],
                                                    onInteractionUpdate: (_) {
                                                      final bool isZoomed = detailsImageCubit.lTransformationController[pageIndex].value.getMaxScaleOnAxis() > 1.0;
                                                      detailsImageCubit.updateIsZoomed(isZoomed);
                                                    },
                                                    onInteractionEnd: (_) {
                                                      final bool isZoomed = detailsImageCubit.lTransformationController[pageIndex].value.getMaxScaleOnAxis() > 1.0;
                                                      detailsImageCubit.updateIsZoomed(isZoomed);
                                                    },
                                                    child: Center(child: ImageWithCancel(
                                                      imageUrl: NS.apiDogUrl + NS.apiDogImagesPage + imageUrls[pageIndex],
                                                      fit: BoxFit.contain,
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (detailsImageCubit.currentHorizontalPage == pageIndex) {
                                                          if (loadingProgress == null) {
                                                            detailsImageCubit.updateIsLoading(false, pageIndex: pageIndex);
                                                            detailsImageCubit.cancelErrorTimer(); // Cancel timer if image loads
                                                            return child;
                                                          }
                                                          detailsImageCubit.updateIsLoading(true, pageIndex: pageIndex);
                                                          detailsImageCubit.startErrorTimer(); // Start timer while loading
                                                        }
                                                        return child;
                                                      },
                                                      errorBuilder: (context, error, stackTrace) {
                                                        detailsImageCubit.cancelErrorTimer(); // Cancel timer if error occurs
                                                        return Center(
                                                          child: SizedBox(width: 180, child: Text(
                                                              appLocalizations.pictureLoadingError,
                                                              style: TextStyle(fontSize: 16.0),
                                                              textAlign: TextAlign.center,
                                                          )),
                                                        );
                                                      },
                                                    )),
                                                  );
                                                },
                                              ),
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minHeight: 0,
                                                maxHeight: 32,
                                              ),
                                              child: SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                        // enlargement icon
                                        Positioned(
                                          top: 64,
                                          right: 16,
                                          child: GestureDetector(
                                            onTap: () => detailsImageCubit.toggleZoom(pageIndex),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black26,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: EdgeInsets.all(4),
                                              child: Icon(
                                                size: 42,
                                                detailsImageState.currentPageIsZoomed
                                                  ? Icons.zoom_out
                                                  : Icons.zoom_in,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]);
                                    },
                                  ),
                                  // Left arrow
                                  if (detailsImageState.currentHorizontalPage > 0)
                                    Positioned.fill(child:
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(padding: EdgeInsets.only(left: 16),
                                          child: Container(
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: Colors.black26,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.arrow_back,
                                                size: 32,
                                                color: Colors.white),
                                              constraints: BoxConstraints(
                                                maxHeight: 48),
                                              onPressed: () {
                                                detailsImageCubit.horizontalPageController.previousPage(
                                                  duration: Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Right arrow
                                  if (detailsImageState.currentHorizontalPage < imageUrls.length - 1)
                                    Positioned.fill(child:
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(padding: EdgeInsets.only(right: 16),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black26,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.arrow_forward, size: 32, color: Colors.white),
                                              onPressed: () {
                                                detailsImageCubit.horizontalPageController.nextPage(
                                                  duration: Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                if (detailsImageState.currentPageIsLoading)
                                  const Center(child: CustomSpinKitThreeInOut()),
                              ]);
                            },
                          ),
                        ),
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8, left: 16.0),
                            child: Column(children: [
                              SizedBox(height: 8),
                              wTitle,
                              SizedBox(height: 8),
                              wCoatStyle,
                              SizedBox(height: 8),
                              wCoatTexture,
                              SizedBox(height: 8),
                              wPersonalityTraits,
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          );
        }
      ),
    );
  }
}
