import '../models/goal.dart';
import '../services/database_service.dart';

class GoalDao {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<int> insertGoal(Goal goal) async {
    final db = await _databaseService.database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getAllGoals() async {
    final db = await _databaseService.database;
    final result = await db.query('goals', orderBy: 'deadline ASC');
    return result.map((map) => Goal.fromMap(map)).toList();
  }

  Future<int> deleteGoal(int id) async {
    final db = await _databaseService.database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await _databaseService.database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }
}