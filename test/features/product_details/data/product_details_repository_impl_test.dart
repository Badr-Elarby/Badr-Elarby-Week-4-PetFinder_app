import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/features/ProductDetails/data/datasources/product_details_datasource.dart';
import 'package:petfinder_app/features/ProductDetails/data/repositories/product_details_repository_impl.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/home/data/models/cat_breed_model.dart';

// Mock classes
class MockProductDetailsDataSource extends Mock
    implements ProductDetailsDataSource {}

void main() {
  late ProductDetailsRepositoryImpl repository;
  late MockProductDetailsDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockProductDetailsDataSource();
    repository = ProductDetailsRepositoryImpl(dataSource: mockDataSource);
  });

  group('ProductDetailsRepositoryImpl', () {
    // Mock raw API response data
    const mockCatDetailJson = {
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
          "description":
              "The Persian cat is a long-haired breed of cat characterized by its round face and short muzzle.",
          "temperament": "Affectionate, Gentle, Quiet",
        },
      ],
    };

    // Expected transformed domain model
    final expectedCat = CatImageModel(
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

    test('should return CatImageModel when data source succeeds', () async {
      // Arrange
      when(
        () => mockDataSource.getCatDetails('cat1'),
      ).thenAnswer((_) async => CatImageModel.fromJson(mockCatDetailJson));

      // Act
      final result = await repository.getCatDetails('cat1');

      // Assert
      expect(result, isA<CatImageModel>());
      expect(result.id, expectedCat.id);
      expect(result.url, expectedCat.url);
      expect(result.width, expectedCat.width);
      expect(result.height, expectedCat.height);
      expect(result.breeds.length, 1);
      expect(result.breeds.first.id, expectedCat.breeds.first.id);
      expect(result.breeds.first.name, expectedCat.breeds.first.name);
      expect(result.breeds.first.origin, expectedCat.breeds.first.origin);
      expect(result.breeds.first.lifeSpan, expectedCat.breeds.first.lifeSpan);
      expect(result.breeds.first.weight, expectedCat.breeds.first.weight);
      expect(
        result.breeds.first.description,
        expectedCat.breeds.first.description,
      );
      expect(
        result.breeds.first.temperament,
        expectedCat.breeds.first.temperament,
      );

      verify(() => mockDataSource.getCatDetails('cat1')).called(1);
    });

    test('should handle different cat IDs correctly', () async {
      // Arrange
      when(
        () => mockDataSource.getCatDetails('cat2'),
      ).thenAnswer((_) async => CatImageModel.fromJson(mockCatDetailJson));

      // Act
      await repository.getCatDetails('cat2');

      // Assert
      verify(() => mockDataSource.getCatDetails('cat2')).called(1);
    });

    test('should throw exception when data source throws exception', () async {
      // Arrange
      when(
        () => mockDataSource.getCatDetails(any()),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => repository.getCatDetails('cat1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to get cat details:'),
          ),
        ),
      );
    });

    test('should handle cats with empty breeds array', () async {
      // Arrange
      const mockCatWithoutBreeds = {
        "id": "cat1",
        "url": "https://cdn2.thecatapi.com/images/cat1.jpg",
        "width": 800,
        "height": 600,
        "breeds": [],
      };

      when(
        () => mockDataSource.getCatDetails('cat1'),
      ).thenAnswer((_) async => CatImageModel.fromJson(mockCatWithoutBreeds));

      // Act
      final result = await repository.getCatDetails('cat1');

      // Assert
      expect(result, isA<CatImageModel>());
      expect(result.id, 'cat1');
      expect(result.breeds, isEmpty);
    });

    test('should handle cats with null breed fields gracefully', () async {
      // Arrange
      const mockCatWithNullFields = {
        "id": "cat1",
        "url": "https://cdn2.thecatapi.com/images/cat1.jpg",
        "width": 800,
        "height": 600,
        "breeds": [
          {
            "id": "unknown",
            "name": "Unknown",
            "origin": null,
            "life_span": null,
            "weight": null,
            "description": null,
            "temperament": null,
          },
        ],
      };

      when(
        () => mockDataSource.getCatDetails('cat1'),
      ).thenAnswer((_) async => CatImageModel.fromJson(mockCatWithNullFields));

      // Act
      final result = await repository.getCatDetails('cat1');

      // Assert
      expect(result, isA<CatImageModel>());
      expect(result.breeds.length, 1);
      expect(result.breeds.first.name, 'Unknown');
      expect(result.breeds.first.origin, isNull);
      expect(result.breeds.first.lifeSpan, isNull);
      expect(result.breeds.first.weight, isNull);
      expect(result.breeds.first.description, isNull);
      expect(result.breeds.first.temperament, isNull);
    });

    test('should handle network timeout errors', () async {
      // Arrange
      when(
        () => mockDataSource.getCatDetails(any()),
      ).thenThrow(Exception('Connection timeout'));

      // Act & Assert
      expect(
        () => repository.getCatDetails('cat1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to get cat details:'),
          ),
        ),
      );
    });

    test('should handle server errors gracefully', () async {
      // Arrange
      when(
        () => mockDataSource.getCatDetails(any()),
      ).thenThrow(Exception('Server error: 500'));

      // Act & Assert
      expect(
        () => repository.getCatDetails('cat1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to get cat details:'),
          ),
        ),
      );
    });
  });
}
