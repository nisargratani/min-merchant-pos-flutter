import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Remote data source for products API.
class ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSource(this._dio);

  /// GET /products — returns list of product maps.
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get(ApiConstants.products);
      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to fetch products',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
