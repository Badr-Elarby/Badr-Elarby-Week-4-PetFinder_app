import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petfinder_app/core/services/api_key_service.dart';
import 'package:petfinder_app/core/services/local_storage_service.dart';
import 'package:petfinder_app/core/network/dio_interceptor.dart';
import 'package:petfinder_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:petfinder_app/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:petfinder_app/features/home/data/repositories/home_repository.dart';
import 'package:petfinder_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:petfinder_app/features/home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:petfinder_app/features/ProductDetails/data/datasources/product_details_datasource.dart';
import 'package:petfinder_app/features/ProductDetails/data/datasources/product_details_datasource_impl.dart';
import 'package:petfinder_app/features/ProductDetails/data/repositories/product_details_repository.dart';
import 'package:petfinder_app/features/ProductDetails/data/repositories/product_details_repository_impl.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/cubit/product_details_cubit.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_cubit.dart';
import 'package:petfinder_app/core/routing/app_router.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Core Services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  const flutterSecureStorage = FlutterSecureStorage();
  getIt.registerLazySingleton(() => flutterSecureStorage);

  // Core Services
  getIt.registerLazySingleton(
    () => LocalStorageService(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton(() => ApiKeyService(sharedPreferences: getIt()));

  // Initialize API key in SharedPreferences
  await getIt<ApiKeyService>().initializeApiKey();

  // AuthInterceptor - HTTP request/response interceptor
  getIt.registerLazySingleton(() => AuthInterceptor(apiKeyService: getIt()));

  // Configure Dio with interceptors
  final dio = Dio();
  dio.options = BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );
  dio.interceptors.add(getIt<AuthInterceptor>());
  getIt.registerLazySingleton(() => dio);

  // Data Sources
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<ProductDetailsDataSource>(
    () => ProductDetailsDataSourceImpl(dio: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<ProductDetailsRepository>(
    () => ProductDetailsRepositoryImpl(dataSource: getIt()),
  );

  // Cubits
  getIt.registerFactory(() => HomeCubit(homeRepository: getIt()));
  getIt.registerFactory(() => ProductDetailsCubit(repository: getIt()));
  getIt.registerFactory(() => FavoritesCubit());

  // App Router
  getIt.registerLazySingleton(() => AppRouter());
}
