import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
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
  Future<Either<Failure, void>> saveOrderLocally(OrderEntity order) async {
    try {
      await _localDataSource.insertOrder(order);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getLocalOrders() async {
    try {
      final orders = await _localDataSource.getAllOrders();
      return Right(orders);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getPendingOrders() async {
    try {
      final orders = await _localDataSource.getPendingOrders();
      return Right(orders);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> syncOrdersToBackend(List<OrderEntity> orders) async {
    try {
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

      return Right(syncedIds);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderSyncStatus(String localOrderId, String status, {int? serverOrderId}) async {
    try {
      await _localDataSource.updateSyncStatus(localOrderId, status, serverOrderId: serverOrderId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getRemoteOrders() async {
    try {
      final data = await _remoteDataSource.getOrders();
      final orders = data.map((json) => OrderEntity.fromJson(json)).toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> processPayment({
    required OrderEntity order,
    required String paymentRef,
  }) async {
    try {
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

      return Right(order.copyWith(
        paymentStatus: paymentStatus,
        paymentRef: ref,
        paymentId: paymentId,
        syncStatus: paymentStatus == 'SUCCESS' ? 'PAID' : order.syncStatus,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getPaymentStatus(int paymentId) async {
    try {
      final result = await _remoteDataSource.getPaymentStatus(paymentId);
      return Right(result['status'] as String? ?? 'PENDING');
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePaymentInfo({
    required String localOrderId,
    required String paymentStatus,
    String? paymentRef,
    int? paymentId,
  }) async {
    try {
      await _localDataSource.updatePaymentInfo(
        localOrderId: localOrderId,
        paymentStatus: paymentStatus,
        paymentRef: paymentRef,
        paymentId: paymentId,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
