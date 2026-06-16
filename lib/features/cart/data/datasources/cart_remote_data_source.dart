import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Remote data source for cart API.
class CartRemoteDataSource {
  final Dio _dio;

  CartRemoteDataSource(this._dio);

  /// GET /cart
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _dio.get(ApiConstants.cart);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to fetch cart',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// POST /cart/items
  Future<void> addToCart(int productId, int qty) async {
    try {
      await _dio.post(ApiConstants.cartItems, data: {
        'productId': productId,
        'qty': qty,
      });
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to add to cart';
      throw ServerException(message: msg, statusCode: e.response?.statusCode);
    }
  }

  /// DELETE /cart/items/{product_id}
  Future<void> removeFromCart(int productId) async {
    try {
      await _dio.delete(ApiConstants.cartItem(productId));
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to remove item',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// DELETE /cart/clear
  Future<void> clearCart() async {
    try {
      await _dio.delete(ApiConstants.cartClear);
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to clear cart',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
