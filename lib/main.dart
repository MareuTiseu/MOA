import 'package:moa_todo/main.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';

import 'package:moa_todo/model/TodoItem.dart';
import 'package:moa_todo/model/Category.dart';
import 'package:moa_todo/databaseConfig.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


var now_date = DateTime.now();  // 이거 앱 켜두고 12시 지나면 반응 안할듯..
List totalList = ["잘 나오나 확인용",];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // 플러터에서 파이어베이스를 사용하려면 플러터 코어 엔진을 초기화해줘야함.

  await Firebase.initializeApp(  // 플러터에서 파이어베이스를 사용하기 위해 최초로 불러와야 함. 초기화하는 메서드. 비동기 방식으로 작동.
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      home: MyApp()
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  /*
  db를 위한 변수 선언
   */
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  Future<List<TodoItem>> _todoList = DatabaseService()
      .databaseConfig()
      .then((_) => DatabaseService().selectTodoItems());

  // id를 부여하기 위한 currentCount
  int currentCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(  // 상단 상태바 색깔 설정
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark
    ));


    return Scaffold(
      backgroundColor: Color(0xffe6e6e6),
      resizeToAvoidBottomInset : false,  // 키보드 올라올 때 배경까지 밀리지 않도록
      
      body: StackedBody(),

    );
  }

  Widget StackedBody() {
    return Stack(
        children: <Widget>[
          // 종이 질감의 컨텐츠 배경
          Container(
            padding: EdgeInsets.fromLTRB(0, 36, 0, 0),
            decoration: ShapeDecoration(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),  // 위의 padding값과 맞춰주기
                      topRight: Radius.circular(36),)),
                shadows: [
                  BoxShadow(  // Stack으로 쌓았기 때문에 레이어 속이 아니라 아직 맨 밑 바탕. Container를 옮긴 만큼 그림자도 옮겨줘야함
                    color: Color(0x3F000000).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 34),  // padding값 - 2
                    spreadRadius: 1,)]
            ),
            child: const ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),),
              child: Image(
                width: double.infinity,
                height: double.infinity,
                image: AssetImage('assets/paper_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 사실 진짜 container
          Container(
              margin: const EdgeInsets.fromLTRB(12, 64, 12, 0), // 내부 타이틀,컨텐츠 마진 (stack-> 레이어 속이 아니라 화면에서 가장 큰 값)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TopAppbar( date : now_date ),
                  TopAppbar(),
                  Contents(),
                  //BottomAppbar()
                ],
              )),
        ]
    );
  }

  Widget TopAppbar() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),  // 탑바와 네모 테두리 투두 영역을 띄울 거리
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(  // 타이틀과 날짜를 묶어줌
            spacing: 8,
            direction: Axis.vertical,
            children: [
              Image.asset('assets/MOA_title.png', height: 16,),
              Text(
                '${DateFormat('M').format(now_date)}월 ${DateFormat('d').format(now_date)}일 오늘의 To do',
                style: const TextStyle(
                  color: Color(0xFF79747E),
                  fontSize: 16,
                  fontFamily: 'Noto Sans KR',
                  fontWeight: FontWeight.w500,
                  height: 1.50,),),
            ],
          ),

          InkWell(  // 이미지를 버튼으로 쓰기 위해
            onTap: () {
              // 카테고리 추가 //
              print("버튼누름!");
            },
            child: Row(
              children: [
                Image.asset('assets/flower_icon.png', height: 28),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget Contents() {
    return Stack(
      children: [
        // 네모 테두리
        Container(
          child: const Image(
            width: double.infinity,
            image: AssetImage('assets/todo_bg.png'),
            fit: BoxFit.fitWidth,
          ),
        ),

        RealBody(),
      ],
    );
  }

  Widget RealBody() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(

        children: [

          firebase_todoListScreen(),

          addTodo(), // 투두리스트 맨 밑의 입력창 영역

          SizedBox(height: 12,),

          // 카테고리 별로 볼 수 있는 전환 버튼 //
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(  // 이미지를 버튼으로 쓰기 위해
                onTap: () {
                  // 카테고리별로 보는 스크린
                  print("버튼누름!");
                },
                child: Row(
                  children: [
                    Image.asset('assets/switch_off.png', height: 20),
                    SizedBox(width: 4,)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget firebase_todoListScreen() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('todoitems/UzFciEzeJ7FfRdZh4b5k/todoitem').snapshots(),
    builder: (BuildContext context,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {

          /*
          // 파이어베이스에서 데이터를 불러오는 동안 데이터가 없다고 에러가 뜨는걸 처리
          하려고 했는데 투두 상태 바뀔 때마다 깜빡거리며 투두리스트가 흔들거림.. 없앴다..
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
           */

          final docs = snapshot.data!.docs;
          currentCount = docs.length;

          return ListView.builder(
            /*
            아래 두 줄이 빠져서 이틀동안 고생함
            ListView 사용 후 'Vertical viewport was given unbounded height' 에러 뜰 시 확인하기
            */
            scrollDirection: Axis.vertical,
            shrinkWrap: true,

            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              return todoBox(docs[index]);
            },
          );
        }
    );
  }

  Widget todoBox(QueryDocumentSnapshot docs) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 체크박스 아이콘 + 투두 내용
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 체크박스 아이콘
                  InkWell(  // 이미지를 버튼으로 쓰기 위해
                    onTap: () {

                      // status 상태 변경 코드
                      firebase_changingStatus(docs);
                    },
                    child: getCheckboxWidget(docs['status']),

                  ),

                  SizedBox(width: 8,),

                  // todoItem 내용
                  Expanded(

                    child: getTodoTaskWidget(docs),)
                ],
              ),
            ),

            SizedBox(width: 16,),

            // 슬라이더 버튼
            InkWell(  // 이미지를 버튼으로 쓰기 위해
              onTap: () {
                // 카테고리 추가 //
                print("버튼누름!");
              },
              child: Row(
                children: [
                  Image.asset('assets/slicing_texture.png', height: 40),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 4,),  // 리스트간 간격
      ],
    );

  }

  Widget getCheckboxWidget(String status) {
    if (status == 'incomplete') {
      return Image(height: 40, image: AssetImage('assets/check_blank.png'));
    } else if (status == 'inProgress') {
      return Image(height: 40, image: AssetImage('assets/check_half.png'));
    } else if (status == 'completed') {
      return Image(height: 40, image: AssetImage('assets/check_full.png'));
    } else {
      return Text("Status Error");
    }
  }

  void changingStatus(int id) {
    Future<TodoItem> todoItem = _databaseService.selectTodoItem(id);
    todoItem.then((value) {
      if(value.status == 'incomplete') {
        _databaseService.updateTodoItem(TodoItem(
            id: value.id,
            task: value.task,
            status: 'inProgress',
            birthday: value.birthday,
            category: value.category));

        setState(() {
          _todoList = _databaseService.selectTodoItems();
        });

      } else if(value.status == 'inProgress') {
        _databaseService.updateTodoItem(TodoItem(
            id: value.id,
            task: value.task,
            status: 'completed',
            birthday: value.birthday,
            category: value.category));

        setState(() {
          _todoList = _databaseService.selectTodoItems();
        });

      } else if(value.status == 'completed') {
        _databaseService.updateTodoItem(TodoItem(
            id: value.id,
            task: value.task,
            status: 'incomplete',
            birthday: value.birthday,
            category: value.category));

        setState(() {
          _todoList = _databaseService.selectTodoItems();
        });

      }
    }).catchError((onError) {
      print('Status changing error');
    });

  }

  void firebase_changingStatus(QueryDocumentSnapshot docs) {
    if(docs['status'] == 'incomplete') {
      setState(() {
        FirebaseFirestore.instance.collection('todoitems/UzFciEzeJ7FfRdZh4b5k/todoitem').doc(docs.id).update({'status':'inProgress'});
      });

    } else if(docs['status'] == 'inProgress') {
      setState(() {
        FirebaseFirestore.instance.collection('todoitems/UzFciEzeJ7FfRdZh4b5k/todoitem').doc(docs.id).update({'status':'completed'});
      });

    } else if(docs['status'] == 'completed') {
      setState(() {
        FirebaseFirestore.instance.collection('todoitems/UzFciEzeJ7FfRdZh4b5k/todoitem').doc(docs.id).update({'status':'incomplete'});
      });
    } else {
    print('Status changing error');
    }

  }

  Widget getTodoTaskWidget(QueryDocumentSnapshot docs) {
    return GestureDetector(
      onTap: () {
        // Future<TodoItem> todoitem = _databaseService.selectTodoItem(id);
        showDialog(context: this.context, barrierDismissible: false, builder: (BuildContext context) => firebase_updateTodoDialog(docs));
      },
      child: Text(docs['task'],
          overflow: TextOverflow.ellipsis,  // 글자수 넘어가면 ...으로 보여주는 속성
          maxLines: 2,
          style: TextStyle(
            color: docs['status'] == 'incomplete' || docs['status'] == 'inProgress' ? Colors.black : Color(0xff9F99A6),
            fontSize: 16,
            fontFamily: 'Noto Sans KR',
            fontWeight: FontWeight.w400,
            height: 1.50,)),
    );

  }

  Widget addTodo() {
    final _todoTextEditController = TextEditingController();
    FocusNode focusNode = FocusNode();
    var value = "";

    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      _todoTextEditController.dispose();
      super.dispose();
    }

    return RawKeyboardListener(
      // 엔터키를 감지하기 위해 추가한 RawKeyboardListner의 설정
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
            setState(() async {
              value = _todoTextEditController.text;
              _todoTextEditController.clear();

              /*
              로컬 디비에 저장하는 방법
              // db에다 저장하고 싶어용
              _databaseService
                  .insertTodoItem(TodoItem(
                  id: currentCount + 1,
                  task: _todoTextEditController.text,
                  status: 'incomplete',
                  birthday: now_date.toString(),
                  category: '없음'))
                  .then(
                    (result) {
                  if (result) {
                    setState(() {
                      _todoList = _databaseService.selectTodoItems();
                      print(_todoList.toString());
                    });
                  } else {
                    print("insert error");
                  }},
              );
              */

              // 파이어베이스에다 저장할 수 있다!
              await FirebaseFirestore.instance.collection('todoitems/UzFciEzeJ7FfRdZh4b5k/todoitem').doc()
              .set({
                'id': currentCount + 1,
                'task': value,
                'status': 'incomplete',
                'birthday': DateTime.now(),
                'category': '없음'
              });
              _todoTextEditController.clear();


            });
          }
        },

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 체크박스 아이콘 + 투두 내용
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 체크박스 아이콘
                  InkWell(  // 이미지를 버튼으로 쓰기 위해
                    onTap: () {
                      // 카테고리 추가 //
                      print("버튼누름!");
                    },
                    child: Row(
                      children: [
                        Image.asset('assets/check_blank.png', height: 40),
                      ],
                    ),
                  ),

                  SizedBox(width: 8,),

                  // todoItem 내용
                  Expanded(
                    child: TextField(
                      controller: _todoTextEditController,

                      maxLength: 80,
                      maxLines: null,

                      decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                          enabledBorder: OutlineInputBorder( borderSide: BorderSide.none ),
                          hintText: '할 일 추가하기',
                          hintStyle: TextStyle(
                            color: Color(0xff9F99A6),
                            fontSize: 16,
                            fontFamily: 'Noto Sans KR',
                            fontWeight: FontWeight.w400,
                            height: 1.50,)),
                    ),
                  ),
                ],
              ),
            ),

            // 슬라이더 버튼 자리
            SizedBox(width: 52,)
          ],
        )
    );


  }

  Widget updateTodoDialog(Future<TodoItem> todoitem) {
    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: const Text("투두 수정")),
          IconButton(
              onPressed: () {
                Navigator.of(this.context).pop();
                showDialog(context: this.context, builder: (context) => deleteTodoDialog(todoitem));
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () => Navigator.of(this.context).pop(),
              icon: const Icon(Icons.close))
        ],
      ),
      content: FutureBuilder(
        future: todoitem,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _taskController.text = snapshot.data!.task;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("투두 생성일시 : " + snapshot.data!.birthday.split('.')[0],
                textAlign: TextAlign.right,),
                const SizedBox(height: 16,),

                TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(hintText: "투두를 수정하세요"),
                ),
                const SizedBox(height: 16,),

                Text("목표 카테고리 : " + snapshot.data!.category,),
                const SizedBox(height: 16,),
                
                ElevatedButton(
                    onPressed: () {
                      _databaseService
                      .updateTodoItem(TodoItem(
                          id: snapshot.data!.id,
                          task: _taskController.text,
                          status: snapshot.data!.status,
                          birthday: snapshot.data!.birthday,
                          category: snapshot.data!.category))
                          .then(
                          (result) {
                            if (result) {
                              Navigator.of(context).pop();
                              setState(() {
                                _todoList = _databaseService.selectTodoItems();
                              });
                            } else {
                              print("update error");
                            }
                          },
                      );
                    }, child: const Text("수정")),


              ],
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error occurred!"),
            );
          } else {
            return const Center (
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }
        },
      ),
    );
  }

  Widget firebase_updateTodoDialog(QueryDocumentSnapshot docs) {
    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: const Text("투두 수정")),
          IconButton(
              onPressed: () {
                Navigator.of(this.context).pop();
                showDialog(context: this.context,
                    builder: (context) => firebase_deleteTodoDialog(docs));
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () => Navigator.of(this.context).pop(),
              icon: const Icon(Icons.close))
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("투두 생성일시 : " + docs['birthday'].toString(),
            textAlign: TextAlign.right,),
          const SizedBox(height: 16,),

          TextField(
            controller: _taskController,
            decoration: const InputDecoration(hintText: "투두를 수정하세요"),
          ),
          const SizedBox(height: 16,),

          Text("목표 카테고리 : " + docs['category'],),
          const SizedBox(height: 16,),

          ElevatedButton(
              onPressed: () {
                docs['task'].update(_taskController);
              },
              child: const Text("수정")
          ),
        ],
      ),
    );
  }

  Widget deleteTodoDialog(Future<TodoItem> todoitem) {
    return AlertDialog(
      title: const Text("투두를 삭제하시겠습니까?"),
      content: FutureBuilder(
        future: todoitem,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _taskController.text = snapshot.data!.task;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _databaseService
                        .deleteTodoItem(snapshot.data!.id).then(
                          (result) {
                        if (result) {
                          Navigator.of(context).pop();
                          setState(() {
                            _todoList = _databaseService.selectTodoItems();
                          });
                        } else {
                          print("delete error");
                        }
                      },
                    );
                  }, child: const Text("예"),
                ),
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("아니오")),
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error occurred!"),
            );
          } else {
            return const Center (
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }
        },
      ),
    );
  }

  Widget firebase_deleteTodoDialog(QueryDocumentSnapshot docs) {
    return AlertDialog(
      title: const Text("투두를 삭제하시겠습니까?"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('todoitems/UzFciEzeJ7FfRdZh4b5k/todoitem').doc(docs.id).delete();
              Navigator.pop(this.context);
            }, child: const Text("예"),
          ),
          ElevatedButton(
              onPressed: () => Navigator.pop(this.context),
              child: const Text("아니오")),
        ],
      )
    );
  }

}
