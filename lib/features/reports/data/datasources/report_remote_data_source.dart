import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Remote data source for report API calls.
class ReportRemoteDataSource {
  final Dio _dio;

  ReportRemoteDataSource(this._dio);

  /// GET /reports/today-sales
  Future<Map<String, dynamic>> getTodaySales() async {
    try {
      final response = await _dio.get(ApiConstants.todaySales);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to fetch today\'s sales',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// GET /reports/pending-sync
  Future<Map<String, dynamic>> getPendingSync() async {
    try {
      final response = await _dio.get(ApiConstants.pendingSync);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to fetch pending sync count',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
