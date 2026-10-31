import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../models/crossbreed_models.dart';
import '../services/crossbreed_image_cache_manager.dart';

enum CrossbreedImageRole { thumbnail, original }

/// Renders one crossbreed media role from its absolute permanent URL through the shared crossbreed
/// cache. Decoding is bounded to the displayed size (and never above the role's native size).
/// Failed downloads offer a retry of the same URL; they never request a new generation.
class CrossbreedImage extends StatefulWidget {
  const CrossbreedImage({
    super.key,
    required this.result,
    required this.role,
    this.fit = BoxFit.cover,
    this.cacheManager,
  });

  final CrossbreedResult result;
  final CrossbreedImageRole role;
  final BoxFit fit;
  final BaseCacheManager? cacheManager;

  String get url => role == CrossbreedImageRole.thumbnail ? result.thumbnailUrl : result.imageUrl;

  int get nativeSize => role == CrossbreedImageRole.thumbnail ? CrossbreedResult.thumbnailSize : CrossbreedResult.originalSize;

  @override
  State<CrossbreedImage> createState() => _CrossbreedImageState();
}

class _CrossbreedImageState extends State<CrossbreedImage> {
  int _attempt = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    return LayoutBuilder(builder: (context, constraints) {
      final logical = constraints.biggest.shortestSide.isFinite ? constraints.biggest.shortestSide : widget.nativeSize.toDouble();
      final decode = min(widget.nativeSize, max(1, (logical * dpr).ceil()));
      final url = widget.url;
      return CachedNetworkImage(
        key: ValueKey('$url#$_attempt'),
        imageUrl: url,
        cacheKey: url,
        cacheManager: widget.cacheManager ?? CrossbreedImageCacheManager(),
        memCacheWidth: decode,
        fit: widget.fit,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (context, _) => const ColoredBox(
          color: Color(0x14000000),
          child: Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
        errorWidget: (context, _, __) => ColoredBox(
          color: const Color(0x14000000),
          child: Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _attempt++),
              icon: const Icon(Icons.refresh),
              label: Text(l.crossbreedImageRetry),
            ),
          ),
        ),
      );
    });
  }
}
