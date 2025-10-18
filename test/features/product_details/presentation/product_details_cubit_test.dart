import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/features/ProductDetails/data/repositories/product_details_repository.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/cubit/product_details_cubit.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/cubit/product_details_state.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/home/data/models/cat_breed_model.dart';

// Mock classes
class MockProductDetailsRepository extends Mock
    implements ProductDetailsRepository {}

void main() {
  late ProductDetailsCubit cubit;
  late MockProductDetailsRepository mockRepository;

  setUp(() {
    mockRepository = MockProductDetailsRepository();
    cubit = ProductDetailsCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  // Mock cat data
  final mockCat = CatImageModel(
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
        description:
            "The Persian cat is a long-haired breed of cat characterized by its round face and short muzzle.",
        temperament: "Affectionate, Gentle, Quiet",
      ),
    ],
  );

  group('ProductDetailsCubit', () {
    group('getCatDetails', () {
      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should emit [ProductDetailsLoading, ProductDetailsSuccess] when successful',
        build: () {
          when(
            () => mockRepository.getCatDetails('cat1'),
          ).thenAnswer((_) async => mockCat);
          return cubit;
        },
        act: (cubit) => cubit.getCatDetails('cat1'),
        expect: () => [
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsSuccess>().having(
            (state) => state.cat.id,
            'cat.id',
            'cat1',
          ),
        ],
        verify: (_) =>
            verify(() => mockRepository.getCatDetails('cat1')).called(1),
      );

      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should emit [ProductDetailsLoading, ProductDetailsError] when repository throws exception',
        build: () {
          when(
            () => mockRepository.getCatDetails('cat1'),
          ).thenThrow(Exception('API Error'));
          return cubit;
        },
        act: (cubit) => cubit.getCatDetails('cat1'),
        expect: () => [
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsError>().having(
            (state) => state.message,
            'message',
            'Exception: API Error',
          ),
        ],
      );

      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should not reload when same cat is already loaded',
        build: () {
          when(
            () => mockRepository.getCatDetails('cat1'),
          ).thenAnswer((_) async => mockCat);
          return cubit;
        },
        seed: () => ProductDetailsSuccess(cat: mockCat),
        act: (cubit) async {
          // First load the cat to set up the state properly
          await cubit.getCatDetails('cat1');
          // Then try to load the same cat again - should not reload
          await cubit.getCatDetails('cat1');
        },
        expect: () => [
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsSuccess>().having(
            (state) => state.cat.id,
            'cat.id',
            'cat1',
          ),
          // No additional states should be emitted for the second call
        ],
        verify: (_) =>
            verify(() => mockRepository.getCatDetails('cat1')).called(1),
      );

      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should reload when different cat is requested',
        build: () {
          final differentCat = CatImageModel(
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
                description:
                    "The Siamese cat is known for its distinctive color points.",
                temperament: "Active, Social, Intelligent",
              ),
            ],
          );

          when(
            () => mockRepository.getCatDetails('cat2'),
          ).thenAnswer((_) async => differentCat);
          return cubit;
        },
        seed: () => ProductDetailsSuccess(cat: mockCat),
        act: (cubit) => cubit.getCatDetails('cat2'),
        expect: () => [
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsSuccess>().having(
            (state) => state.cat.id,
            'cat.id',
            'cat2',
          ),
        ],
        verify: (_) =>
            verify(() => mockRepository.getCatDetails('cat2')).called(1),
      );

      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should handle network timeout errors',
        build: () {
          when(
            () => mockRepository.getCatDetails('cat1'),
          ).thenThrow(Exception('Connection timeout'));
          return cubit;
        },
        act: (cubit) => cubit.getCatDetails('cat1'),
        expect: () => [
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsError>().having(
            (state) => state.message,
            'message',
            'Exception: Connection timeout',
          ),
        ],
      );

      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should handle server errors',
        build: () {
          when(
            () => mockRepository.getCatDetails('cat1'),
          ).thenThrow(Exception('Server error: 500'));
          return cubit;
        },
        act: (cubit) => cubit.getCatDetails('cat1'),
        expect: () => [
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsError>().having(
            (state) => state.message,
            'message',
            'Exception: Server error: 500',
          ),
        ],
      );

      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should track current cat ID correctly',
        build: () {
          when(
            () => mockRepository.getCatDetails('cat1'),
          ).thenAnswer((_) async => mockCat);
          return cubit;
        },
        act: (cubit) => cubit.getCatDetails('cat1'),
        verify: (_) {
          expect(cubit.currentCatId, 'cat1');
        },
      );
    });

    group('clearState', () {
      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should emit ProductDetailsInitial and clear current cat ID',
        build: () {
          when(
            () => mockRepository.getCatDetails('cat1'),
          ).thenAnswer((_) async => mockCat);
          return cubit;
        },
        seed: () => ProductDetailsSuccess(cat: mockCat),
        act: (cubit) => cubit.clearState(),
        expect: () => [isA<ProductDetailsInitial>()],
        verify: (_) {
          expect(cubit.currentCatId, isNull);
        },
      );

      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should work from any state',
        build: () => cubit,
        seed: () => ProductDetailsError(message: 'Some error'),
        act: (cubit) => cubit.clearState(),
        expect: () => [isA<ProductDetailsInitial>()],
      );
    });

    group('state transitions', () {
      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should handle multiple consecutive calls correctly',
        build: () {
          final cat1 = CatImageModel(
            id: "cat1",
            url: "https://cdn2.thecatapi.com/images/cat1.jpg",
            width: 800,
            height: 600,
            breeds: [mockCat.breeds.first],
          );
          final cat2 = CatImageModel(
            id: "cat2",
            url: "https://cdn2.thecatapi.com/images/cat2.jpg",
            width: 600,
            height: 400,
            breeds: [mockCat.breeds.first],
          );
          final cat3 = CatImageModel(
            id: "cat3",
            url: "https://cdn2.thecatapi.com/images/cat3.jpg",
            width: 700,
            height: 500,
            breeds: [mockCat.breeds.first],
          );

          when(
            () => mockRepository.getCatDetails('cat1'),
          ).thenAnswer((_) async => cat1);
          when(
            () => mockRepository.getCatDetails('cat2'),
          ).thenAnswer((_) async => cat2);
          when(
            () => mockRepository.getCatDetails('cat3'),
          ).thenAnswer((_) async => cat3);
          return cubit;
        },
        act: (cubit) async {
          await cubit.getCatDetails('cat1');
          await cubit.getCatDetails('cat2');
          await cubit.getCatDetails('cat3');
        },
        expect: () => [
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsSuccess>().having(
            (state) => state.cat.id,
            'cat.id',
            'cat1',
          ),
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsSuccess>().having(
            (state) => state.cat.id,
            'cat.id',
            'cat2',
          ),
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsSuccess>().having(
            (state) => state.cat.id,
            'cat.id',
            'cat3',
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getCatDetails('cat1')).called(1);
          verify(() => mockRepository.getCatDetails('cat2')).called(1);
          verify(() => mockRepository.getCatDetails('cat3')).called(1);
        },
      );

      blocTest<ProductDetailsCubit, ProductDetailsState>(
        'should handle error recovery correctly',
        build: () {
          when(
            () => mockRepository.getCatDetails('cat1'),
          ).thenThrow(Exception('First error'));

          when(
            () => mockRepository.getCatDetails('cat2'),
          ).thenAnswer((_) async => mockCat);

          return cubit;
        },
        act: (cubit) async {
          await cubit.getCatDetails('cat1');
          await cubit.getCatDetails('cat2');
        },
        expect: () => [
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsError>().having(
            (state) => state.message,
            'message',
            'Exception: First error',
          ),
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsSuccess>().having(
            (state) => state.cat.id,
            'cat.id',
            'cat1',
          ),
        ],
      );
    });
  });
}
