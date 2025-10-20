import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:petfinder_app/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:dio/dio.dart';

// Mock classes
class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  late HomeRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockResponse mockResponse;

  setUp(() {
    mockDio = MockDio();
    mockResponse = MockResponse();
    dataSource = HomeRemoteDataSourceImpl(dio: mockDio);
  });

  group('HomeRemoteDataSourceImpl', () {
    const mockCatsJson = [
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

    test(
      'should return list of cat data when API call is successful',
      () async {
        // Arrange
        when(() => mockResponse.data).thenReturn(mockCatsJson);

        when(
          () => mockDio.get(
            'https://api.thecatapi.com/v1/images/search',
            queryParameters: {
              'size': 'med',
              'mime_types': 'jpg',
              'format': 'json',
              'has_breeds': 'true',
              'order': 'RANDOM',
              'page': '0',
              'limit': '10',
            },
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getCats();

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, 2);
        expect(result[0]['id'], 'cat1');
        expect(result[1]['url'], 'https://cdn2.thecatapi.com/images/cat2.jpg');
        verify(
          () => mockDio.get(
            'https://api.thecatapi.com/v1/images/search',
            queryParameters: {
              'size': 'med',
              'mime_types': 'jpg',
              'format': 'json',
              'has_breeds': 'true',
              'order': 'RANDOM',
              'page': '0',
              'limit': '10',
            },
          ),
        ).called(1);
      },
    );

    test('should handle page parameter correctly', () async {
      // Arrange
      when(() => mockResponse.data).thenReturn(mockCatsJson);

      when(
        () => mockDio.get(
          'https://api.thecatapi.com/v1/images/search',
          queryParameters: {
            'size': 'med',
            'mime_types': 'jpg',
            'format': 'json',
            'has_breeds': 'true',
            'order': 'RANDOM',
            'page': '5',
            'limit': '10',
          },
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await dataSource.getCats(page: 5);

      // Assert
      verify(
        () => mockDio.get(
          'https://api.thecatapi.com/v1/images/search',
          queryParameters: {
            'size': 'med',
            'mime_types': 'jpg',
            'format': 'json',
            'has_breeds': 'true',
            'order': 'RANDOM',
            'page': '5',
            'limit': '10',
          },
        ),
      ).called(1);
    });

    test('should handle limit parameter correctly', () async {
      // Arrange
      when(() => mockResponse.data).thenReturn(mockCatsJson);

      when(
        () => mockDio.get(
          'https://api.thecatapi.com/v1/images/search',
          queryParameters: {
            'size': 'med',
            'mime_types': 'jpg',
            'format': 'json',
            'has_breeds': 'true',
            'order': 'RANDOM',
            'page': '0',
            'limit': '5',
          },
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await dataSource.getCats(limit: 5);

      // Assert
      verify(
        () => mockDio.get(
          'https://api.thecatapi.com/v1/images/search',
          queryParameters: {
            'size': 'med',
            'mime_types': 'jpg',
            'format': 'json',
            'has_breeds': 'true',
            'order': 'RANDOM',
            'page': '0',
            'limit': '5',
          },
        ),
      ).called(1);
    });

    test('should throw exception when Dio throws an exception', () async {
      // Arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: 'https://api.thecatapi.com/v1/images/search',
          ),
          error: 'Network Error',
        ),
      );

      // Act & Assert
      expect(() => dataSource.getCats(), throwsException);
    });

    test('should return empty list when API returns empty data', () async {
      // Arrange
      when(() => mockResponse.data).thenReturn([]);

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCats();

      // Assert
      expect(result, isEmpty);
    });

    test('should handle null data correctly', () async {
      // Arrange
      when(() => mockResponse.data).thenReturn(null);

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCats();

      // Assert
      expect(result, isEmpty);
    });
  });
}
