import '../models/crossbreed_models.dart';

class CrossbreedGalleryState {
  const CrossbreedGalleryState({
    this.items = const [],
    this.nextCursor,
    this.dogIds,
    this.loading = false,
    this.loadingMore = false,
    this.loaded = false,
    this.errorCode,
  });

  final List<CrossbreedResult> items;
  final String? nextCursor;

  /// Optional pair filter (one or two dog IDs); null shows every published pair.
  final List<String>? dogIds;

  /// First page / refresh in flight (existing items stay visible).
  final bool loading;
  final bool loadingMore;

  /// At least one page loaded successfully for the current filter.
  final bool loaded;

  /// Safe error code of the last failed request; existing items are kept.
  final String? errorCode;

  bool get hasMore => nextCursor != null;
  bool get isEmpty => loaded && items.isEmpty;

  CrossbreedGalleryState copyWith({
    List<CrossbreedResult>? items,
    String? Function()? nextCursor,
    List<String>? Function()? dogIds,
    bool? loading,
    bool? loadingMore,
    bool? loaded,
    String? Function()? errorCode,
  }) =>
      CrossbreedGalleryState(
        items: items ?? this.items,
        nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
        dogIds: dogIds != null ? dogIds() : this.dogIds,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        loaded: loaded ?? this.loaded,
        errorCode: errorCode != null ? errorCode() : this.errorCode,
      );
}
