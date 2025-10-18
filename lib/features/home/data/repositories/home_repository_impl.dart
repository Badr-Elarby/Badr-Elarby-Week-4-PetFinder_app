import '../datasources/home_remote_data_source.dart';
import '../models/cat_image_model.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CatImageModel>> getCats({int page = 0, int limit = 10}) async {
    try {
      // Get raw API data from Data Source
      final rawCatsData = await remoteDataSource.getCats(
        page: page,
        limit: limit,
      );

      // Transform raw data to domain models in Repository
      final cats = rawCatsData
          .map((catData) => CatImageModel.fromJson(catData))
          .toList();

      return cats;
    } catch (e) {
      throw Exception('Failed to get cats: $e');
    }
  }

  @override
  List<CatImageModel> searchCats(List<CatImageModel> cats, String query) {
    if (query.isEmpty) return cats;

    // Perform data filtering/manipulation in Repository
    return cats.where((cat) {
      if (cat.breeds.isEmpty) return false;

      final breed = cat.breeds.first;
      final searchTerm = query.toLowerCase();

      // Search across multiple attributes: name, origin, and weight
      final nameMatch = breed.name.toLowerCase().contains(searchTerm);
      final originMatch =
          breed.origin?.toLowerCase().contains(searchTerm) ?? false;
      final weightMatch =
          breed.weight?.toLowerCase().contains(searchTerm) ?? false;

      return nameMatch || originMatch || weightMatch;
    }).toList();
  }
}
