import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/core/services/local_storage_service.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final LocalStorageService _localStorageService;
  final String _favoritesKey = 'favorites';

  FavoritesCubit()
    : _localStorageService = GetIt.instance<LocalStorageService>(),
      super(FavoritesInitial());

  Future<void> getFavorites() async {
    emit(FavoritesLoading());
    try {
      final jsonString = _localStorageService.getString(_favoritesKey);
      if (jsonString == null) {
        emit(const FavoritesSuccess(favorites: []));
        return;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final favorites = jsonList
          .map((json) => CatImageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(FavoritesSuccess(favorites: favorites));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  Future<void> addToFavorites(CatImageModel cat) async {
    try {
      final currentState = state;
      List<CatImageModel> currentFavorites = [];

      if (currentState is FavoritesSuccess) {
        currentFavorites = List.from(currentState.favorites);
      } else if (currentState is FavoritesInitial) {
        // Load favorites if initial
        await getFavorites();
        if (state is FavoritesSuccess) {
          currentFavorites = List.from((state as FavoritesSuccess).favorites);
        }
      }

      // Check if already exists
      if (currentFavorites.any((favorite) => favorite.id == cat.id)) {
        return; // Already favorite
      }

      currentFavorites.add(cat);

      final jsonList = currentFavorites.map((cat) => cat.toJson()).toList();
      await _localStorageService.setString(
        _favoritesKey,
        json.encode(jsonList),
      );

      emit(FavoritesSuccess(favorites: currentFavorites));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  Future<void> removeFromFavorites(String catId) async {
    try {
      final currentState = state;
      if (currentState is! FavoritesSuccess) {
        return;
      }

      final currentFavorites = List<CatImageModel>.from(currentState.favorites);
      currentFavorites.removeWhere((cat) => cat.id == catId);

      final jsonList = currentFavorites.map((cat) => cat.toJson()).toList();
      await _localStorageService.setString(
        _favoritesKey,
        json.encode(jsonList),
      );

      emit(FavoritesSuccess(favorites: currentFavorites));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  bool isFavorite(String catId) {
    final currentState = state;
    if (currentState is FavoritesSuccess) {
      return currentState.favorites.any((cat) => cat.id == catId);
    }
    return false;
  }

  Future<void> clearFavorites() async {
    try {
      await _localStorageService.remove(_favoritesKey);
      emit(const FavoritesSuccess(favorites: []));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }
}
