abstract class HomeRemoteDataSource {
  Future<List<Map<String, dynamic>>> getCats({int page = 0, int limit = 10});
}
