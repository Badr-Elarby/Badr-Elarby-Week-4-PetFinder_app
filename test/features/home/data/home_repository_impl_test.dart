import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:petfinder_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/home/data/models/cat_breed_model.dart';

// Mock classes
class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

void main() {
  late HomeRepositoryImpl repository;
  late MockHomeRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockHomeRemoteDataSource();
    repository = HomeRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('HomeRepositoryImpl', () {
    // Mock raw API response data (similar to what the data source receives)
    const mockCatsRawResponse = [
      {
        "id": "cat1",
        "url": "https://cdn2.thecatapi.com/images/cat1.jpg",
        "width": 800,
        "height": 600,
        "breeds": [
          {
            "id": "pers",
            "name": "Persian",
            "origin": "Iran",
            "life_span": "10 - 15",
            "weight": {"metric": "3 - 7"},
          },
        ],
      },
      {
        "id": "cat2",
        "url": "https://cdn2.thecatapi.com/images/cat2.jpg",
        "width": 600,
        "height": 400,
        "breeds": [
          {
            "id": "siamese",
            "name": "Siamese",
            "origin": "Thailand",
            "life_span": "12 - 15",
            "weight": {"metric": "2 - 6"},
          },
        ],
      },
    ];

    // Expected transformed domain models
    final expectedCats = [
      CatImageModel(
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
      ),
      CatImageModel(
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
      ),
    ];

    test(
      'should return list of CatImageModel when data source succeeds',
      () async {
        // Arrange
        when(
          () => mockDataSource.getCats(page: 0, limit: 10),
        ).thenAnswer((_) async => mockCatsRawResponse);

        // Act
        final result = await repository.getCats(page: 0, limit: 10);

        // Assert
        expect(result, isA<List<CatImageModel>>());
        expect(result.length, 2);
        expect(result[0].id, expectedCats[0].id);
        expect(result[0].url, expectedCats[0].url);
        expect(result[0].breeds.first.name, expectedCats[0].breeds.first.name);
        expect(
          result[0].breeds.first.origin,
          expectedCats[0].breeds.first.origin,
        );
        expect(
          result[0].breeds.first.lifeSpan,
          expectedCats[0].breeds.first.lifeSpan,
        );
        expect(
          result[1].breeds.first.weight,
          expectedCats[1].breeds.first.weight,
        );

        verify(() => mockDataSource.getCats(page: 0, limit: 10)).called(1);
      },
    );

    test('should handle page and limit parameters correctly', () async {
      // Arrange
      when(
        () => mockDataSource.getCats(page: 3, limit: 5),
      ).thenAnswer((_) async => mockCatsRawResponse);

      // Act
      await repository.getCats(page: 3, limit: 5);

      // Assert
      verify(() => mockDataSource.getCats(page: 3, limit: 5)).called(1);
    });

    test('should use default page=0 and limit=10 when not specified', () async {
      // Arrange
      when(
        () => mockDataSource.getCats(page: 0, limit: 10),
      ).thenAnswer((_) async => mockCatsRawResponse);

      // Act
      await repository.getCats();

      // Assert
      verify(() => mockDataSource.getCats(page: 0, limit: 10)).called(1);
    });

    test('should throw exception when data source throws exception', () async {
      // Arrange
      when(
        () => mockDataSource.getCats(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Network Error'));

      // Act & Assert
      expect(() => repository.getCats(), throwsException);
    });

    test(
      'should return empty list when data source returns empty list',
      () async {
        // Arrange
        when(
          () => mockDataSource.getCats(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getCats();

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<CatImageModel>>());
      },
    );

    group('searchCats', () {
      late CatImageModel cat1;
      late CatImageModel cat2;
      late List<CatImageModel> testCats;

      setUp(() {
        cat1 = expectedCats[0]; // Persian
        cat2 = expectedCats[1]; // Siamese
        testCats = [cat1, cat2];
      });

      test('should return all cats when query is empty', () {
        // Act
        final result = repository.searchCats(testCats, '');

        // Assert
        expect(result, testCats);
        expect(result.length, 2);
      });

      test('should filter cats by breed name (case insensitive)', () {
        // Act
        final result = repository.searchCats(testCats, 'persian');

        // Assert
        expect(result.length, 1);
        expect(result[0].breeds.first.name, 'Persian');
      });

      test('should filter cats by origin (case insensitive)', () {
        // Act
        final result = repository.searchCats(testCats, 'iran');

        // Assert
        expect(result.length, 1);
        expect(result[0].breeds.first.origin, 'Iran');
      });

      test('should filter cats by weight', () {
        // Act
        final result = repository.searchCats(testCats, '3 - 7');

        // Assert
        expect(result.length, 1);
        expect(result[0].breeds.first.weight, '3 - 7');
      });

      test(
        'should return multiple matches when multiple fields match the query',
        () {
          // Test with cats that have different but matching attributes
          final cat3 = expectedCats[1]; // Siamese, Thailand, 2-6
          final cat4 = CatImageModel(
            id: "cat4",
            url: "https://cdn2.thecatapi.com/images/cat4.jpg",
            width: 600,
            height: 400,
            breeds: [
              CatBreedModel(
                id: "abys",
                name: "Abyssinian",
                origin: "Egypt",
                lifeSpan: "9 - 15",
                weight: "2 - 7", // Multiple of 7 to match
              ),
            ],
          );

          final mixedCats = [cat1, cat4]; // Persian (3-7), Abyssinian (2-7)

          // Act
          final result = repository.searchCats(mixedCats, '7');

          // Assert
          expect(result.length, 2); // Both cats should match
        },
      );

      test('should return empty list when no cats match the query', () {
        // Act
        final result = repository.searchCats(testCats, 'wolfhound');

        // Assert
        expect(result, isEmpty);
      });

      test('should handle cats with empty breeds gracefully', () {
        // Arrange - Create cat with no breeds
        final catWithoutBreeds = CatImageModel(
          id: "cat3",
          url: "https://cdn2.thecatapi.com/images/cat3.jpg",
          width: 400,
          height: 300,
          breeds: [], // Empty breeds
        );

        final catsWithEmptyBreeds = [catWithoutBreeds];

        // Act
        final result = repository.searchCats(catsWithEmptyBreeds, 'persian');

        // Assert
        expect(result, isEmpty); // No breeds to match against
      });

      test('should handle null values in breed fields gracefully', () {
        // Arrange - Create cat with null breed fields
        final catWithNullBreeds = CatImageModel(
          id: "cat3",
          url: "https://cdn2.thecatapi.com/images/cat3.jpg",
          width: 400,
          height: 300,
          breeds: [
            CatBreedModel(
              id: "unknown",
              name: "Unknown",
              origin: null, // Null origin
              lifeSpan: null, // Null life_span
              weight: null, // Null weight
            ),
          ],
        );

        final catsWithNull = [catWithNullBreeds];

        // Act
        final result = repository.searchCats(catsWithNull, 'persian');

        // Assert
        expect(result, isEmpty); // No matching fields
      });
    });
  });
}
