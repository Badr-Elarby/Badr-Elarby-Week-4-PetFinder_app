import 'cat_breed_model.dart';

class CatImageModel {
  final String id;
  final String url;
  final int width;
  final int height;
  final List<CatBreedModel> breeds;

  const CatImageModel({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    required this.breeds,
  });

  factory CatImageModel.fromJson(Map<String, dynamic> json) {
    return CatImageModel(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      breeds:
          (json['breeds'] as List<dynamic>?)
              ?.map(
                (breed) =>
                    CatBreedModel.fromJson(breed as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'width': width,
      'height': height,
      'breeds': breeds.map((breed) => breed.toJson()).toList(),
    };
  }
}
