import 'package:hello_gas/model/general/review_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ReviewState {}

class InitialReviewState extends ReviewState {}

class ReviewError extends ReviewState {
  final String errorMessage;

  ReviewError({
    required this.errorMessage,
  });
}

class ReviewProductError extends ReviewState {
  final String errorMessage;

  ReviewProductError({
    required this.errorMessage,
  });
}

class ReviewWaiting extends ReviewState {}

class ReviewProductWaiting extends ReviewState {}

class GetReviewSuccess extends ReviewState {
  final List<ReviewModel> reviewData;
  GetReviewSuccess({required this.reviewData});
}

class GetReviewProductSuccess extends ReviewState {
  final List<ReviewModel> reviewData;
  GetReviewProductSuccess({required this.reviewData});
}