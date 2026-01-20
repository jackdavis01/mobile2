import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dog.dart';
import '../parameters/netservices.dart';
import '../parameters/feature_ids.dart';
import '../widgets/spinkitwidgets.dart';
import '../widgets/feature_overlays.dart';
import '../businesslogic/user_preferences_bloc_cubit.dart';
import '../businesslogic/user_preferences_bloc_state.dart';
import '../businesslogic/like_bloc_cubit.dart';
import '../businesslogic/like_bloc_state.dart';
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

  @override
  Widget build(BuildContext context) {
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
                  // Like count row
                  BlocBuilder<LikeCubit, LikeState>(
                    builder: (context, state) {
                      final likeCount = state.likeCounts[dog.id] ?? 0;
                      return Text(
                        '👍 $likeCount ${likeCount == 1 ? 'like' : 'likes'}',
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
                      return IconButton(
                        padding: EdgeInsets.only(bottom: 2.5),
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked ? Colors.amber : null,
                          size: 29.0,
                        ),
                        onPressed: () async {
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
                            // Like the dog
                            final success = await context.read<LikeCubit>().likeDog(dog.id);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Liked ${dog.name}! 👍'),
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
