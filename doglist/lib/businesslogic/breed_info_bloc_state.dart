import '../models/dog_extended_info.dart';

class BreedInfoState {
  final DogExtendedInfo? extendedInfo;
  final bool loading;
  final String errorMessage;

  BreedInfoState({
    required this.extendedInfo,
    required this.loading,
    required this.errorMessage,
  });

  factory BreedInfoState.initial() => BreedInfoState(
    extendedInfo: null,
    loading: true,
    errorMessage: '',
  );

  BreedInfoState copyWith({
    DogExtendedInfo? extendedInfo,
    bool? loading,
    String? errorMessage,
  }) {
    return BreedInfoState(
      extendedInfo: extendedInfo ?? this.extendedInfo,
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
