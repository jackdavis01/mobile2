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
      final listPageDiscovery = await _repository.getListPageDiscoveryEnabled();
      final detailsPageDiscovery = await _repository.getDetailsPageDiscoveryEnabled();
      final filterPageDiscovery = await _repository.getFilterPageDiscoveryEnabled();
      final navigationPageDiscovery = await _repository.getNavigationPageDiscoveryEnabled();
      emit(state.copyWith(
        quickFilterVisibility: visibility,
        isFirstXTimesDisabled: isDisabled,
        listPageDiscoveryEnabled: listPageDiscovery,
        detailsPageDiscoveryEnabled: detailsPageDiscovery,
        filterPageDiscoveryEnabled: filterPageDiscovery,
        navigationPageDiscoveryEnabled: navigationPageDiscovery,
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

  Future<void> toggleListPageDiscovery(bool value) async {
    try {
      await _repository.setListPageDiscoveryEnabled(value);
      // Clear completion preferences when re-enabling
      if (value) {
        await _repository.clearListPageFeatureDiscoveryPreferences();
      }
      emit(state.copyWith(
        listPageDiscoveryEnabled: value,
      ));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleDetailsPageDiscovery(bool value) async {
    try {
      await _repository.setDetailsPageDiscoveryEnabled(value);
      // Clear completion preferences when re-enabling
      if (value) {
        await _repository.clearDetailsPageFeatureDiscoveryPreferences();
      }
      emit(state.copyWith(
        detailsPageDiscoveryEnabled: value,
      ));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleFilterPageDiscovery(bool value) async {
    try {
      await _repository.setFilterPageDiscoveryEnabled(value);
      // Clear completion preferences when re-enabling
      if (value) {
        await _repository.clearFilterPageFeatureDiscoveryPreferences();
      }
      emit(state.copyWith(
        filterPageDiscoveryEnabled: value,
      ));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleNavigationPageDiscovery(bool value) async {
    try {
      await _repository.setNavigationPageDiscoveryEnabled(value);
      // Clear completion preferences when re-enabling
      if (value) {
        await _repository.clearNavigationPageFeatureDiscoveryPreferences();
      }
      emit(state.copyWith(
        navigationPageDiscoveryEnabled: value,
      ));
    } catch (e) {
      // Handle error silently
    }
  }

  void markListPageDiscoveryCompleted() async {
    await toggleListPageDiscovery(false);
  }

  void markDetailsPageDiscoveryCompleted() async {
    await toggleDetailsPageDiscovery(false);
  }

  void markFilterPageDiscoveryCompleted() async {
    await toggleFilterPageDiscovery(false);
  }

  void markNavigationPageDiscoveryCompleted() async {
    await toggleNavigationPageDiscovery(false);
  }
}
