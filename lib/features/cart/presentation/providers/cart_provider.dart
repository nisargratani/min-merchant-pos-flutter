import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/cart_remote_data_source.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/cart_usecases.dart';

// ── Data Sources ──
final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSource(ref.watch(dioProvider));
});

// ── Repository ──
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    remoteDataSource: ref.watch(cartRemoteDataSourceProvider),
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

  CartNotifier({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required ClearCartUseCase clearCartUseCase,
  })  : _getCartUseCase = getCartUseCase,
        _addToCartUseCase = addToCartUseCase,
        _removeFromCartUseCase = removeFromCartUseCase,
        _clearCartUseCase = clearCartUseCase,
        super(const AsyncValue.data(Cart.empty)) {
    fetchCart();
  }

  Future<void> fetchCart() async {
    state = const AsyncValue.loading();
    try {
      final cart = await _getCartUseCase(const NoParams());
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addToCart(int productId, int qty) async {
    try {
      await _addToCartUseCase(AddToCartParams(productId: productId, qty: qty));
      await fetchCart();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      await _removeFromCartUseCase(productId);
      await fetchCart();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearCart() async {
    try {
      await _clearCartUseCase(const NoParams());
      state = const AsyncValue.data(Cart.empty);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<Cart>>((ref) {
  return CartNotifier(
    getCartUseCase: ref.watch(getCartUseCaseProvider),
    addToCartUseCase: ref.watch(addToCartUseCaseProvider),
    removeFromCartUseCase: ref.watch(removeFromCartUseCaseProvider),
    clearCartUseCase: ref.watch(clearCartUseCaseProvider),
  );
});
