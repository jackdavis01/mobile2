import '../models/top_dog.dart';
import '../models/dog.dart';

enum TopDogsErrorCode {
  offlineCache,
  loadFailed,
  noData,
}

class TopDogsState {
  final bool loading;
  final List<TopDog> topDogs;
  final List<Dog> allDogs;
  final TopDogsErrorCode? errorCode;
  final String? errorDetails;

  TopDogsState({
    required this.loading,
    required this.topDogs,
    required this.allDogs,
    this.errorCode,
    this.errorDetails,
  });

  factory TopDogsState.initial() => TopDogsState(
        loading: true,
        topDogs: [],
        allDogs: [],
        errorCode: null,
        errorDetails: null,
      );

  TopDogsState copyWith({
    bool? loading,
    List<TopDog>? topDogs,
    List<Dog>? allDogs,
    TopDogsErrorCode? errorCode,
    String? errorDetails,
  }) {
    return TopDogsState(
      loading: loading ?? this.loading,
      topDogs: topDogs ?? this.topDogs,
      allDogs: allDogs ?? this.allDogs,
      errorCode: errorCode ?? this.errorCode,
      errorDetails: errorDetails ?? this.errorDetails,
    );
  }
}
