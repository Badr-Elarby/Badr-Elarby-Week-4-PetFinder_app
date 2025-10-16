import 'cat_image_model.dart';

class CatsResponseModel {
  final List<CatImageModel> cats;

  const CatsResponseModel({required this.cats});

  factory CatsResponseModel.fromJson(List<dynamic> json) {
    return CatsResponseModel(
      cats: json
          .map((cat) => CatImageModel.fromJson(cat as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'cats': cats.map((cat) => cat.toJson()).toList()};
  }
}
