import 'package:dio/dio.dart';
import 'package:petfinder_app/core/services/api_key_service.dart';

class AuthInterceptor extends Interceptor {
  final ApiKeyService apiKeyService;

  AuthInterceptor({required this.apiKeyService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add API key header for Cat API requests
    if (options.uri.toString().contains('api.thecatapi.com')) {
      final apiKey = apiKeyService.getApiKey();
      options.queryParameters['api_key'] = apiKey;
    }

    // Add common headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    // Log request for debugging
    print('🚀 Request: ${options.method} ${options.uri}');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response for debugging
    print('✅ Response: ${response.statusCode} ${response.requestOptions.uri}');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error for debugging
    print('❌ Error: ${err.type} - ${err.message}');
    print('❌ URL: ${err.requestOptions.uri}');

    // Handle different types of errors
    DioException processedError = _processError(err);

    super.onError(processedError, handler);
  }

  DioException _processError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return DioException(
          requestOptions: error.requestOptions,
          error: 'Connection timeout. Please check your internet connection.',
          type: error.type,
        );

      case DioExceptionType.connectionError:
        return DioException(
          requestOptions: error.requestOptions,
          error: 'No internet connection. Please check your network.',
          type: error.type,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message = 'An error occurred';

        switch (statusCode) {
          case 400:
            message = 'Bad request. Please check your input.';
            break;
          case 401:
            message = 'Unauthorized. Please check your API key.';
            break;
          case 403:
            message = 'Forbidden. Access denied.';
            break;
          case 404:
            message = 'Resource not found.';
            break;
          case 429:
            message = 'Too many requests. Please try again later.';
            break;
          case 500:
            message = 'Internal server error. Please try again later.';
            break;
          default:
            message = 'Server error (${statusCode}). Please try again.';
        }

        return DioException(
          requestOptions: error.requestOptions,
          error: message,
          type: error.type,
          response: error.response,
        );

      case DioExceptionType.cancel:
        return DioException(
          requestOptions: error.requestOptions,
          error: 'Request was cancelled.',
          type: error.type,
        );

      case DioExceptionType.unknown:
      default:
        return DioException(
          requestOptions: error.requestOptions,
          error: 'An unexpected error occurred. Please try again.',
          type: error.type,
        );
    }
  }
}
