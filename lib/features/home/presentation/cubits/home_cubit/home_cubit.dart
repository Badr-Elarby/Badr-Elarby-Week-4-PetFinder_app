import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petfinder_app/features/home/data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;
  int _currentPage = 0;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  HomeCubit({required this.homeRepository}) : super(HomeInitial());

  Future<void> getCats() async {
    emit(HomeLoading());
    _currentPage = 0;
    _hasMorePages = true;
    _isLoadingMore = false;

    try {
      // Get first page of processed data from Repository
      final cats = await homeRepository.getCats(page: _currentPage, limit: 10);
      emit(
        HomeSuccess(
          cats: cats,
          filteredCats: cats,
          searchQuery: '',
          isLoadingMore: false,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> loadMoreCats() async {
    final currentState = state;
    if (currentState is! HomeSuccess || _isLoadingMore || !_hasMorePages) {
      return;
    }

    _isLoadingMore = true;

    // Emit loading state for more items
    emit(
      HomeSuccess(
        cats: currentState.cats,
        filteredCats: currentState.filteredCats,
        searchQuery: currentState.searchQuery,
        isLoadingMore: true,
        hasMorePages: _hasMorePages,
        currentPage: _currentPage,
      ),
    );

    try {
      // Increment page for next load
      _currentPage++;
      final newCats = await homeRepository.getCats(
        page: _currentPage,
        limit: 10,
      );

      // Check if we got fewer cats than requested (indicating no more pages)
      if (newCats.length < 10) {
        _hasMorePages = false;
      }

      final allCats = [...currentState.cats, ...newCats];

      emit(
        HomeSuccess(
          cats: allCats,
          filteredCats: currentState.searchQuery.isEmpty
              ? allCats
              : homeRepository.searchCats(allCats, currentState.searchQuery),
          searchQuery: currentState.searchQuery,
          isLoadingMore: false,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage,
        ),
      );
    } catch (e) {
      // Reset loading state on error but don't change the data
      emit(
        HomeSuccess(
          cats: currentState.cats,
          filteredCats: currentState.filteredCats,
          searchQuery: currentState.searchQuery,
          isLoadingMore: false,
          hasMorePages: _hasMorePages,
          currentPage: _currentPage - 1, // Decrement page back
        ),
      );
    } finally {
      _isLoadingMore = false;
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
          isLoadingMore: currentState.isLoadingMore ?? false,
          hasMorePages: currentState.hasMorePages ?? true,
          currentPage: currentState.currentPage ?? 0,
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
          isLoadingMore: currentState.isLoadingMore ?? false,
          hasMorePages: currentState.hasMorePages ?? true,
          currentPage: currentState.currentPage ?? 0,
        ),
      );
    }
  }
}
