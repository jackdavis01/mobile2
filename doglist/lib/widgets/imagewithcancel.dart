import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../parameters/netservices.dart';

class ImageWithCancel extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext, Object?, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;

  const ImageWithCancel({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  });

  @override
  State<ImageWithCancel> createState() => _ImageWithCancelState();
}

class _ImageWithCancelState extends State<ImageWithCancel> {
  late CachedNetworkImageProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CachedNetworkImageProvider(
      widget.imageUrl,
      cacheManager: LongTermCacheManager(),
    );
  }

  @override
  void dispose() {
    // If the widget disappears, the cache manager won't load further
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: _provider,
      fit: widget.fit,
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
    );
  }
}