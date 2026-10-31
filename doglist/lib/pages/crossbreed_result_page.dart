import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../models/crossbreed_models.dart';
import '../repositories/crossbreed_repository.dart';
import '../services/crossbreed_image_cache_manager.dart';
import '../widgets/crossbreed_image.dart';

/// Full-screen view of one published crossbreed. Opened only from a succeeded Generate action or from
/// the gallery; it never starts a generation. The pair is re-checked in the background and both cached
/// roles are evicted when the backend reports it hidden/unavailable.
class CrossbreedResultPage extends StatefulWidget {
  const CrossbreedResultPage({
    super.key,
    required this.result,
    this.fulfillment,
    this.repository,
    this.mediaCache,
    this.onUnavailable,
    this.imageCacheManager,
  });

  final CrossbreedResult result;

  /// Set when opened from a Generate action (reused/joined/generated); null from the gallery.
  final FulfillmentKind? fulfillment;
  final CrossbreedRepository? repository;
  final CrossbreedMediaCache? mediaCache;
  final void Function(String pairId)? onUnavailable;
  final BaseCacheManager? imageCacheManager;

  static Route<void> route(CrossbreedResult result,
          {FulfillmentKind? fulfillment,
          void Function(String pairId)? onUnavailable,
          CrossbreedRepository? repository,
          CrossbreedMediaCache? mediaCache,
          BaseCacheManager? imageCacheManager}) =>
      MaterialPageRoute(
        builder: (_) => CrossbreedResultPage(
          result: result,
          fulfillment: fulfillment,
          onUnavailable: onUnavailable,
          repository: repository,
          mediaCache: mediaCache,
          imageCacheManager: imageCacheManager,
        ),
      );

  @override
  State<CrossbreedResultPage> createState() => _CrossbreedResultPageState();
}

class _CrossbreedResultPageState extends State<CrossbreedResultPage> {
  bool _unavailable = false;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    try {
      await (widget.repository ?? ApiCrossbreedRepository.shared).getGalleryItem(widget.result.pairId);
    } on CrossbreedApiException catch (e) {
      if (e.code != 'NOT_FOUND' && e.code != 'PAIR_UNAVAILABLE') return;
      await (widget.mediaCache ?? CrossbreedMediaCache()).evict(widget.result);
      widget.onUnavailable?.call(widget.result.pairId);
      if (mounted) setState(() => _unavailable = true);
    } catch (_) {
      // Offline or unexpected: keep showing the permanent image.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final r = widget.result;
    final names = r.breedNames.join(' × ');
    return Scaffold(
      appBar: AppBar(title: Text(names)),
      body: SafeArea(
        top: false,
        child: _unavailable
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.crossbreedNoLongerAvailable, textAlign: TextAlign.center),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InteractiveViewer(
                        maxScale: 4,
                        child: CrossbreedImage(
                            result: r,
                            role: CrossbreedImageRole.original,
                            fit: BoxFit.contain,
                            cacheManager: widget.imageCacheManager),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: 6),
                    Text(l.crossbreedAiLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 8),
                  Text(l.crossbreedBasedOn(r.breedNames[0], r.breedNames[1]), textAlign: TextAlign.center),
                  if (widget.fulfillment == FulfillmentKind.reused) ...[
                    const SizedBox(height: 8),
                    Text(l.crossbreedReusedNote, textAlign: TextAlign.center),
                  ],
                ],
              ),
      ),
    );
  }
}
