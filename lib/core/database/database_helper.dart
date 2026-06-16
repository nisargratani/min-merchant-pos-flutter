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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_orders (
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
      CREATE TABLE offline_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        localOrderId TEXT NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT,
        qty INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (localOrderId) REFERENCES offline_orders (localOrderId) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add payment simulation columns
      await db.execute('ALTER TABLE offline_orders ADD COLUMN paymentRef TEXT');
      await db.execute('ALTER TABLE offline_orders ADD COLUMN paymentId INTEGER');
    }
  }
}

/// Provider for DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});
