import '../models/transaction.dart';
import '../services/database_service.dart';

class TransactionDao {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await _databaseService.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await _databaseService.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByType(String type) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<double> getTotalByType(String type) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [type],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions WHERE type = ? GROUP BY category',
      ['expense'],
    );
    
    Map<String, double> expenses = {};
    for (var row in result) {
      expenses[row['category'] as String] = row['total'] as double;
    }
    return expenses;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await _databaseService.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await _databaseService.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
}