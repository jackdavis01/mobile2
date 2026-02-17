import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../platform/platform_info.dart';
import '../models/dog.dart';
import '../parameters/netservices.dart';
import '../parameters/feature_ids.dart';
import '../widgets/spinkitwidgets.dart';
import '../widgets/feature_overlays.dart';
import '../businesslogic/user_preferences_bloc_cubit.dart';
import '../businesslogic/user_preferences_bloc_state.dart';
import '../businesslogic/like_bloc_cubit.dart';
import '../businesslogic/like_bloc_state.dart';
import '../services/like_cache_service.dart';
import 'like_cooldown_dialog.dart';

enum DogListItemType {
  list,   // Show like icon (for list page)
  filter, // Show best dog icon (for filter page)
}

class DogListItem extends StatelessWidget {
  final Dog dog;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggled;
  final VoidCallback? onBestToggled;
  final EdgeInsets padding;
  final double imageSize;
  final bool enableDiscovery;
  final DogListItemType type;

  const DogListItem({
    super.key,
    required this.dog,
    required this.onTap,
    this.onFavoriteToggled,
    this.onBestToggled,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.imageSize = 56.0,
    this.enableDiscovery = false,
    this.type = DogListItemType.filter,
  });

  String _getLocalizedError(String? errorCode, String dogName, AppLocalizations localizations) {
    if (errorCode == null) return localizations.likeFailedToLike(dogName);
    
    switch (errorCode) {
      case 'FAILED_TO_LOAD_COUNTS':
        return localizations.likeFailedToLoadCounts('');
      case 'FAILED_TO_LOAD_SPECIFIC_COUNTS':
        return localizations.likeFailedToLoadSpecificCounts('');
      case 'FAILED_TO_LIKE':
        return localizations.likeFailedGeneric;
      case 'UNEXPECTED_ERROR':
        return localizations.likeUnexpectedError;
      default:
        // If error message contains specific text, use it; otherwise use generic
        return errorCode.isNotEmpty ? errorCode : localizations.likeFailedToLike(dogName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            // Leading image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: NS.apiDogUrl + NS.apiDogImagesPage + dog.images.smallOutdoors,
                cacheManager: LongTermCacheManager(),
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                placeholder: (context, url) => SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: const FittedBox(
                    fit: BoxFit.contain,
                    child: Center(
                      child: CustomSpinKitThreeInOut(),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                      Icons.image,
                      size: imageSize,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dog.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.28
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${dog.coatStyle}, ${dog.coatTexture}",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.28,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Like count row - hidden on web
                  if (!PlatformInfo.isWeb)
                    BlocBuilder<LikeCubit, LikeState>(
                    builder: (context, state) {
                      final likeCount = state.likeCounts[dog.id] ?? 0;
                      
                      // Check if cache expired and queue refresh (lazy loading)
                      // Only queue if we have a count in state (meaning initial load completed)
                      // but cache is expired (meaning it's stale)
                      final cacheService = LikeCacheService();
                      final hasCachedCount = cacheService.hasCachedCount(dog.id);
                      final hasStateCount = state.likeCounts.containsKey(dog.id);
                      
                      if (hasStateCount && !hasCachedCount) {
                        // We have a count in state but cache expired - queue for refresh
                        debugPrint('[DogListItem] Cache expired for ${dog.id}, queueing refresh');
                        context.read<LikeCubit>().queueLikeCountRefresh(dog.id);
                      }
                      
                      return Text(
                        '👍 ${appLocalizations.likeCount(likeCount)}',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.28,
                          color: Colors.purple.shade900,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Like button (list mode) or Best star button (filter mode)
            if (type == DogListItemType.list)
              BlocBuilder<LikeCubit, LikeState>(
                builder: (context, state) {
                  return FutureBuilder<bool>(
                    future: context.read<LikeCubit>().isLikedByUser(dog.id),
                    builder: (context, snapshot) {
                      final isLiked = snapshot.data ?? false;
                      final isLoading = state.isLoading;
                      
                      return IconButton(
                        padding: EdgeInsets.only(bottom: 1.0),
                        icon: isLoading
                            ? SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.amber,
                                ),
                              )
                            : Icon(
                                isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                color: isLiked ? Colors.amber : null,
                                size: 25.0,
                              ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                // On web, show dialog to download app
                                if (PlatformInfo.isWeb) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(appLocalizations.likeWebDialogTitle),
                                      content: Text(appLocalizations.likeWebDialogMessage),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text(appLocalizations.likeDialogOk),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                                if (isLiked) {
                                  // Show cooldown dialog
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => LikeCooldownDialog(
                                      dogId: dog.id,
                                      dogName: dog.name,
                                    ),
                                  );
                                } else {
                                  // Optimistic update
                                  final likeCubit = context.read<LikeCubit>();
                                  likeCubit.incrementLikeCountOptimistically(dog.id);
                                  
                                  // Like the dog
                                  final success = await likeCubit.likeDog(dog.id);
                                  
                                  if (!success) {
                                    // Revert on failure
                                    likeCubit.revertLikeCount(dog.id);
                                    
                                    if (context.mounted) {
                                      // Get the latest state from the cubit (state variable may be stale)
                                      final latestState = likeCubit.state;
                                      
                                      // Show cooldown dialog for ALREADY_LIKED_TODAY error
                                      if (latestState.error == 'ALREADY_LIKED_TODAY') {
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) => LikeCooldownDialog(
                                            dogId: dog.id,
                                            dogName: dog.name,
                                          ),
                                        );
                                      } else {
                                        // Show snackbar for other errors
                                        final errorMsg = _getLocalizedError(latestState.error, dog.name, appLocalizations);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              errorMsg,
                                              style: const TextStyle(fontSize: 15),
                                            ),
                                            backgroundColor: Colors.red.shade700,
                                            duration: const Duration(seconds: 4),
                                            action: SnackBarAction(
                                              label: appLocalizations.likeRetry,
                                              textColor: Colors.white,
                                              onPressed: () async {
                                                likeCubit.incrementLikeCountOptimistically(dog.id);
                                                final retrySuccess = await likeCubit.likeDog(dog.id);
                                                if (!retrySuccess) {
                                                  likeCubit.revertLikeCount(dog.id);
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          appLocalizations.likeSuccess(dog.name),
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        backgroundColor: Colors.green.shade700,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                      );
                    },
                  );
                },
              )
            else
              BlocBuilder<UserPreferencesCubit, UserPreferencesState>(
                builder: (context, state) {
                  final cubit = context.read<UserPreferencesCubit>();
                  final isBest = cubit.isBest(dog.id);

                  return IconButton(
                    padding: EdgeInsets.only(bottom: 2.5),
                    icon: Icon(
                      isBest ? Icons.star : Icons.star_border,
                      color: isBest ? Colors.amber : null,
                      size: 29.0,
                    ),
                    onPressed: () async {
                      await cubit.toggleBestDog(dog.id);
                      onBestToggled?.call();
                    },
                  );
                },
              ),
            // Favorite button
            BlocBuilder<UserPreferencesCubit, UserPreferencesState>(
              builder: (context, state) {
                final cubit = context.read<UserPreferencesCubit>();
                final isFavorite = cubit.isFavorite(dog.id);

                final favoriteButton = IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () async {
                    await cubit.toggleFavorite(dog);
                    onFavoriteToggled?.call();
                  },
                );

                // Only wrap first item with discovery overlay
                if (enableDiscovery) {
                  return ListFavoriteButtonDiscoveryOverlay(
                    featureId: FeatureIds.listFavoriteButton,
                    child: favoriteButton,
                  );
                }

                return favoriteButton;
              },
            ),
          ],
        ),
      ),
    );
  }
}
