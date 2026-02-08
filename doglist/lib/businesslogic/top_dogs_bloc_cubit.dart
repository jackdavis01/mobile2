import 'package:flutter_bloc/flutter_bloc.dart';
import 'top_dogs_bloc_state.dart';
import '../models/top_dogs_response.dart';
import '../repositories/top_dogs_repository.dart';
import '../repositories/dogs_data_repository.dart';

class TopDogsCubit extends Cubit<TopDogsState> {
  final TopDogsRepository _topDogsRepository = TopDogsRepository();
  final DogsDataRepository _dogsRepository = DogsDataRepository();
  
  TopDogsResponse? _cachedResponse;

  TopDogsCubit() : super(TopDogsState.initial()) {
    loadTopDogs();
  }

  Future<void> loadTopDogs() async {
    emit(TopDogsState.initial());

    try {
      // Load all dogs data first
      final allDogs = await _dogsRepository.getDogs();
      
      // Fetch top 3 dogs from API
      final response = await _topDogsRepository.getTop3Dogs();
      
      if (response.success && response.dogs.isNotEmpty) {
        _cachedResponse = response;
        emit(state.copyWith(
          topDogs: response.dogs,
          allDogs: allDogs,
          loading: false,
          errorCode: null,
          errorDetails: null,
        ));
      } else {
        // Offline fallback: use cached data if available
        if (_cachedResponse != null && _cachedResponse!.dogs.isNotEmpty) {
          emit(state.copyWith(
            topDogs: _cachedResponse!.dogs,
            allDogs: allDogs,
            loading: false,
            errorCode: TopDogsErrorCode.offlineCache,
            errorDetails: null,
          ));
        } else {
          emit(state.copyWith(
            loading: false,
            errorCode: TopDogsErrorCode.noData,
            errorDetails: response.error,
          ));
        }
      }
    } catch (e) {
      // Offline fallback: use cached data if available
      if (_cachedResponse != null && _cachedResponse!.dogs.isNotEmpty) {
        final allDogs = await _dogsRepository.getDogs();
        emit(state.copyWith(
          topDogs: _cachedResponse!.dogs,
          allDogs: allDogs,
          loading: false,
          errorCode: TopDogsErrorCode.offlineCache,
          errorDetails: null,
        ));
      } else {
        emit(state.copyWith(
          loading: false,
          errorCode: TopDogsErrorCode.loadFailed,
          errorDetails: e.toString(),
        ));
      }
    }
  }

  void retry() {
    loadTopDogs();
  }
}
