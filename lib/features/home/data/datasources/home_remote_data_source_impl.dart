import 'package:dio/dio.dart';
import 'home_remote_data_source.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getCats() async {
    // Make API call - all HTTP concerns handled by Dio Interceptors:
    // - API key injection (AuthInterceptor)
    // - Common headers (AuthInterceptor)
    // - Request/response logging (AuthInterceptor)
    // - Error handling (AuthInterceptor)
    final response = await dio.get(
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
    );

    // Return raw API data - no data modeling or transformation here
    // Data transformation happens in Repository layer
    final List<dynamic> data = response.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
