import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/features/ProductDetails/data/datasources/product_details_datasource_impl.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:dio/dio.dart';

// Mock classes
class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  late ProductDetailsDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockResponse mockResponse;

  setUp(() {
    mockDio = MockDio();
    mockResponse = MockResponse();
    dataSource = ProductDetailsDataSourceImpl(dio: mockDio);
  });

  group('ProductDetailsDataSourceImpl', () {
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

    test('should return cat detail data when API call is successful', () async {
      // Arrange
      when(() => mockResponse.data).thenReturn(mockCatDetailJson);

      when(
        () => mockDio.get('https://api.thecatapi.com/v1/images/cat1'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCatDetails('cat1');

      // Assert
      expect(result, isA<CatImageModel>());
      expect(result.id, 'cat1');
      expect(result.url, 'https://cdn2.thecatapi.com/images/cat1.jpg');
      expect(result.breeds[0].name, 'Persian');
      expect(
        result.breeds[0].description,
        'The Persian cat is a long-haired breed of cat characterized by its round face and short muzzle.',
      );

      verify(
        () => mockDio.get('https://api.thecatapi.com/v1/images/cat1'),
      ).called(1);
    });

    test('should handle different cat IDs correctly', () async {
      // Arrange
      when(() => mockResponse.data).thenReturn(mockCatDetailJson);

      when(
        () => mockDio.get('https://api.thecatapi.com/v1/images/cat2'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await dataSource.getCatDetails('cat2');

      // Assert
      verify(
        () => mockDio.get('https://api.thecatapi.com/v1/images/cat2'),
      ).called(1);
    });

    test('should throw exception when Dio throws an exception', () async {
      // Arrange
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: 'https://api.thecatapi.com/v1/images/cat1',
          ),
          error: 'Network Error',
        ),
      );

      // Act & Assert
      expect(() => dataSource.getCatDetails('cat1'), throwsException);
    });

    test('should throw exception when API returns null data', () async {
      // Arrange
      when(() => mockResponse.data).thenReturn(null);

      when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(() => dataSource.getCatDetails('cat1'), throwsException);
    });

    test(
      'should throw exception when API returns invalid data structure',
      () async {
        // Arrange
        when(() => mockResponse.data).thenReturn('invalid_data');

        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(() => dataSource.getCatDetails('cat1'), throwsException);
      },
    );

    test('should handle empty breeds array gracefully', () async {
      // Arrange
      const mockCatWithoutBreeds = {
        "id": "cat1",
        "url": "https://cdn2.thecatapi.com/images/cat1.jpg",
        "width": 800,
        "height": 600,
        "breeds": [],
      };

      when(() => mockResponse.data).thenReturn(mockCatWithoutBreeds);

      when(
        () => mockDio.get('https://api.thecatapi.com/v1/images/cat1'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCatDetails('cat1');

      // Assert
      expect(result, isA<CatImageModel>());
      expect(result.id, 'cat1');
      expect(result.breeds, isEmpty);
    });
  });
}
