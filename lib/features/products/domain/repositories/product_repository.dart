import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/product.dart';

/// Abstract product repository — domain layer contract.
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
}
