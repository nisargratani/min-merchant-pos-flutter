import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/order_entity.dart';

/// Local data source for offline order storage via SQLite.
class OrderLocalDataSource {
  final DatabaseHelper _dbHelper;

  OrderLocalDataSource(this._dbHelper);

  /// Insert an order and its items into SQLite.
  Future<void> insertOrder(OrderEntity order) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert(
        'offline_orders',
        {
          'localOrderId': order.localOrderId,
          'serverOrderId': order.serverOrderId,
          'paymentStatus': order.paymentStatus,
          'paymentMode': order.paymentMode,
          'totalAmount': order.totalAmount,
          'syncStatus': order.syncStatus,
          'createdAt': order.createdAt,
          'paymentRef': order.paymentRef,
          'paymentId': order.paymentId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final item in order.items) {
        await txn.insert('offline_order_items', {
          'localOrderId': order.localOrderId,
          'productId': item.productId,
          'productName': item.productName,
          'qty': item.qty,
          'price': item.price,
        });
      }
    });
  }

  /// Helper to build an OrderEntity from a DB row map + items.
  OrderEntity _orderFromMap(Map<String, dynamic> map, List<OrderItem> items) {
    return OrderEntity(
      localOrderId: map['localOrderId'] as String,
      serverOrderId: map['serverOrderId'] as int?,
      paymentStatus: map['paymentStatus'] as String,
      paymentMode: map['paymentMode'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      syncStatus: map['syncStatus'] as String,
      items: items,
      createdAt: map['createdAt'] as int,
      paymentRef: map['paymentRef'] as String?,
      paymentId: map['paymentId'] as int?,
    );
  }

  /// Helper to fetch items for a given localOrderId.
  Future<List<OrderItem>> _getItemsForOrder(Database db, String localOrderId) async {
    final itemMaps = await db.query(
      'offline_order_items',
      where: 'localOrderId = ?',
      whereArgs: [localOrderId],
    );
    return itemMaps
        .map((m) => OrderItem(
              productId: m['productId'] as int,
              productName: m['productName'] as String?,
              qty: m['qty'] as int,
              price: (m['price'] as num).toDouble(),
            ))
        .toList();
  }

  /// Get all orders from local DB, including their items.
  Future<List<OrderEntity>> getAllOrders() async {
    final db = await _dbHelper.database;
    final orderMaps = await db.query('offline_orders', orderBy: 'createdAt DESC');

    final List<OrderEntity> orders = [];
    for (final map in orderMaps) {
      final items = await _getItemsForOrder(db, map['localOrderId'] as String);
      orders.add(_orderFromMap(map, items));
    }
    return orders;
  }

  /// Get only PENDING/FAILED orders (not yet synced).
  Future<List<OrderEntity>> getPendingOrders() async {
    final db = await _dbHelper.database;
    final orderMaps = await db.query(
      'offline_orders',
      where: 'syncStatus = ? OR syncStatus = ?',
      whereArgs: ['PENDING', 'FAILED'],
    );

    final List<OrderEntity> orders = [];
    for (final map in orderMaps) {
      final items = await _getItemsForOrder(db, map['localOrderId'] as String);
      orders.add(_orderFromMap(map, items));
    }
    return orders;
  }

  /// Update the sync status of a local order.
  Future<void> updateSyncStatus(String localOrderId, String status, {int? serverOrderId}) async {
    final db = await _dbHelper.database;
    final values = <String, dynamic>{'syncStatus': status};
    if (serverOrderId != null) {
      values['serverOrderId'] = serverOrderId;
    }
    await db.update(
      'offline_orders',
      values,
      where: 'localOrderId = ?',
      whereArgs: [localOrderId],
    );
  }

  /// Update payment info for an order after payment simulation.
  Future<void> updatePaymentInfo({
    required String localOrderId,
    required String paymentStatus,
    String? paymentRef,
    int? paymentId,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      'offline_orders',
      // ignore: use_null_aware_elements
      {
        'paymentStatus': paymentStatus,
        if (paymentRef != null) 'paymentRef': paymentRef, // ignore: use_null_aware_elements
        if (paymentId != null) 'paymentId': paymentId, // ignore: use_null_aware_elements
      },
      where: 'localOrderId = ?',
      whereArgs: [localOrderId],
    );
  }
}
