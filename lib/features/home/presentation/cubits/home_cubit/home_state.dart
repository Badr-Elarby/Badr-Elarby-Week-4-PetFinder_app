import 'package:equatable/equatable.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeSuccess extends HomeState {
  final List<CatImageModel> cats;
  final List<CatImageModel> filteredCats;
  final String searchQuery;
  final bool isLoadingMore;
  final bool hasMorePages;
  final int currentPage;

  const HomeSuccess({
    required this.cats,
    required this.filteredCats,
    required this.searchQuery,
    this.isLoadingMore = false,
    this.hasMorePages = true,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [
    cats,
    filteredCats,
    searchQuery,
    isLoadingMore,
    hasMorePages,
    currentPage,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
