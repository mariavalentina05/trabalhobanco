import "package:trabalhobanco/database/db.dart";
import "package:trabalhobanco/model/dogmodel.dart";
import "package:sqflite/sqflite.dart";




Future<int> insertDog(Dog dog) async{
  Database db = await getDatabase();//o await faz com que a código embaixo so seja executado se getdatabase der certo
  return db.insert(
  'dogs',
  dog.toMap(),
  conflictAlgorithm: ConflictAlgorithm.replace
  );
}

Future<List<Map>> findAll() async {
  final Database db = await getDatabase();
  return db.query('dogs');
}

Future <int> deleteById(int id) async {
  final Database db = await getDatabase();
  return db.delete('dogs', where:'id = ?', whereArgs: [id]);
}