import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Manages the local SQLite database for offline order storage.
class DatabaseHelper {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mini_merchant_pos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        // Fallback to ensure tables exist since we are keeping version at 1
        await _onCreate(db, 1);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS offline_orders (
        localOrderId TEXT PRIMARY KEY,
        serverOrderId INTEGER,
        paymentStatus TEXT NOT NULL,
        paymentMode TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'PENDING',
        createdAt INTEGER NOT NULL,
        paymentRef TEXT,
        paymentId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS offline_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        localOrderId TEXT NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT,
        qty INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (localOrderId) REFERENCES offline_orders (localOrderId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cart_items (
        productId INTEGER PRIMARY KEY,
        qty INTEGER NOT NULL
      )
    ''');
  }
}

/// Provider for DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});
