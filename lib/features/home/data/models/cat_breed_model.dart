import 'package:equatable/equatable.dart';

class CatBreedModel extends Equatable {
  final String id;
  final String name;
  final String? origin;
  final String? lifeSpan;
  final String? weight;
  final String? description;
  final String? age;
  final String? temperament;

  const CatBreedModel({
    required this.id,
    required this.name,
    this.origin,
    this.lifeSpan,
    this.weight,
    this.description,
    this.age,
    this.temperament,
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
      description: json['description'] as String?,
      age: json['age'] as String?,
      temperament: json['temperament'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'life_span': lifeSpan,
      'weight': weight != null ? {'metric': weight} : null,
      'description': description,
      'age': age,
      'temperament': temperament,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    origin,
    lifeSpan,
    weight,
    description,
    age,
    temperament,
  ];
}
