import '../models/cat_image_model.dart';

abstract class HomeRepository {
  Future<List<CatImageModel>> getCats();
  List<CatImageModel> searchCats(List<CatImageModel> cats, String query);
}
