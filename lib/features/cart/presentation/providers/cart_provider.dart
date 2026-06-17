import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/cart_local_data_source.dart';
import '../../data/datasources/cart_remote_data_source.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/cart_usecases.dart';

// ── Data Sources ──
final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSource(ref.watch(dioProvider));
});

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSource(ref.watch(databaseHelperProvider));
});

// ── Repository ──
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    remoteDataSource: ref.watch(cartRemoteDataSourceProvider),
    localDataSource: ref.watch(cartLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// ── Use Cases ──
final getCartUseCaseProvider = Provider<GetCartUseCase>((ref) {
  return GetCartUseCase(ref.watch(cartRepositoryProvider));
});

final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  return AddToCartUseCase(ref.watch(cartRepositoryProvider));
});

final removeFromCartUseCaseProvider = Provider<RemoveFromCartUseCase>((ref) {
  return RemoveFromCartUseCase(ref.watch(cartRepositoryProvider));
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  return ClearCartUseCase(ref.watch(cartRepositoryProvider));
});

// ── State ──

class CartNotifier extends StateNotifier<AsyncValue<Cart>> {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;

  CartNotifier({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required ClearCartUseCase clearCartUseCase,
    required NetworkInfo networkInfo,
  })  : _getCartUseCase = getCartUseCase,
        _addToCartUseCase = addToCartUseCase,
        _removeFromCartUseCase = removeFromCartUseCase,
        _clearCartUseCase = clearCartUseCase,
        _networkInfo = networkInfo,
        super(const AsyncValue.data(Cart.empty)) {
    _init();
  }

  void _init() {
    fetchCart();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        fetchCart();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchCart() async {
    // Remove state = const AsyncValue.loading() to prevent UI flickering on refresh
    final result = await _getCartUseCase(const NoParams());
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (cart) => state = AsyncValue.data(cart),
    );
  }

  Future<void> addToCart(int productId, int qty) async {
    final result = await _addToCartUseCase(AddToCartParams(productId: productId, qty: qty));
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => fetchCart(),
    );
  }

  Future<void> removeFromCart(int productId) async {
    final result = await _removeFromCartUseCase(productId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => fetchCart(),
    );
  }

  Future<void> clearCart() async {
    final result = await _clearCartUseCase(const NoParams());
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(Cart.empty),
    );
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<Cart>>((ref) {
  return CartNotifier(
    getCartUseCase: ref.watch(getCartUseCaseProvider),
    addToCartUseCase: ref.watch(addToCartUseCaseProvider),
    removeFromCartUseCase: ref.watch(removeFromCartUseCaseProvider),
    clearCartUseCase: ref.watch(clearCartUseCaseProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});
