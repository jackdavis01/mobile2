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

class DogListItem extends StatelessWidget {
  final Dog dog;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggled;
  final VoidCallback? onBestToggled;
  final EdgeInsets padding;
  final double imageSize;
  final bool enableDiscovery;

  const DogListItem({
    super.key,
    required this.dog,
    required this.onTap,
    this.onFavoriteToggled,
    this.onBestToggled,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.imageSize = 56.0,
    this.enableDiscovery = false,
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
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "${dog.coatStyle}, ${dog.coatTexture}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Best star button
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
