import 'package:flutter_bloc/flutter_bloc.dart';
import 'breed_info_bloc_state.dart';
import '../models/dog.dart';
import '../repositories/dogs_data_repository.dart';

class BreedInfoCubit extends Cubit<BreedInfoState> {
  final DogsDataRepository _repository = DogsDataRepository();

  BreedInfoCubit() : super(BreedInfoState.initial());

  Future<void> loadExtendedInfo(Dog dog, String Function(String) errorCallback) async {
    emit(state.copyWith(loading: true, errorMessage: ''));

    try {
      final extendedInfo = await _repository.getExtendedInfo(dog.id);

      if (extendedInfo == null) {
        emit(state.copyWith(
          loading: false,
          errorMessage: errorCallback('breedInfoLoadError'),
        ));
      } else {
        emit(state.copyWith(
          extendedInfo: extendedInfo,
          loading: false,
          errorMessage: '',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        errorMessage: errorCallback(e.toString()),
      ));
    }
  }

  void reloadData(Dog dog, String Function(String) errorCallback) {
    emit(BreedInfoState.initial());
    loadExtendedInfo(dog, errorCallback);
  }
}
