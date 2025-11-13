import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_drawer_bloc_state.dart';

class NavigationDrawerCubit extends Cubit<NavigationDrawerState> {
  NavigationDrawerCubit() : super(NavigationDrawerState.initial());

  void updateDogBreedName(String name) {
    emit(state.copyWith(dogBreedName: name));
  }

  void updateLikes(int likes) {
    emit(state.copyWith(likes: likes));
  }

  void incrementLikes() {
    emit(state.copyWith(likes: state.likes + 1));
  }

  void decrementLikes() {
    emit(state.copyWith(likes: state.likes - 1));
  }
}
