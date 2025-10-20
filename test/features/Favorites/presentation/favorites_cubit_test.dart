import 'dart:convert';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/core/services/local_storage_service.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_cubit.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_state.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/home/data/models/cat_breed_model.dart';

// Mock classes
class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late FavoritesCubit cubit;
  late MockLocalStorageService mockLocalStorageService;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    cubit = FavoritesCubit(localStorageService: mockLocalStorageService);
  });

  tearDown(() {
    cubit.close();
  });

  // Mock cat data
  final mockPersianCat = CatImageModel(
    id: "cat1",
    url: "https://cdn2.thecatapi.com/images/cat1.jpg",
    width: 800,
    height: 600,
    breeds: [
      CatBreedModel(
        id: "pers",
        name: "Persian",
        origin: "Iran",
        lifeSpan: "10 - 15",
        weight: "3 - 7",
      ),
    ],
  );

  final mockSiameseCat = CatImageModel(
    id: "cat2",
    url: "https://cdn2.thecatapi.com/images/cat2.jpg",
    width: 600,
    height: 400,
    breeds: [
      CatBreedModel(
        id: "siamese",
        name: "Siamese",
        origin: "Thailand",
        lifeSpan: "12 - 15",
        weight: "2 - 6",
      ),
    ],
  );

  const favoritesKey = 'favorites';

  group('FavoritesCubit', () {
    group('initial state', () {
      test('should start with FavoritesInitial state', () {
        expect(cubit.state, isA<FavoritesInitial>());
      });
    });

    group('getFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should emit [FavoritesLoading, FavoritesSuccess] when successful with existing data',
        build: () {
          final jsonData = json.encode([
            mockPersianCat.toJson(),
            mockSiameseCat.toJson(),
          ]);
          when(
            () => mockLocalStorageService.getString(favoritesKey),
          ).thenReturn(jsonData);
          return cubit;
        },
        act: (cubit) => cubit.getFavorites(),
        expect: () => [
          FavoritesLoading(),
          FavoritesSuccess(favorites: [mockPersianCat, mockSiameseCat]),
        ],
        verify: (_) => verify(
          () => mockLocalStorageService.getString(favoritesKey),
        ).called(1),
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit [FavoritesLoading, FavoritesSuccess] with empty list when no stored data',
        build: () {
          when(
            () => mockLocalStorageService.getString(favoritesKey),
          ).thenReturn(null);
          return cubit;
        },
        act: (cubit) => cubit.getFavorites(),
        expect: () => [FavoritesLoading(), FavoritesSuccess(favorites: [])],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit [FavoritesLoading, FavoritesError] when JSON parsing fails',
        build: () {
          when(
            () => mockLocalStorageService.getString(favoritesKey),
          ).thenReturn('invalid json data');
          return cubit;
        },
        act: (cubit) => cubit.getFavorites(),
        expect: () => [
          FavoritesLoading(),
          isA<FavoritesError>(), // Use matcher instead of exact error message
        ],
        verify: (_) {
          final state = cubit.state as FavoritesError;
          expect(state.message, contains('FormatException'));
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should handle storage exceptions gracefully',
        build: () {
          when(
            () => mockLocalStorageService.getString(favoritesKey),
          ).thenThrow(Exception('Storage access denied'));
          return cubit;
        },
        act: (cubit) => cubit.getFavorites(),
        expect: () => [
          FavoritesLoading(),
          FavoritesError(message: 'Exception: Storage access denied'),
        ],
      );
    });

    group('addToFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should add new cat to favorites and save to storage',
        build: () {
          // Start with existing favorites to avoid initial loading sequence
          cubit.emit(FavoritesSuccess(favorites: [mockPersianCat]));
          when(
            () => mockLocalStorageService.setString(any(), any()),
          ).thenAnswer((_) async => true);
          return cubit;
        },
        act: (cubit) => cubit.addToFavorites(mockSiameseCat),
        expect: () => [
          FavoritesSuccess(favorites: [mockPersianCat, mockSiameseCat]),
        ],
        verify: (_) {
          final expectedJson = json.encode([
            mockPersianCat.toJson(),
            mockSiameseCat.toJson(),
          ]);
          verify(
            () => mockLocalStorageService.setString(favoritesKey, expectedJson),
          ).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should prevent adding duplicate cats',
        build: () {
          cubit.emit(FavoritesSuccess(favorites: [mockPersianCat]));
          return cubit;
        },
        act: (cubit) =>
            cubit.addToFavorites(mockPersianCat), // Try to add existing cat
        expect: () => [], // No state change
        verify: (_) =>
            verifyNever(() => mockLocalStorageService.setString(any(), any())),
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should load existing favorites first when starting from initial state',
        build: () {
          final jsonData = json.encode([mockPersianCat.toJson()]);
          when(
            () => mockLocalStorageService.getString(favoritesKey),
          ).thenReturn(jsonData);
          when(
            () => mockLocalStorageService.setString(any(), any()),
          ).thenAnswer((_) async => true);
          return cubit;
        },
        act: (cubit) => cubit.addToFavorites(mockSiameseCat),
        expect: () => [
          FavoritesLoading(),
          FavoritesSuccess(favorites: [mockPersianCat]),
          FavoritesSuccess(favorites: [mockPersianCat, mockSiameseCat]),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit FavoritesError when storage save fails',
        build: () {
          cubit.emit(FavoritesSuccess(favorites: [mockPersianCat]));
          when(
            () => mockLocalStorageService.setString(any(), any()),
          ).thenThrow(Exception('Storage write failed'));
          return cubit;
        },
        act: (cubit) => cubit.addToFavorites(mockSiameseCat),
        expect: () => [
          FavoritesError(message: 'Exception: Storage write failed'),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should load existing favorites when in initial state but storage fails',
        build: () {
          when(
            () => mockLocalStorageService.getString(favoritesKey),
          ).thenThrow(Exception('Storage read failed during load'));
          when(
            () => mockLocalStorageService.setString(any(), any()),
          ).thenThrow(Exception("Null is not a subtype of Future<bool>"));
          return cubit;
        },
        act: (cubit) => cubit.addToFavorites(mockPersianCat),
        expect: () => [
          FavoritesLoading(),
          FavoritesError(message: 'Exception: Storage read failed during load'),
          FavoritesError(
            message: 'Exception: Null is not a subtype of Future<bool>',
          ),
        ],
        verify: (_) => verify(
          () => mockLocalStorageService.getString(favoritesKey),
        ).called(1),
      );
    });

    group('removeFromFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should remove cat from favorites and update storage',
        build: () {
          cubit.emit(
            FavoritesSuccess(favorites: [mockPersianCat, mockSiameseCat]),
          );
          when(
            () => mockLocalStorageService.setString(any(), any()),
          ).thenAnswer((_) async => true);
          return cubit;
        },
        act: (cubit) => cubit.removeFromFavorites('cat1'),
        expect: () => [
          FavoritesSuccess(favorites: [mockSiameseCat]),
        ],
        verify: (_) {
          final expectedJson = json.encode([mockSiameseCat.toJson()]);
          verify(
            () => mockLocalStorageService.setString(favoritesKey, expectedJson),
          ).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should not emit anything when not in success state',
        build: () {
          // Stay in initial state
          return cubit;
        },
        act: (cubit) => cubit.removeFromFavorites('cat1'),
        expect: () => [],
        verify: (_) =>
            verifyNever(() => mockLocalStorageService.setString(any(), any())),
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit FavoritesError when storage update fails during removal',
        build: () {
          cubit.emit(
            FavoritesSuccess(favorites: [mockPersianCat, mockSiameseCat]),
          );
          when(
            () => mockLocalStorageService.setString(any(), any()),
          ).thenThrow(Exception('Storage update failed'));
          return cubit;
        },
        act: (cubit) => cubit.removeFromFavorites('cat1'),
        expect: () => [
          FavoritesError(message: 'Exception: Storage update failed'),
        ],
      );
    });

    group('clearFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'should clear all favorites and remove from storage',
        build: () {
          when(
            () => mockLocalStorageService.remove(favoritesKey),
          ).thenAnswer((_) async => true);
          return cubit;
        },
        act: (cubit) => cubit.clearFavorites(),
        expect: () => [FavoritesSuccess(favorites: [])],
        verify: (_) => verify(
          () => mockLocalStorageService.remove(favoritesKey),
        ).called(1),
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'should emit FavoritesError when storage removal fails',
        build: () {
          when(
            () => mockLocalStorageService.remove(favoritesKey),
          ).thenThrow(Exception('Storage removal failed'));
          return cubit;
        },
        act: (cubit) => cubit.clearFavorites(),
        expect: () => [
          FavoritesError(message: 'Exception: Storage removal failed'),
        ],
      );
    });

    group('isFavorite', () {
      test('should return true when cat ID exists in favorites', () {
        cubit.emit(
          FavoritesSuccess(favorites: [mockPersianCat, mockSiameseCat]),
        );
        expect(cubit.isFavorite('cat1'), true);
        expect(cubit.isFavorite('cat2'), true);
      });

      test('should return false when cat ID does not exist in favorites', () {
        cubit.emit(FavoritesSuccess(favorites: [mockPersianCat]));
        expect(cubit.isFavorite('cat3'), false);
      });

      test('should return false when not in success state', () {
        expect(cubit.isFavorite('cat1'), false);
      });
    });
  });
}
