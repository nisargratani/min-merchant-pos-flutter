import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

/// Concrete implementation of [ProductRepository].
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Product>> getProducts() async {
    final data = await _remoteDataSource.getProducts();
    return data.map((json) => Product.fromJson(json)).toList();
  }
}
