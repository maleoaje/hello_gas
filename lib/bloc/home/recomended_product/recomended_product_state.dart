import 'package:hello_gas/model/home/recomended_product_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RecomendedProductState {}

class InitialRecomendedProductState extends RecomendedProductState {}

class RecomendedProductError extends RecomendedProductState {
  final String errorMessage;

  RecomendedProductError({
    required this.errorMessage,
  });
}

class RecomendedProductWaiting extends RecomendedProductState {}

class GetRecomendedProductSuccess extends RecomendedProductState {
  final List<RecomendedProductModel> recomendedProductData;
  GetRecomendedProductSuccess({required this.recomendedProductData});
}