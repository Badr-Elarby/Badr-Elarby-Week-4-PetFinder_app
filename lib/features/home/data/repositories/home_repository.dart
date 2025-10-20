import '../models/cat_image_model.dart';

abstract class HomeRepository {
  Future<List<CatImageModel>> getCats({int page = 0, int limit = 10});
  List<CatImageModel> searchCats(List<CatImageModel> cats, String query);
}
