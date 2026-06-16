import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../datasources/order_local_data_source.dart';

/// Concrete implementation of [OrderRepository].
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;
  final OrderLocalDataSource _localDataSource;

  OrderRepositoryImpl({
    required OrderRemoteDataSource remoteDataSource,
    required OrderLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<void> saveOrderLocally(OrderEntity order) async {
    await _localDataSource.insertOrder(order);
  }

  @override
  Future<List<OrderEntity>> getLocalOrders() async {
    return _localDataSource.getAllOrders();
  }

  @override
  Future<List<OrderEntity>> getPendingOrders() async {
    return _localDataSource.getPendingOrders();
  }

  @override
  Future<List<String>> syncOrdersToBackend(List<OrderEntity> orders) async {
    final ordersData = orders.map((o) => {
      'localOrderId': o.localOrderId,
      'paymentMode': o.paymentMode,
      'paymentStatus': o.paymentStatus,
      'totalAmount': o.totalAmount,
      'items': o.items.map((i) => i.toJson()).toList(),
    }).toList();

    final result = await _remoteDataSource.syncOrders(ordersData);

    final synced = result['synced'] as List<dynamic>? ?? [];
    final syncedIds = <String>[];

    for (final s in synced) {
      final map = s as Map<String, dynamic>;
      final localOrderId = map['localOrderId'] as String;
      final serverOrderId = map['serverOrderId'] as int?;
      syncedIds.add(localOrderId);

      await _localDataSource.updateSyncStatus(
        localOrderId,
        'SYNCED',
        serverOrderId: serverOrderId,
      );
    }

    return syncedIds;
  }

  @override
  Future<void> updateOrderSyncStatus(String localOrderId, String status, {int? serverOrderId}) async {
    await _localDataSource.updateSyncStatus(localOrderId, status, serverOrderId: serverOrderId);
  }

  @override
  Future<List<OrderEntity>> getRemoteOrders() async {
    final data = await _remoteDataSource.getOrders();
    return data.map((json) => OrderEntity.fromJson(json)).toList();
  }

  @override
  Future<OrderEntity> processPayment({
    required OrderEntity order,
    required String paymentRef,
  }) async {
    final result = await _remoteDataSource.processPayment(
      serverOrderId: order.serverOrderId!,
      amount: order.totalAmount,
      localOrderId: order.localOrderId,
      paymentMode: order.paymentMode,
      paymentRef: paymentRef,
    );

    final paymentStatus = result['status'] as String? ?? 'PENDING';
    final paymentId = result['paymentId'] as int?;
    final ref = result['paymentRef'] as String? ?? paymentRef;

    // Update local DB with payment info
    await _localDataSource.updatePaymentInfo(
      localOrderId: order.localOrderId,
      paymentStatus: paymentStatus,
      paymentRef: ref,
      paymentId: paymentId,
    );

    // Also update sync status to PAID if payment succeeded
    if (paymentStatus == 'SUCCESS') {
      await _localDataSource.updateSyncStatus(order.localOrderId, 'PAID');
    }

    return order.copyWith(
      paymentStatus: paymentStatus,
      paymentRef: ref,
      paymentId: paymentId,
      syncStatus: paymentStatus == 'SUCCESS' ? 'PAID' : order.syncStatus,
    );
  }

  @override
  Future<String> getPaymentStatus(int paymentId) async {
    final result = await _remoteDataSource.getPaymentStatus(paymentId);
    return result['status'] as String? ?? 'PENDING';
  }

  @override
  Future<void> updatePaymentInfo({
    required String localOrderId,
    required String paymentStatus,
    String? paymentRef,
    int? paymentId,
  }) async {
    await _localDataSource.updatePaymentInfo(
      localOrderId: localOrderId,
      paymentStatus: paymentStatus,
      paymentRef: paymentRef,
      paymentId: paymentId,
    );
  }
}
