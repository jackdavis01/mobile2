import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/crossbreed_gallery_bloc_cubit.dart';
import '../businesslogic/crossbreed_gallery_bloc_state.dart';
import '../models/crossbreed_models.dart' show CrossbreedResult;
import '../repositories/crossbreed_repository.dart';
import '../services/crossbreed_image_cache_manager.dart';
import '../widgets/ad_banner.dart';
import '../widgets/crossbreed_image.dart';
import 'crossbreed_result_page.dart';

/// Public gallery of published AI crossbreeds. Browsing is free of rewarded ads; the bottom banner is
/// independent of Generate and never satisfies its rewarded requirement.
///
/// Route arguments (optional): `{'dogIds': [a, b], 'names': [nameA, nameB]}` opens one pair.
class CrossbreedGalleryScreen extends StatelessWidget {
  const CrossbreedGalleryScreen(
      {super.key, this.dogIds, this.names, this.cubit, this.repository, this.mediaCache, this.imageCacheManager});

  final List<String>? dogIds;
  final List<String>? names;

  /// Injected in tests (caller loads it); otherwise a page-scoped cubit is created and loaded.
  final CrossbreedGalleryCubit? cubit;
  final CrossbreedRepository? repository;
  final CrossbreedMediaCache? mediaCache;
  final BaseCacheManager? imageCacheManager;

  static const routeName = '/crossbreed-gallery';

  static Widget fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final ids = (args['dogIds'] as List?)?.cast<String>();
      final names = (args['names'] as List?)?.cast<String>();
      if (ids != null && ids.length == 2) return CrossbreedGalleryScreen(dogIds: ids, names: names);
    }
    return const CrossbreedGalleryScreen();
  }

  @override
  Widget build(BuildContext context) {
    final child = _GalleryView(
        initialNames: names, repository: repository, mediaCache: mediaCache, imageCacheManager: imageCacheManager);
    if (cubit != null) return BlocProvider.value(value: cubit!, child: child);
    return BlocProvider(
      create: (_) => CrossbreedGalleryCubit(repository: repository, mediaCache: mediaCache)..setFilter(dogIds),
      child: child,
    );
  }
}

class _GalleryView extends StatefulWidget {
  const _GalleryView({this.initialNames, this.repository, this.mediaCache, this.imageCacheManager});

  final List<String>? initialNames;
  final CrossbreedRepository? repository;
  final CrossbreedMediaCache? mediaCache;
  final BaseCacheManager? imageCacheManager;

  @override
  State<_GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<_GalleryView> {
  bool _loadMoreScheduled = false;

  void _maybeLoadMore(CrossbreedGalleryCubit cubit) {
    if (_loadMoreScheduled) return;
    _loadMoreScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMoreScheduled = false;
      if (mounted) cubit.loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return Scaffold(
      appBar: AppBar(title: Text(l.crossbreedGalleryTitle), centerTitle: true),
      body: BlocBuilder<CrossbreedGalleryCubit, CrossbreedGalleryState>(
        builder: (context, state) {
          final cubit = context.read<CrossbreedGalleryCubit>();
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: Text(l.crossbreedGalleryDisclosure,
                        textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
                if (state.dogIds != null)
                  SliverToBoxAdapter(
                    child: Center(
                      child: InputChip(
                        avatar: const Icon(Icons.filter_alt, size: 18),
                        label: Text((widget.initialNames ?? state.dogIds!).join(' × ')),
                        onDeleted: () => cubit.setFilter(null),
                      ),
                    ),
                  ),
                ..._content(context, l, state, cubit),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [AdBanner()],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, AppLocalizations l, CrossbreedGalleryState state, CrossbreedGalleryCubit cubit) {
    if (state.items.isEmpty) {
      final Widget child;
      if (!state.loaded && state.errorCode == null) {
        child = const CircularProgressIndicator();
      } else if (state.errorCode != null) {
        child = _ErrorRow(text: l.crossbreedGalleryError, onRetry: cubit.refresh);
      } else {
        child = Text(state.dogIds != null ? l.crossbreedGalleryFilteredEmpty : l.crossbreedGalleryEmpty,
            textAlign: TextAlign.center);
      }
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Padding(padding: const EdgeInsets.all(24), child: child)),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (state.hasMore && index >= state.items.length - 4) _maybeLoadMore(cubit);
              final r = state.items[index];
              return _GalleryTile(
                result: r,
                cacheManager: widget.imageCacheManager,
                onTap: () => Navigator.of(context).push(CrossbreedResultPage.route(
                      r,
                      onUnavailable: cubit.removeUnavailable,
                      repository: widget.repository,
                      mediaCache: widget.mediaCache,
                      imageCacheManager: widget.imageCacheManager,
                    )),
              );
            },
            childCount: state.items.length,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: state.loadingMore
              ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
              : state.errorCode != null
                  ? _ErrorRow(text: l.crossbreedGalleryError, onRetry: state.hasMore ? cubit.loadMore : cubit.refresh)
                  : const SizedBox.shrink(),
        ),
      ),
    ];
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.result, required this.onTap, this.cacheManager});

  final CrossbreedResult result;
  final BaseCacheManager? cacheManager;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return Semantics(
      button: true,
      label: '${result.breedNames.join(' × ')}, ${l.crossbreedAiLabel}',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(fit: StackFit.expand, children: [
                  CrossbreedImage(result: result, role: CrossbreedImageRole.thumbnail, cacheManager: cacheManager),
                  const Positioned(
                    right: 6,
                    top: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x99000000), shape: BoxShape.circle),
                      child: Padding(padding: EdgeInsets.all(4), child: Icon(Icons.auto_awesome, size: 14, color: Colors.white)),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              result.breedNames.join(' × '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.text, required this.onRetry});

  final String text;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(text, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        TextButton(onPressed: onRetry, child: Text(l.crossbreedGalleryRetry)),
      ]),
    );
  }
}
