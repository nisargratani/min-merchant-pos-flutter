import '../entities/product.dart';

/// Abstract product repository — domain layer contract.
abstract class ProductRepository {
  Future<List<Product>> getProducts();
}
