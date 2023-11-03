import 'package:sqflite/sqflite.dart';

class DataBase {
  // 데이터 베이스를 담아두기 위한 변수 (값이 있으면 중복 호출하지 않음)
  var _fixed_database;

  // 데이터베이스 값 반환하기
Future<DataBase> get fixed_database async {
  // 데이터 베이스가 있으면 중복호출 하지 않기 위해 변수에 있는 데이터베이스를 그대로 반환
  if (_fixed_database != null) return _fixed_database;

  // openDatabase 메서드를 호출해 데이터베이스를 open
  _fixed_database = openDatabase(
    join(await getDatabasesPath(), 'fixed_database.db'),  // 경로 지정
    onCreate: (db, version) => createTable(db),  // 인자에 생성한 db를 넣어주어 테이블 생성
    version: 1,  // 데이터베이스의 업그레이드와 다운그레이드를 함으로써 수정하기 위한 경로 제공
  );
  return _fixed_database;
}

// 테이블 만들기
void createTable(DataBase db) {
  // 거주지역
  db.execute(
    'CREATE TABLE taskName_todos (id INTEGER PRIMARY KEY, value TEXT)',
    // 아래처럼 이어서 여러 개의 테이블을 한번에 만들어도 됨
    // 'create TABLE' '테이블명' (컬럼명1 INTEER PRIMARY KEY, 컬럼명2 타입, 컬럼명3 타입)''
  );
}
}