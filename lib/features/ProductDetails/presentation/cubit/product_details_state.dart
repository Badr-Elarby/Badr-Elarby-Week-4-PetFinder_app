import 'package:equatable/equatable.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

class ProductDetailsInitial extends ProductDetailsState {}

class ProductDetailsLoading extends ProductDetailsState {}

class ProductDetailsSuccess extends ProductDetailsState {
  final CatImageModel cat;

  const ProductDetailsSuccess({required this.cat});

  @override
  List<Object?> get props => [cat];
}

class ProductDetailsError extends ProductDetailsState {
  final String message;

  const ProductDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
