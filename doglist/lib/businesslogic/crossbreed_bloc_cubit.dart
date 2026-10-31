import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<bool> startGenerate({required List<String> displayDogIds, required String catalogVersion}) =>
      _coordinator.startGenerate(displayDogIds: displayDogIds, catalogVersion: catalogVersion);

  Future<void> recordAdEarned() => _coordinator.recordAdEarned();
  Future<void> recordAdDismissed() => _coordinator.recordAdDismissed();
  Future<void> retry() => _coordinator.recover();
  Future<bool> cancel() => _coordinator.cancel();
  Future<void> acknowledge() => _coordinator.acknowledge();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
