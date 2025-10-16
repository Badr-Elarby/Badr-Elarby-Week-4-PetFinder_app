import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petfinder_app/features/home/data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;

  HomeCubit({required this.homeRepository}) : super(HomeInitial());

  Future<void> getCats() async {
    emit(HomeLoading());
    try {
      // Get processed data from Repository
      final cats = await homeRepository.getCats();
      emit(HomeSuccess(cats: cats, filteredCats: cats, searchQuery: ''));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  void searchCats(String query) {
    final currentState = state;
    if (currentState is HomeSuccess) {
      // Use Repository for data filtering instead of doing it in Cubit
      final filteredCats = homeRepository.searchCats(currentState.cats, query);

      emit(
        HomeSuccess(
          cats: currentState.cats,
          filteredCats: filteredCats,
          searchQuery: query,
        ),
      );
    }
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is HomeSuccess) {
      emit(
        HomeSuccess(
          cats: currentState.cats,
          filteredCats: currentState.cats,
          searchQuery: '',
        ),
      );
    }
  }
}
