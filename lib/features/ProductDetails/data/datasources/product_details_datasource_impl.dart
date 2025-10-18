import 'package:dio/dio.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/ProductDetails/data/datasources/product_details_datasource.dart';

class ProductDetailsDataSourceImpl implements ProductDetailsDataSource {
  final Dio dio;

  ProductDetailsDataSourceImpl({required this.dio});

  @override
  Future<CatImageModel> getCatDetails(String id) async {
    try {
      final response = await dio.get('https://api.thecatapi.com/v1/images/$id');

      final data = response.data as Map<String, dynamic>;
      return CatImageModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch cat details: $e');
    }
  }
}
