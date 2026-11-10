import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'tahu_crispy_pos.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sales(
            id TEXT PRIMARY KEY,
            cart_id TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            unit_price INTEGER NOT NULL,
            total INTEGER NOT NULL,
            payment_method TEXT NOT NULL,
            created_at TEXT NOT NULL,
            sync_status TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE expenses(
            id TEXT PRIMARY KEY,
            cart_id TEXT NOT NULL,
            amount INTEGER NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            created_at TEXT NOT NULL,
            sync_status TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> insertSale(Map<String, Object?> sale) async {
    final db = await database;
    await db.insert('sales', sale, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Map<String, Object?>>> getSales({String? cartId}) async {
    final db = await database;
    if (cartId == null) {
      return db.query('sales', orderBy: 'created_at DESC');
    }
    return db.query('sales', where: 'cart_id = ?', whereArgs: [cartId], orderBy: 'created_at DESC');
  }

  Future<Map<String, int>> dailySummary({String? cartId}) async {
    final db = await database;
    final start = DateTime.now();
    final dayStart = DateTime(start.year, start.month, start.day).toIso8601String();
    final where = cartId == null
        ? 'created_at >= ?'
        : 'created_at >= ? AND cart_id = ?';
    final args = cartId == null ? [dayStart] : [dayStart, cartId];
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(total),0) AS revenue, COUNT(*) AS count, '
      'COALESCE(SUM(CASE WHEN payment_method = \'Tunai\' THEN total ELSE 0 END),0) AS cash, '
      'COALESCE(SUM(CASE WHEN payment_method = \'QRIS\' THEN total ELSE 0 END),0) AS qris '
      'FROM sales WHERE $where',
      args,
    );
    final row = rows.first;
    return {
      'revenue': (row['revenue'] as num).toInt(),
      'count': (row['count'] as num).toInt(),
      'cash': (row['cash'] as num).toInt(),
      'qris': (row['qris'] as num).toInt(),
    };
  }
}
