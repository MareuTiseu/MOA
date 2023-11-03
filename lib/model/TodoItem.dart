import 'package:moa_todo/model/Category.dart';

// db 저장이 안되는 것 같아 status enum은 폐기.. 스트링으로 사용할 것..!
// enum TodoStatus {
//   incomplete,
//   inProgress,
//   completed,
// }

// 투두 클래스
class TodoItem {
  // 멤버변수
  int id;
  String task;
  // TodoStatus status;
  String status;
  String birthday;
  String category;

  // 생성자로 값을 받고 바로 멤버변수에 넣어줌
  TodoItem({
    required this.id,
    required this.task,
    required this.status,
    required this.birthday,
    required this.category,
  });

  // 내부 db용 (sqlite)
  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      'id' : id,
      'task' : task,
      'status' : status,
      'birthday' : birthday,
      'category' : category
    };
  }
}