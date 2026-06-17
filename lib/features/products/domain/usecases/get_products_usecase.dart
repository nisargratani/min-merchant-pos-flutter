import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Use case to fetch the list of products.
class GetProductsUseCase implements UseCase<List<Product>, NoParams> {
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) {
    return _repository.getProducts();
  }
}
