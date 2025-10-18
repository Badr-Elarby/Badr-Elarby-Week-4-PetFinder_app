import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';

abstract class ProductDetailsDataSource {
  Future<CatImageModel> getCatDetails(String id);
}
