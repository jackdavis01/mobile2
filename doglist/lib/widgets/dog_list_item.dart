import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/dog.dart';
import '../parameters/netservices.dart';
import '../widgets/spinkitwidgets.dart';

class DogListItem extends StatelessWidget {
  final Dog dog;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final double imageSize;

  const DogListItem({
    super.key,
    required this.dog,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.imageSize = 56.0,
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
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "${dog.coatStyle}, ${dog.coatTexture}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Favorite button
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: onFavoritePressed,
            ),
          ],
        ),
      ),
    );
  }
}
