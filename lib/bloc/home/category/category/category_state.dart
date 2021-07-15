import 'package:hello_gas/model/home/category/category_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CategoryState {}

class InitialCategoryState extends CategoryState {}

class CategoryError extends CategoryState {
  final String errorMessage;

  CategoryError({
    required this.errorMessage,
  });
}

class CategoryWaiting extends CategoryState {}

class GetCategorySuccess extends CategoryState {
  final List<CategoryModel> categoryData;
  GetCategorySuccess({required this.categoryData});
}