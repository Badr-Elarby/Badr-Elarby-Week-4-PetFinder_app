class CatBreedModel {
  final String id;
  final String name;
  final String? origin;
  final String? lifeSpan;
  final String? weight;

  const CatBreedModel({
    required this.id,
    required this.name,
    this.origin,
    this.lifeSpan,
    this.weight,
  });

  factory CatBreedModel.fromJson(Map<String, dynamic> json) {
    return CatBreedModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      origin: json['origin'] as String?,
      lifeSpan: json['life_span'] as String?,
      weight: json['weight'] != null
          ? json['weight']['metric'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'life_span': lifeSpan,
      'weight': weight != null ? {'metric': weight} : null,
    };
  }
}
