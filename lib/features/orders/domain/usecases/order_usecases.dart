import '../../../../core/usecase/usecase.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// Parameters for creating an order.
class CreateOrderParams {
  final String paymentMode;
  final Cart cart;

  const CreateOrderParams({required this.paymentMode, required this.cart});
}

/// Creates an order from the current cart, saves locally.
/// The actual sync decision is handled at the provider/notifier level.
class CreateOrderUseCase implements UseCase<OrderEntity, CreateOrderParams> {
  final OrderRepository _repository;

  CreateOrderUseCase(this._repository);

  @override
  Future<OrderEntity> call(CreateOrderParams params) async {
    // UUID is generated at the provider level and passed via the entity
    throw UnimplementedError(
      'CreateOrderUseCase.call is not used directly. '
      'Use the OrderNotifier which handles UUID generation and connectivity.',
    );
  }

  /// Save order to local DB.
  Future<void> saveLocally(OrderEntity order) => _repository.saveOrderLocally(order);
}

/// Fetches all orders (combines local + remote).
class GetOrdersUseCase implements UseCase<List<OrderEntity>, NoParams> {
  final OrderRepository _repository;

  GetOrdersUseCase(this._repository);

  @override
  Future<List<OrderEntity>> call(NoParams params) => _repository.getLocalOrders();

  Future<List<OrderEntity>> getRemoteOrders() => _repository.getRemoteOrders();
}

/// Syncs pending offline orders to the backend.
class SyncOrdersUseCase implements UseCase<void, NoParams> {
  final OrderRepository _repository;

  SyncOrdersUseCase(this._repository);

  @override
  Future<void> call(NoParams params) async {
    final pending = await _repository.getPendingOrders();
    if (pending.isEmpty) return;

    final syncedIds = await _repository.syncOrdersToBackend(pending);

    for (final id in syncedIds) {
      await _repository.updateOrderSyncStatus(id, 'SYNCED');
    }

    // Mark non-synced as FAILED
    for (final order in pending) {
      if (!syncedIds.contains(order.localOrderId)) {
        await _repository.updateOrderSyncStatus(order.localOrderId, 'FAILED');
      }
    }
  }
}
