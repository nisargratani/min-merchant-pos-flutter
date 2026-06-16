import '../entities/order_entity.dart';

/// Abstract order repository — domain layer contract.
abstract class OrderRepository {
  /// Save an order to the local SQLite database.
  Future<void> saveOrderLocally(OrderEntity order);

  /// Get all orders from local database.
  Future<List<OrderEntity>> getLocalOrders();

  /// Get pending (un-synced) orders from local database.
  Future<List<OrderEntity>> getPendingOrders();

  /// Sync pending orders to the backend.
  /// Returns list of successfully synced order IDs.
  Future<List<String>> syncOrdersToBackend(List<OrderEntity> orders);

  /// Update the sync status of a local order.
  Future<void> updateOrderSyncStatus(String localOrderId, String status, {int? serverOrderId});

  /// Get orders from backend API.
  Future<List<OrderEntity>> getRemoteOrders();

  /// Simulate payment for a synced order.
  /// Returns updated order with paymentRef and paymentId.
  Future<OrderEntity> processPayment({
    required OrderEntity order,
    required String paymentRef,
  });

  /// Check payment status from backend.
  Future<String> getPaymentStatus(int paymentId);

  /// Update payment info in local DB.
  Future<void> updatePaymentInfo({
    required String localOrderId,
    required String paymentStatus,
    String? paymentRef,
    int? paymentId,
  });
}
