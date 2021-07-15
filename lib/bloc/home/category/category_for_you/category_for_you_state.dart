import 'package:hello_gas/model/home/category/category_for_you_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CategoryForYouState {}

class InitialCategoryForYouState extends CategoryForYouState {}

class CategoryForYouError extends CategoryForYouState {
  final String errorMessage;

  CategoryForYouError({
    required this.errorMessage,
  });
}

class CategoryForYouWaiting extends CategoryForYouState {}

class GetCategoryForYouSuccess extends CategoryForYouState {
  final List<CategoryForYouModel> categoryForYouData;
  GetCategoryForYouSuccess({required this.categoryForYouData});
}