import 'package:dio/dio.dart';
import 'home_remote_data_source.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getCats({
    int page = 0,
    int limit = 10,
  }) async {
    final response = await dio.get(
      'https://api.thecatapi.com/v1/images/search',
      queryParameters: {
        'size': 'med',
        'mime_types': 'jpg',
        'format': 'json',
        'has_breeds': 'true',
        'order': 'RANDOM',
        'page': '$page',
        'limit': '$limit',
      },
    );

    final data = (response.data is List) ? response.data as List : [];
    return data.cast<Map<String, dynamic>>();
  }
}
