import 'package:flutter_bloc/flutter_bloc.dart';
import 'compare_bloc_state.dart';
import '../repositories/compare_repository.dart';

class CompareCubit extends Cubit<CompareState> {
  final CompareRepository _repository = CompareRepository();

  CompareCubit() : super(CompareState.initial()) {
    loadPinned();
  }

  Future<void> loadPinned() async {
    try {
      final ids = await _repository.getPinnedIds();
      emit(state.copyWith(pinnedIds: ids));
    } catch (e) {
      // Keep the initial empty state on failure
    }
  }

  bool isPinned(String dogId) => state.pinnedIds.contains(dogId);

  /// Toggles the pinned state for [dogId]. Returns false if the pin was
  /// rejected because two breeds are already pinned.
  Future<bool> togglePin(String dogId) async {
    final ids = List<String>.from(state.pinnedIds);

    if (ids.contains(dogId)) {
      ids.remove(dogId);
    } else {
      if (ids.length >= 2) return false;
      ids.add(dogId);
    }

    await _repository.savePinnedIds(ids);
    emit(state.copyWith(pinnedIds: ids));
    return true;
  }
}
