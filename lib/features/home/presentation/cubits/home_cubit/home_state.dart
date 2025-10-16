import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<CatImageModel> cats;
  final List<CatImageModel> filteredCats;
  final String searchQuery;

  const HomeSuccess({
    required this.cats,
    required this.filteredCats,
    required this.searchQuery,
  });
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});
}
