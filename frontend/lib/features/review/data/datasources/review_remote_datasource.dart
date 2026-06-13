import 'package:dio/dio.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/features/review/data/models/review_mapper.dart';
import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';
import 'package:frontend/features/review/domain/review_exception.dart';

class ReviewRemoteDataSource {
  const ReviewRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Review> create(CreateReviewParams params) async {
    try {
      final res = await _dio.post<dynamic>(
        ReviewEndpoints.create,
        data: {
          'bookingId': params.bookingId,
          'rating': params.rating,
          if (params.comment != null && params.comment!.isNotEmpty)
            'comment': params.comment,
        },
      );
      return reviewFromJson(_data(res) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<UserReviews> getForUser(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        UserEndpoints.reviews(userId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return userReviewsFromJson(_data(res) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  dynamic _data(Response<dynamic> res) {
    final body = res.data as Map<String, dynamic>;
    return body['data'];
  }

  ReviewException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ReviewException(
        (data['error'] as String?) ?? 'Đã xảy ra lỗi',
        code: data['code'] as String?,
      );
    }
    return const ReviewException('Không thể kết nối tới máy chủ');
  }
}
