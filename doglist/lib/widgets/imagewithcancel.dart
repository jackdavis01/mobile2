import 'package:flutter/material.dart';

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
  ImageWithCancelState createState() => ImageWithCancelState();
}

class ImageWithCancelState extends State<ImageWithCancel> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    final ImageProvider imageProvider = NetworkImage(widget.imageUrl);
    _imageStream = imageProvider.resolve(const ImageConfiguration());
    _imageStreamListener = ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        setState(() {}); // Rebuild when the image is loaded
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (widget.errorBuilder != null) {
          setState(() {}); // Rebuild to show the error widget
        }
      },
    );
    _imageStream?.addListener(_imageStreamListener!);
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageStreamListener!); // Stop the image loading
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider = NetworkImage(widget.imageUrl);
    return Image(
      image: imageProvider,
      fit: widget.fit,
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
    );
  }
}