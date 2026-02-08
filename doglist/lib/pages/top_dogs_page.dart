import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/top_dogs_bloc_cubit.dart';
import '../businesslogic/top_dogs_bloc_state.dart';
import '../models/dog.dart';
import '../parameters/netservices.dart';
import '../widgets/spinkitwidgets.dart';

/// Top 3 Dogs Starting Page
/// Shows the top 3 most liked dogs with large photos and navigation buttons
class TopDogsPage extends StatelessWidget {
  const TopDogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopDogsCubit(),
      child: const _TopDogsPageContent(),
    );
  }
}

class _TopDogsPageContent extends StatelessWidget {
  const _TopDogsPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopDogsCubit, TopDogsState>(
      builder: (context, state) {
        return Scaffold(
          body: state.loading
              ? const Center(child: CustomSpinKitThreeInOut())
              : state.topDogs.isEmpty
                  ? _buildErrorView(context, state)
                  : _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, TopDogsState state) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();
    
    // Translate error codes to localized messages
    String errorMessage;
    switch (state.errorCode) {
      case TopDogsErrorCode.offlineCache:
        errorMessage = appLocalizations.topDogsOfflineCache;
        break;
      case TopDogsErrorCode.loadFailed:
        errorMessage = appLocalizations.topDogsLoadError(state.errorDetails ?? '');
        break;
      case TopDogsErrorCode.noData:
        errorMessage = appLocalizations.topDogsUnableToLoad;
        break;
      case null:
        errorMessage = appLocalizations.topDogsNoDataAvailable;
        break;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TopDogsCubit>().retry(),
            child: Text(appLocalizations.topDogsRetry),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _navigateToList(context),
            child: Text(appLocalizations.topDogsGoToList),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, TopDogsState state) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();
    
    return Column(
      children: [
        // Upper half: Single large photo (1st place) - 50% of screen
        if (state.topDogs.isNotEmpty)
          Expanded(
            child: _buildDogPhoto(
              context: context,
              dogId: state.topDogs[0].dogId,
              likes: state.topDogs[0].totalLikes,
              isTopPhoto: true,
              rank: 1,
              allDogs: state.allDogs,
            ),
          ),
        
        // Lower half: Two photos side by side (2nd and 3rd place) - 50% of screen
        Expanded(
          child: Row(
            children: [
              // 2nd place - 50% width
              if (state.topDogs.length > 1)
                Expanded(
                  child: _buildDogPhoto(
                    context: context,
                    dogId: state.topDogs[1].dogId,
                    likes: state.topDogs[1].totalLikes,
                    isTopPhoto: false,
                    rank: 2,
                    allDogs: state.allDogs,
                  ),
                ),
              
              // 3rd place - 50% width
              if (state.topDogs.length > 2)
                Expanded(
                  child: _buildDogPhoto(
                    context: context,
                    dogId: state.topDogs[2].dogId,
                    likes: state.topDogs[2].totalLikes,
                    isTopPhoto: false,
                    rank: 3,
                    allDogs: state.allDogs,
                  ),
                ),
            ],
          ),
        ),
        
        // Two buttons at bottom - no margin/spacing between them and photos above
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // "Dog breeds" button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToList(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      appLocalizations.topDogsBreedsButton,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // "Filter breeds" button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToFilter(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      appLocalizations.topDogsFilterButton,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Dog? _getDogById(String dogId, List<Dog> allDogs) {
    try {
      return allDogs.firstWhere((dog) => dog.id == dogId);
    } catch (e) {
      return null;
    }
  }

  void _navigateToDogDetails(BuildContext context, String dogId, List<Dog> allDogs) {
    final dog = _getDogById(dogId, allDogs);
    if (dog == null) return;

    final dogIndex = allDogs.indexWhere((d) => d.id == dogId);
    if (dogIndex == -1) return;

    Navigator.pushNamed(
      context,
      '/details',
      arguments: {
        'dogs': allDogs,
        'index': dogIndex,
      },
    );
  }

  void _navigateToList(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/list', (route) => false);
  }

  void _navigateToFilter(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pushNamedAndRemoveUntil('/list', (route) => false);
    navigator.pushNamed('/filter');
  }

  Widget _buildDogPhoto({
    required BuildContext context,
    required String dogId,
    required int likes,
    required bool isTopPhoto,
    required int rank,
    required List<Dog> allDogs,
  }) {
    final AppLocalizations appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();
    
    final dog = _getDogById(dogId, allDogs);
    if (dog == null) {
      return Container(
        color: Colors.grey[300],
        child: Center(child: Text(appLocalizations.topDogsDogNotFound)),
      );
    }

    final imageUrl = NS.apiDogUrl + NS.apiDogImagesPage + dog.images.largeOutdoors;

    return GestureDetector(
      onTap: () => _navigateToDogDetails(context, dogId, allDogs),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate max width for breed name to prevent overlap
          // Leave space for: right margin (8) + likes counter (~70px) + gap (16)
          final maxBreedNameWidth = constraints.maxWidth - 94;
          
          // Get system status bar height for Top 1 badge
          final statusBarHeight = MediaQuery.of(context).padding.top;
          final topMargin = isTopPhoto ? statusBarHeight + 8 : 8.0;
          
          return Stack(
            fit: StackFit.expand,
            children: [
              // Dog photo - fills entire space with no margins
              CachedNetworkImage(
                imageUrl: imageUrl,
                cacheManager: LongTermCacheManager(),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CustomSpinKitThreeInOut()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
                ),
              ),
              // Semi-transparent overlays with text
              // Bottom-left: Dog breed name
              Positioned(
                bottom: 8,
                left: 8,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxBreedNameWidth,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      dog.name,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom-right: Likes with yellow/amber thumb up icon
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.thumb_up,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Top-right: Rank badge ("Top 1", "Top 2", "Top 3")
              Positioned(
                top: topMargin,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    appLocalizations.topDogsRank(rank),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
