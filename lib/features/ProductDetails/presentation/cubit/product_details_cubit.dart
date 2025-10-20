import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petfinder_app/features/ProductDetails/data/repositories/product_details_repository.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/cubit/product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final ProductDetailsRepository repository;
  String? _currentCatId;

  ProductDetailsCubit({required this.repository})
    : super(ProductDetailsInitial());

  String? get currentCatId => _currentCatId;

  Future<void> getCatDetails(String id) async {
    // If we already have the same cat loaded, don't reload
    if (state is ProductDetailsSuccess && _currentCatId == id) {
      return;
    }

    _currentCatId = id;
    emit(ProductDetailsLoading());

    try {
      final cat = await repository.getCatDetails(id);
      emit(ProductDetailsSuccess(cat: cat));
    } catch (e) {
      emit(ProductDetailsError(message: e.toString()));
    }
  }

  void clearState() {
    _currentCatId = null;
    emit(ProductDetailsInitial());
  }
}
