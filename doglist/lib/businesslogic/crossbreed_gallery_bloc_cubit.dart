import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/crossbreed_models.dart';
import '../repositories/crossbreed_repository.dart';
import '../services/crossbreed_image_cache_manager.dart';
import 'crossbreed_gallery_bloc_state.dart';

/// Gallery metadata (no-store JSON): refreshed on entry, pull-to-refresh and foreground resume.
///
/// Absence from one paginated response is not deletion. Only previously listed items that fall inside
/// the refreshed range (order `completedAt desc, pairId desc`) yet are missing get a detail check; a
/// `NOT_FOUND`/`PAIR_UNAVAILABLE` answer evicts both cached roles. Already cached public bytes elsewhere
/// are not promised to disappear immediately.
class CrossbreedGalleryCubit extends Cubit<CrossbreedGalleryState> with WidgetsBindingObserver {
  CrossbreedGalleryCubit({
    CrossbreedRepository? repository,
    CrossbreedMediaCache? mediaCache,
    this.pageSize = 20,
    this.maxVerifyPerRefresh = 10,
    bool observeLifecycle = true,
  })  : _repo = repository ?? ApiCrossbreedRepository.shared,
        _media = mediaCache ?? CrossbreedMediaCache(),
        _observing = observeLifecycle,
        super(const CrossbreedGalleryState()) {
    if (_observing) WidgetsBinding.instance.addObserver(this);
  }

  final CrossbreedRepository _repo;
  final CrossbreedMediaCache _media;
  final int pageSize;
  final int maxVerifyPerRefresh;
  final bool _observing;
  int _generation = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && this.state.loaded && !this.state.loading) refresh();
  }

  /// Applies a pair filter (null = all) and reloads from the first page.
  Future<void> setFilter(List<String>? dogIds) {
    _generation++;
    emit(CrossbreedGalleryState(dogIds: dogIds == null || dogIds.isEmpty ? null : List.unmodifiable(dogIds)));
    return refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    final previous = state.items;
    emit(state.copyWith(loading: true, loadingMore: false, errorCode: () => null));
    final CrossbreedGalleryPage page;
    try {
      page = await _repo.listGallery(limit: pageSize, dogIds: state.dogIds);
    } catch (e) {
      if (generation == _generation && !isClosed) {
        emit(state.copyWith(loading: false, errorCode: () => _code(e)));
      }
      return;
    }
    if (generation != _generation || isClosed) return;
    emit(state.copyWith(
      items: List.unmodifiable(page.items),
      nextCursor: () => page.nextCursor,
      loading: false,
      loaded: true,
      errorCode: () => null,
    ));
    await _verifyMissing(previous, page);
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loading || state.loadingMore) return;
    final generation = _generation;
    emit(state.copyWith(loadingMore: true, errorCode: () => null));
    try {
      final page = await _repo.listGallery(limit: pageSize, cursor: cursor, dogIds: state.dogIds);
      if (generation != _generation || isClosed) return;
      final known = {for (final r in state.items) r.pairId};
      emit(state.copyWith(
        items: List.unmodifiable([...state.items, ...page.items.where((r) => !known.contains(r.pairId))]),
        nextCursor: () => page.nextCursor,
        loadingMore: false,
      ));
    } catch (e) {
      if (generation == _generation && !isClosed) emit(state.copyWith(loadingMore: false, errorCode: () => _code(e)));
    }
  }

  /// Called when a detail/status check elsewhere (e.g. the result page) found the pair hidden.
  void removeUnavailable(String pairId) {
    if (isClosed || !state.items.any((r) => r.pairId == pairId)) return;
    emit(state.copyWith(items: List.unmodifiable(state.items.where((r) => r.pairId != pairId))));
  }

  Future<void> _verifyMissing(List<CrossbreedResult> previous, CrossbreedGalleryPage page) async {
    if (previous.isEmpty) return;
    final listed = {for (final r in page.items) r.pairId};
    final boundary = page.nextCursor == null || page.items.isEmpty ? null : page.items.last;
    final candidates = previous
        .where((r) => !listed.contains(r.pairId) && (boundary == null || !_isAfter(boundary, r)))
        .take(maxVerifyPerRefresh);
    for (final r in candidates) {
      try {
        await _repo.getGalleryItem(r.pairId);
      } on CrossbreedApiException catch (e) {
        if (e.code == 'NOT_FOUND' || e.code == 'PAIR_UNAVAILABLE') {
          await _media.evict(r);
          removeUnavailable(r.pairId);
        }
      } catch (_) {
        // Unknown: keep the cache; a later detail/status check decides.
      }
    }
  }

  /// True when [b] sorts after (i.e. older than) [a] in `completedAt desc, pairId desc` order.
  static bool _isAfter(CrossbreedResult a, CrossbreedResult b) {
    final byTime = b.completedAt.compareTo(a.completedAt);
    if (byTime != 0) return byTime < 0;
    return b.pairId.compareTo(a.pairId) < 0;
  }

  static String _code(Object e) => e is CrossbreedApiException ? e.code : 'INTERNAL_ERROR';

  @override
  Future<void> close() {
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
