import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Fetches all products from the backend.
class GetProductsUseCase implements UseCase<List<Product>, NoParams> {
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  @override
  Future<List<Product>> call(NoParams params) {
    return _repository.getProducts();
  }
}
