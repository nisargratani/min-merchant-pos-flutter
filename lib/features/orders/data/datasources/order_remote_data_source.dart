import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Remote data source for order/sync/payment API calls.
class OrderRemoteDataSource {
  final Dio _dio;

  OrderRemoteDataSource(this._dio);

  /// GET /orders — returns list of orders from backend.
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await _dio.get(ApiConstants.orders);
      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to fetch orders',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// POST /sync/orders — syncs offline orders to the server.
  Future<Map<String, dynamic>> syncOrders(
    List<Map<String, dynamic>> orders,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.syncOrders,
        data: {'orders': orders},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to sync orders',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// POST /payments — simulate payment for an order.
  /// Returns payment result with paymentId, paymentRef, status.
  Future<Map<String, dynamic>> processPayment({
    required int serverOrderId,
    required double amount,
    required String localOrderId,
    required String paymentMode,
    required String paymentRef,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.payments,
        data: {
          'serverOrderId': serverOrderId,
          'amount': amount,
          'localOrderId': localOrderId,
          'paymentMode': paymentMode,
          'paymentRef': paymentRef,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Payment failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// GET /payments/{pid} — check payment status.
  Future<Map<String, dynamic>> getPaymentStatus(int paymentId) async {
    try {
      final response = await _dio.get('${ApiConstants.payments}/$paymentId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to get payment status',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// POST /sync/payments — syncs offline payment confirmations.
  Future<Map<String, dynamic>> syncPayments(
    List<Map<String, dynamic>> payments,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.syncPayments,
        data: {'payments': payments},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to sync payments',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
