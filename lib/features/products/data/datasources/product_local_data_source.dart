import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/product.dart';

abstract class ProductLocalDataSource {
  Future<List<Product>> getProducts();
  Future<void> cacheProducts(List<Product> products);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ProductLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<Product>> getProducts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return maps.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      // Clear existing products to ensure local matches remote exactly
      await txn.delete('products');
      
      // Insert new products
      for (var product in products) {
        await txn.insert(
          'products',
          product.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
