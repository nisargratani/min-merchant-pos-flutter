import '../../../../core/database/database_helper.dart';
import '../../domain/entities/cart_item.dart';

/// Local data source for offline cart storage.
class CartLocalDataSource {
  final DatabaseHelper _dbHelper;

  CartLocalDataSource(this._dbHelper);

  /// Retrieves the current local cart by joining cart_items and products.
  Future<Cart> getCart() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.productId, p.name, p.price, c.qty
      FROM cart_items c
      LEFT JOIN products p ON c.productId = p.id
    ''');

    final items = maps.map((map) {
      return CartItem(
        productId: map['productId'] as int,
        name: map['name'] as String? ?? 'Unknown Product',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        qty: map['qty'] as int,
      );
    }).toList();

    final totalAmount = items.fold(0.0, (sum, item) => sum + item.total);

    return Cart(items: items, totalAmount: totalAmount);
  }

  /// Sets the entire local cart (used for syncing).
  Future<void> saveCart(Cart cart) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('cart_items');
      for (final item in cart.items) {
        await txn.insert('cart_items', {
          'productId': item.productId,
          'qty': item.qty,
          // name and price are not stored here anymore, they are joined
        });
      }
    });
  }

  /// Adjusts quantity for an item locally.
  Future<void> addToCart(int productId, int deltaQty) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'cart_items',
      where: 'productId = ?',
      whereArgs: [productId],
    );

    if (existing.isEmpty) {
      if (deltaQty > 0) {
        await db.insert('cart_items', {
          'productId': productId,
          'qty': deltaQty,
        });
      }
    } else {
      final currentQty = existing.first['qty'] as int;
      final newQty = currentQty + deltaQty;
      
      if (newQty <= 0) {
        await removeFromCart(productId);
      } else {
        await db.update(
          'cart_items',
          {'qty': newQty},
          where: 'productId = ?',
          whereArgs: [productId],
        );
      }
    }
  }

  /// Removes an item from the local cart.
  Future<void> removeFromCart(int productId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'cart_items',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  /// Clears the local cart.
  Future<void> clearCart() async {
    final db = await _dbHelper.database;
    await db.delete('cart_items');
  }
}
