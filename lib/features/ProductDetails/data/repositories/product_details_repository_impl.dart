import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/ProductDetails/data/datasources/product_details_datasource.dart';
import 'package:petfinder_app/features/ProductDetails/data/repositories/product_details_repository.dart';

class ProductDetailsRepositoryImpl implements ProductDetailsRepository {
  final ProductDetailsDataSource dataSource;

  ProductDetailsRepositoryImpl({required this.dataSource});

  @override
  Future<CatImageModel> getCatDetails(String id) async {
    try {
      return await dataSource.getCatDetails(id);
    } catch (e) {
      throw Exception('Failed to get cat details: $e');
    }
  }
}
