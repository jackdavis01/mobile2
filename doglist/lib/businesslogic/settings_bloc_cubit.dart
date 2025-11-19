import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_bloc_state.dart';
import '../widgets/quick_filter_buttons.dart';
import '../repositories/settings_repository.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository = SettingsRepository();

  SettingsCubit() : super(SettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final visibility = await _repository.getQuickFilterVisibility();
      final isDisabled = await _repository.getFirstXTimesDisabled();
      emit(state.copyWith(
        quickFilterVisibility: visibility,
        isFirstXTimesDisabled: isDisabled,
      ));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setQuickFilterVisibility(QuickFilterVisibility visibility) async {
    try {
      await _repository.setQuickFilterVisibility(visibility);
      emit(state.copyWith(quickFilterVisibility: visibility));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setFirstXTimesDisabled(bool disabled) async {
    try {
      await _repository.setFirstXTimesDisabled(disabled);
      emit(state.copyWith(isFirstXTimesDisabled: disabled));
    } catch (e) {
      // Handle error silently
    }
  }
}
