import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_products_usecase.dart';

// ── Data Sources ──
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(ref.watch(dioProvider));
});

// ── Repository ──
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
  );
});

// ── Use Cases ──
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

// ── State ──

/// Fetches product list; supports refresh via ref.invalidate(productsProvider).
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final useCase = ref.watch(getProductsUseCaseProvider);
  return useCase(const NoParams());
});
