import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/datasources/order_local_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/order_usecases.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

// ── Data Sources ──
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource(ref.watch(dioProvider));
});

final orderLocalDataSourceProvider = Provider<OrderLocalDataSource>((ref) {
  return OrderLocalDataSource(ref.watch(databaseHelperProvider));
});

// ── Repository ──
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    remoteDataSource: ref.watch(orderRemoteDataSourceProvider),
    localDataSource: ref.watch(orderLocalDataSourceProvider),
  );
});

// ── Use Cases ──
final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  return CreateOrderUseCase(ref.watch(orderRepositoryProvider));
});

final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  return GetOrdersUseCase(ref.watch(orderRepositoryProvider));
});

final syncOrdersUseCaseProvider = Provider<SyncOrdersUseCase>((ref) {
  return SyncOrdersUseCase(ref.watch(orderRepositoryProvider));
});

// ── State ──

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderEntity>>> {
  final OrderRepository _repository;
  final SyncOrdersUseCase _syncOrdersUseCase;
  final CartNotifier _cartNotifier;
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;

  OrderNotifier({
    required OrderRepository repository,
    required SyncOrdersUseCase syncOrdersUseCase,
    required CartNotifier cartNotifier,
    required NetworkInfo networkInfo,
  })  : _repository = repository,
        _syncOrdersUseCase = syncOrdersUseCase,
        _cartNotifier = cartNotifier,
        _networkInfo = networkInfo,
        super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await fetchOrders();
    _listenToConnectivity();
  }

  /// Listen to connectivity changes and auto-sync when back online.
  void _listenToConnectivity() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        syncPendingOrders();
      }
    });
  }

  /// Fetch all local orders.
  Future<void> fetchOrders() async {
    final result = await _repository.getLocalOrders();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (orders) => state = AsyncValue.data(orders),
    );
  }

  /// Create an order from the current cart.
  Future<void> checkout(String paymentMode) async {
    final cartState = _cartNotifier.state;
    final cart = cartState.valueOrNull;
    if (cart == null || cart.items.isEmpty) return;

    final localOrderId = const Uuid().v4();
    final isOnline = await _networkInfo.isConnected;

    final orderItems = cart.items
        .map((item) => OrderItem(
              productId: item.productId,
              productName: item.name,
              qty: item.qty,
              price: item.price,
            ))
        .toList();

    final order = OrderEntity(
      localOrderId: localOrderId,
      paymentStatus: 'PENDING',
      paymentMode: paymentMode,
      totalAmount: cart.totalAmount,
      syncStatus: 'PENDING',
      items: orderItems,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Save to local DB first (offline-first)
    final saveResult = await _repository.saveOrderLocally(order);
    await saveResult.fold(
      (failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) async {
        // Clear the server-side cart
        await _cartNotifier.clearCart();

        // If online, try to sync and process payment immediately
        if (isOnline) {
          final syncResult = await _repository.syncOrdersToBackend([order]);
          await syncResult.fold(
            (_) async => await _repository.updateOrderSyncStatus(localOrderId, 'PENDING'),
            (syncedIds) async {
              if (syncedIds.contains(localOrderId)) {
                // After sync, simulate payment automatically
                await _simulatePaymentForOrder(localOrderId);
              }
            }
          );
        }

        // Refresh order list
        await fetchOrders();
      }
    );
  }

  /// Simulate payment for a synced order (internal helper).
  Future<void> _simulatePaymentForOrder(String localOrderId) async {
    final ordersResult = await _repository.getLocalOrders();
    await ordersResult.fold(
      (_) async {},
      (orders) async {
        try {
          final order = orders.firstWhere(
            (o) => o.localOrderId == localOrderId,
          );

          if (order.serverOrderId == null) return;

          // Generate a unique paymentRef (transaction ID)
          final paymentRef = 'TXN-${const Uuid().v4().substring(0, 8).toUpperCase()}';

          final paymentResult = await _repository.processPayment(
            order: order,
            paymentRef: paymentRef,
          );
          
          await paymentResult.fold(
            (_) async => await _repository.updatePaymentInfo(
              localOrderId: localOrderId,
              paymentStatus: 'FAILED',
            ),
            (_) async {} // success handled in repository
          );
        } catch (_) {
          await _repository.updatePaymentInfo(
            localOrderId: localOrderId,
            paymentStatus: 'FAILED',
          );
        }
      }
    );
  }

  /// Manually trigger payment simulation for a specific order.
  /// Used when the user taps "Pay Now" on a synced but unpaid order.
  Future<void> simulatePayment(OrderEntity order) async {
    if (order.serverOrderId == null) return;

    final paymentRef = 'TXN-${const Uuid().v4().substring(0, 8).toUpperCase()}';

    final result = await _repository.processPayment(
      order: order,
      paymentRef: paymentRef,
    );

    await result.fold(
      (_) async {
        await _repository.updatePaymentInfo(
          localOrderId: order.localOrderId,
          paymentStatus: 'FAILED',
        );
        await fetchOrders();
      },
      (_) async {
        await fetchOrders();
      }
    );
  }

  /// Check and update payment status for an order.
  Future<void> checkPaymentStatus(OrderEntity order) async {
    if (order.paymentId == null) return;

    final result = await _repository.getPaymentStatus(order.paymentId!);
    await result.fold(
      (_) async {},
      (status) async {
        await _repository.updatePaymentInfo(
          localOrderId: order.localOrderId,
          paymentStatus: status,
        );
        await fetchOrders();
      }
    );
  }

  /// Sync all pending/failed orders to the backend, then process payments.
  Future<void> syncPendingOrders() async {
    final syncResult = await _syncOrdersUseCase(const NoParams());
    await syncResult.fold(
      (_) async {},
      (_) async {
        // After syncing, try to process payments for synced orders that are unpaid
        final ordersResult = await _repository.getLocalOrders();
        await ordersResult.fold(
          (_) async {},
          (orders) async {
            for (final order in orders) {
              if (order.syncStatus == 'SYNCED' && order.paymentStatus == 'PENDING' && order.serverOrderId != null) {
                await _simulatePaymentForOrder(order.localOrderId);
              }
            }
          }
        );
        await fetchOrders();
      }
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderEntity>>>((ref) {
  return OrderNotifier(
    repository: ref.watch(orderRepositoryProvider),
    syncOrdersUseCase: ref.watch(syncOrdersUseCaseProvider),
    cartNotifier: ref.watch(cartNotifierProvider.notifier),
    networkInfo: ref.watch(networkInfoProvider),
  );
});
