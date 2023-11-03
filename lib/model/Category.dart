import 'package:moa_todo/model/TodoItem.dart';

// 카테고리 클래스
class Category {
  // 멤버변수
  String categoryName;
  String todoIdList;


  // 생성자로 값을 받고 바로 멤버변수에 넣어줌
  Category({
    required this.categoryName,
    required this.todoIdList
  });

  // 내부 db용 (sqlite)
  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      'categoryName' : categoryName,
      'todoIDList' : todoIdList
    };
  }
}