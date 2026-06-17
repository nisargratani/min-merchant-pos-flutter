import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/order_entity.dart';

/// Abstract order repository — domain layer contract.
abstract class OrderRepository {
  /// Save an order to the local SQLite database.
  Future<Either<Failure, void>> saveOrderLocally(OrderEntity order);

  /// Get all orders from local database.
  Future<Either<Failure, List<OrderEntity>>> getLocalOrders();

  /// Get pending (un-synced) orders from local database.
  Future<Either<Failure, List<OrderEntity>>> getPendingOrders();

  /// Sync pending orders to the backend.
  /// Returns list of successfully synced order IDs.
  Future<Either<Failure, List<String>>> syncOrdersToBackend(List<OrderEntity> orders);

  /// Update the sync status of a local order.
  Future<Either<Failure, void>> updateOrderSyncStatus(String localOrderId, String status, {int? serverOrderId});

  /// Get orders from backend API.
  Future<Either<Failure, List<OrderEntity>>> getRemoteOrders();

  /// Simulate payment for a synced order.
  /// Returns updated order with paymentRef and paymentId.
  Future<Either<Failure, OrderEntity>> processPayment({
    required OrderEntity order,
    required String paymentRef,
  });

  /// Check payment status from backend.
  Future<Either<Failure, String>> getPaymentStatus(int paymentId);

  /// Update payment info in local DB.
  Future<Either<Failure, void>> updatePaymentInfo({
    required String localOrderId,
    required String paymentStatus,
    String? paymentRef,
    int? paymentId,
  });
}
