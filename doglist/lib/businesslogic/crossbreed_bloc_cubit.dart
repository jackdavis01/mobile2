import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/crossbreed_models.dart';
import '../services/crossbreed_coordinator.dart';
import 'crossbreed_bloc_state.dart';

/// Page-facing view of the app-wide [CrossbreedCoordinator]. Closing the cubit never cancels the
/// pending command; the coordinator keeps it alive.
class CrossbreedCubit extends Cubit<CrossbreedFlowState> {
  CrossbreedCubit({CrossbreedCoordinator? coordinator})
      : _coordinator = coordinator ?? CrossbreedCoordinator.instance,
        super((coordinator ?? CrossbreedCoordinator.instance).state) {
    _subscription = _coordinator.stream.listen(emit);
  }

  final CrossbreedCoordinator _coordinator;
  late final StreamSubscription<CrossbreedFlowState> _subscription;

  bool get adsSupported => _coordinator.adsSupported;

  /// True while any Generate command (for any pair) is persisted and unfinished.
  bool get hasPendingCommand => _coordinator.pendingCommand != null;

  Future<CrossbreedSourcePreview> previewSources(String firstDogId, String secondDogId) =>
      _coordinator.previewSources(firstDogId, secondDogId);

  /// One explicit Generate action: creates a new intent, then shows a fresh rewarded ad.
  Future<bool> generate({required List<String> displayDogIds, required String catalogVersion}) async {
    final started = await _coordinator.startGenerate(displayDogIds: displayDogIds, catalogVersion: catalogVersion);
    if (started) await _coordinator.watchAd();
    return started;
  }

  /// Shows another ad for the same pending intent (after no fill, failure or a skipped reward).
  Future<void> watchAd() => _coordinator.watchAd();
  Future<void> retry() => _coordinator.recover();
  Future<bool> cancel() => _coordinator.cancel();
  Future<void> acknowledge() => _coordinator.acknowledge();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
