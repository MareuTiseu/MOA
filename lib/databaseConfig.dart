import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:moa_todo/model/TodoItem.dart';
// import 'package:moa_todo/model/Category.dart';

import 'package:sqflite/sqflite.dart';

// // 내가 밖으로 빼버림
// late Future<Database> database;

/*
_internal을 통해 private 생성자를 구현,
databaseConfig 메소드를 통해 db 변수를 초기화해준다.
 */
class DatabaseService {
  static final DatabaseService _database = DatabaseService._internal();
  late Future<Database> database;

  factory DatabaseService() => _database;

  DatabaseService._internal() {
    databaseConfig();
  }


  Future<bool> databaseConfig() async {
    try {
      database = openDatabase(
        join(await getDatabasesPath(), 'MOA_database.db'),
        onCreate: (db, version) {
          db.execute(
            // 테이블 생성, id를 Primary Key로 지저한다(고유식별값, 중복X)
            'CREATE TABLE todoitems(id INTEGER PRIMARY KEY, task TEXT, status TEXT, birthday TEXT, category TEXT)',
          );
          db.execute(  // 목표 카테고리 저장할 테이블 생성
            'CREATE TABLE categories(categoryName TEXT PRIMARY KEY, todoIdList TEXT)',
          );
        },
        version: 1,
      );
      return true;
    } catch (err) {
      print(err.toString());
      return false;
    }
  }


/*
데이터 삽입을 위한 insert 메소드.
parameter로 테이블 이름, 테이블에 삽입할 데이터를 map 형태로 변환해 넣어줌.
 */
  Future<bool> insertTodoItem(TodoItem todoItem) async {
    final Database db = await database;
    try {
      db.insert(
        'todoitems',
        todoItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (err) {
      return false;
    }
  }
  // Future<bool> insertCategory(Category category) async {
  //   final Database db = await database;
  //   try {
  //     db.insert(
  //       'categories',
  //       category.toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //     return true;
  //   } catch (err) {
  //     return false;
  //   }
  // }


/*
모든 투두를 가져오기 위한 select 메소드.
모든 투두를 가져오는 selectTodoItems와 1개의 투두를 가져오는 selectTodoItem을 분리한다.
 */

  Future<List<TodoItem>> selectTodoItems() async {
    final Database db = await database;
    final List<Map<String, dynamic>> data = await db.query('todoitems');

    return List.generate(data.length, (i) {
      return TodoItem(
          id: data[i]['id'],
          task: data[i]['task'],
          status: data[i]['status'],
          birthday: data[i]['birthday'],
          category: data[i]['category']);
    });
  }

  Future<TodoItem> selectTodoItem(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> data =
    // where로 어떤 데이터를 가져올건지 조건 추가
    // ? 부분을 whereArgs로 지정
    await db.query('todoitems', where: "id = ?", whereArgs: [id]);
    return TodoItem(
        id: data[0]['id'],
        task: data[0]['task'],
        status: data[0]['status'],
        birthday: data[0]['birthday'],
        category: data[0]['category']);
  }


/*
투두 수정을 위한 update 메소드
 */
  Future<bool> updateTodoItem(TodoItem todoItem) async {
    final Database db = await database;
    try {
      db.update(
        'todoitems',
        todoItem.toMap(),
        where: "id = ?",
        whereArgs: [todoItem.id],
      );
      return true;
    } catch (err) {
      return false;
    }
  }


/*
투두 삭제를 위한 delete 메소드
 */
  Future<bool> deleteTodoItem(int id) async {
    final Database db = await database;
    try {
      db.delete(
        'todoitems',
        where: "id = ?",
        whereArgs: [id],
      );
      return true;
    } catch (err) {
      return false;
    }
  }


/*
투두 카테고리 변경을 위한 move 메소드 => 수정 필요
 */
// Future<bool> moveTodoItem(TodoItem todoItem) async {
//   final Database db = await database;
//   try {
//     db.update(
//       'todoitems',
//       todoItem.toMap(),
//       where: "id = ?",
//       whereArgs: [todoItem.id],
//     );
//     return true;
//   } catch(err) {
//     return false;
//   }
// }
}