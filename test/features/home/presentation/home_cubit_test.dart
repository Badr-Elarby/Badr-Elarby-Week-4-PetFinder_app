import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/features/home/data/repositories/home_repository.dart';
import 'package:petfinder_app/features/home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:petfinder_app/features/home/presentation/cubits/home_cubit/home_state.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/home/data/models/cat_breed_model.dart';

// Mock classes
class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late HomeCubit cubit;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    cubit = HomeCubit(homeRepository: mockRepository);
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

  final mockCats = [mockPersianCat, mockSiameseCat];

  group('HomeCubit', () {
    group('getCats', () {
      blocTest<HomeCubit, HomeState>(
        'should emit [HomeLoading, HomeSuccess] when successful',
        build: () {
          when(
            () => mockRepository.getCats(page: 0, limit: 10),
          ).thenAnswer((_) async => mockCats);
          return cubit;
        },
        act: (cubit) => cubit.getCats(),
        expect: () => [
          HomeLoading(),
          HomeSuccess(
            cats: mockCats,
            filteredCats: mockCats,
            searchQuery: '',
            isLoadingMore: false,
            hasMorePages: true,
            currentPage: 0,
          ),
        ],
        verify: (_) =>
            verify(() => mockRepository.getCats(page: 0, limit: 10)).called(1),
      );

      blocTest<HomeCubit, HomeState>(
        'should emit [HomeLoading, HomeError] when repository throws exception',
        build: () {
          when(
            () => mockRepository.getCats(page: 0, limit: 10),
          ).thenThrow(Exception('API Error'));
          return cubit;
        },
        act: (cubit) => cubit.getCats(),
        expect: () => [
          HomeLoading(),
          HomeError(message: 'Exception: API Error'),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'should provide consistent state structure after getCats',
        build: () {
          when(
            () => mockRepository.getCats(page: 0, limit: 10),
          ).thenAnswer((_) async => mockCats);
          return cubit;
        },
        act: (cubit) => cubit.getCats(),
        verify: (_) {
          // Verify that repository was called with expected parameters
          verify(() => mockRepository.getCats(page: 0, limit: 10)).called(1);
        },
      );
    });

    group('loadMoreCats', () {
      // Setup initial data state
      final initialState = HomeSuccess(
        cats: [mockPersianCat],
        filteredCats: [mockPersianCat],
        searchQuery: '',
        isLoadingMore: false,
        hasMorePages: true,
        currentPage: 0,
      );

      final mockNewCats = [mockSiameseCat];
      final expectedCombinedCats = [mockPersianCat, mockSiameseCat];

      blocTest<HomeCubit, HomeState>(
        'should emit loading state then success with appended cats',
        build: () {
          // Mock initial state
          cubit.emit(initialState);
          // Mock load more call
          when(
            () => mockRepository.getCats(page: 1, limit: 10),
          ).thenAnswer((_) async => mockNewCats);
          return cubit;
        },
        act: (cubit) => cubit.loadMoreCats(),
        expect: () => [
          // First emit loading state with isLoadingMore=true
          HomeSuccess(
            cats: [mockPersianCat],
            filteredCats: [mockPersianCat],
            searchQuery: '',
            isLoadingMore: true,
            hasMorePages: true,
            currentPage: 0,
          ),
          // Then emit success with appended data
          HomeSuccess(
            cats: expectedCombinedCats,
            filteredCats: expectedCombinedCats,
            searchQuery: '',
            isLoadingMore: false,
            hasMorePages: false,
            currentPage: 1,
          ),
        ],
        verify: (_) =>
            verify(() => mockRepository.getCats(page: 1, limit: 10)).called(1),
      );

      blocTest<HomeCubit, HomeState>(
        'should set hasMorePages to false when fewer cats than limit are returned',
        build: () {
          cubit.emit(initialState);
          // Return only 1 cat but limit is 10, indicating end of data
          when(() => mockRepository.getCats(page: 1, limit: 10)).thenAnswer(
            (_) async => [mockSiameseCat],
          ); // Only 1 cat instead of up to 10
          return cubit;
        },
        act: (cubit) => cubit.loadMoreCats(),
        expect: () => [
          HomeSuccess(
            cats: [mockPersianCat],
            filteredCats: [mockPersianCat],
            searchQuery: '',
            isLoadingMore: true,
            hasMorePages: true,
            currentPage: 0,
          ),
          HomeSuccess(
            cats: expectedCombinedCats,
            filteredCats: expectedCombinedCats,
            searchQuery: '',
            isLoadingMore: false,
            hasMorePages: false, // Should be false now
            currentPage: 1,
          ),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'should not emit anything when already loading or no more pages',
        build: () => cubit,
        act: (cubit) => cubit.loadMoreCats(),
        expect: () => [], // No emissions expected
        verify: (_) => verifyNever(() => mockRepository.getCats()),
      );

      blocTest<HomeCubit, HomeState>(
        'should handle errors during load more by resetting loading state',
        build: () {
          cubit.emit(initialState);
          when(
            () => mockRepository.getCats(page: 1, limit: 10),
          ).thenThrow(Exception('Load More Error'));
          return cubit;
        },
        act: (cubit) => cubit.loadMoreCats(),
        expect: () => [
          // Loading state
          HomeSuccess(
            cats: [mockPersianCat],
            filteredCats: [mockPersianCat],
            searchQuery: '',
            isLoadingMore: true,
            hasMorePages: true,
            currentPage: 0,
          ),
          // Error reset - keep existing data but reset loading
          HomeSuccess(
            cats: [mockPersianCat],
            filteredCats: [mockPersianCat],
            searchQuery: '',
            isLoadingMore: false,
            hasMorePages: true,
            currentPage: 0, // Page decremented back on error
          ),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'should properly search through paginated results',
        build: () {
          // Setup initial state with multiple cats
          cubit.emit(
            HomeSuccess(
              cats: expectedCombinedCats,
              filteredCats: expectedCombinedCats,
              searchQuery: '',
              isLoadingMore: false,
              hasMorePages: true,
              currentPage: 1,
            ),
          );

          when(
            () => mockRepository.searchCats(expectedCombinedCats, 'persian'),
          ).thenReturn([mockPersianCat]);

          return cubit;
        },
        act: (cubit) => cubit.searchCats('persian'),
        expect: () => [
          HomeSuccess(
            cats: expectedCombinedCats, // All cats preserved
            filteredCats: [mockPersianCat], // Only Persian filtered
            searchQuery: 'persian',
            isLoadingMore: false,
            hasMorePages: true,
            currentPage: 1,
          ),
        ],
        verify: (_) {
          verify(
            () => mockRepository.searchCats(expectedCombinedCats, 'persian'),
          ).called(1);
        },
      );

      blocTest<HomeCubit, HomeState>(
        'should clear search and show all cats',
        build: () {
          // Setup state with active search
          cubit.emit(
            HomeSuccess(
              cats: expectedCombinedCats,
              filteredCats: [mockPersianCat],
              searchQuery: 'persian',
              isLoadingMore: false,
              hasMorePages: true,
              currentPage: 1,
            ),
          );

          return cubit;
        },
        act: (cubit) => cubit.clearSearch(),
        expect: () => [
          HomeSuccess(
            cats: expectedCombinedCats,
            filteredCats: expectedCombinedCats, // Back to all cats
            searchQuery: '', // Search cleared
            isLoadingMore: false,
            hasMorePages: true,
            currentPage: 1,
          ),
        ],
      );
    });
  });
}
