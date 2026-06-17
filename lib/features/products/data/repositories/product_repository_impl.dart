import '../../../../core/network/network_info.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';

/// Concrete implementation of [ProductRepository].
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required ProductLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      if (await _networkInfo.isConnected) {
        try {
          final data = await _remoteDataSource.getProducts();
          final products = data.map((json) => Product.fromJson(json)).toList();
          // Cache the products locally
          await _localDataSource.cacheProducts(products);
          return Right(products);
        } catch (e) {
          // If remote fails but we have network, we can still try local DB
          return Right(await _localDataSource.getProducts());
        }
      } else {
        // If no network, return local products (can be empty)
        return Right(await _localDataSource.getProducts());
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
