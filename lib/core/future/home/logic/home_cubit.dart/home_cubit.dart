import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(const HomeInitial());

  int selectedIndex = 0;

  void changeState(int newIndex) {
    if (selectedIndex == newIndex) return;
    selectedIndex = newIndex;
    emit(HomeChanged(newIndex));
  }
}
