import 'package:flutter/material.dart';
import 'package:handa/pages/settings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:handa/database/database_helper.dart';
import 'package:handa/models/todo.dart';
import 'package:handa/pages/search.dart';

class Todos extends StatefulWidget {
  const Todos({super.key});

  @override
  State<Todos> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  final Map<DateTime, TextEditingController> _textControllers =
      {}; // 요일별 TextEditingController
  final ScrollController _scrollController = ScrollController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Todo> _todos = [];
  OverlayEntry? _calendarOverlay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadTodos();
  }

  @override
  void dispose() {
    // 모든 TextEditingController를 정리
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _scrollController.dispose(); // ScrollController 정리
    super.dispose();
  }

  void _scrollToToday() {
    final weekDays = _getWeekDays(_focusedDay);
    final todayIndex =
        weekDays.indexWhere((day) => isSameDay(day, DateTime.now()));

    if (todayIndex != -1) {
      // 오늘 날짜의 위치가 존재하면 스크롤
      _scrollController.animateTo(
        todayIndex * 120.0, // 카드의 높이에 맞춰 스크롤 위치 계산 (예: 카드 높이 120)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  TextEditingController _getControllerForDay(DateTime day) {
    if (!_textControllers.containsKey(day)) {
      _textControllers[day] = TextEditingController();
    }
    return _textControllers[day]!;
  }

  Future<void> _loadTodos() async {
    final todos = await DatabaseHelper.instance.getTodos();
    setState(() {
      _todos = todos;
    });
  }

  Future<void> _addTodoForDay(DateTime day) async {
    final controller = _getControllerForDay(day);
    if (controller.text.trim().isEmpty) return;

    final newTodo = Todo(
      title: controller.text,
      description: '',
      createdAt: day,
      color: 'blue',
      tag: 'default',
    );

    await DatabaseHelper.instance.insertTodo(newTodo);
    controller.clear();
    await _loadTodos();
  }

  Future<void> _editTodo(Todo todo) async {
    TextEditingController titleController =
        TextEditingController(text: todo.title);
    TextEditingController descriptionController =
        TextEditingController(text: todo.description);
    DateTime selectedDate = todo.createdAt;
    String selectedColor = todo.color;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); // 키보드 닫기 및 포커싱 해제
              },
              child: AlertDialog(
                contentPadding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                titlePadding: EdgeInsets.zero,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.today),
                          onPressed: () {},
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              contentPadding: EdgeInsets.all(10),
                              content: const Text(
                                  '정말로 이 할 일을 삭제하시겠습니까? \n 되돌릴 수 없습니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('취소'),
                                  style: TextButton.styleFrom(
                                      textStyle: TextStyle(fontSize: 12)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('삭제',
                                      style: TextStyle(color: Colors.red)),
                                  style: TextButton.styleFrom(
                                      textStyle: TextStyle(fontSize: 12)),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          await DatabaseHelper.instance.deleteTodo(todo.id!);
                          await _loadTodos();
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(hintText: '제목'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(hintText: '내용'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(20, 20),
                          minimumSize: Size.zero,
                          shape: const CircleBorder(),
                          backgroundColor:
                              _getColorFromName(selectedColor), // 현재 색상 표시
                        ),
                        onPressed: () async {
                          final selected = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Wrap(
                                  spacing: 4,
                                  children: [
                                    'red',
                                    'orange',
                                    'yellow',
                                    'green',
                                    'blue'
                                  ]
                                      .map((color) => GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop(color);
                                            },
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: _getColorFromName(color),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              );
                            },
                          );
                          if (selected != null) {
                            setState(() {
                              selectedColor = selected;
                            });
                          }
                        },
                        child: const Text(''),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('취소'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final updatedTodo = Todo(
                                id: todo.id,
                                title: titleController.text,
                                description: descriptionController.text,
                                createdAt: selectedDate,
                                color: selectedColor,
                                tag: todo.tag,
                              );
                              await DatabaseHelper.instance
                                  .updateTodo(updatedTodo);
                              await _loadTodos();
                              Navigator.of(context).pop();
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  List<Todo> _getTodosForDay(DateTime day) {
    return _todos.where((todo) {
      return isSameDay(todo.createdAt, day);
    }).toList();
  }

  /// 현재 페이지에서 표현할 연도를 반환
  String _getYearToDisplay() {
    final mondayOfWeek = _getWeekDays(_focusedDay).first;
    final today = DateTime.now();

    // 현재 페이지가 이번 주인지 확인
    final isCurrentWeek = _getWeekDays(today).first == mondayOfWeek;

    if (isCurrentWeek && today.month == 1 && mondayOfWeek.year != today.year) {
      // 오늘이 새해 첫날이고 이번 주가 연도를 넘어가는 경우
      return '${today.year}년';
    } else {
      // 일반적인 경우
      return '${mondayOfWeek.year}년';
    }
  }

  List<DateTime> _getWeekDays(DateTime focusedDay) {
    final int weekDay = focusedDay.weekday;
    final DateTime monday = focusedDay.subtract(Duration(days: weekDay - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void _toggleCalendarPopup(BuildContext context) {
    if (_calendarOverlay != null) {
      _calendarOverlay!.remove();
      _calendarOverlay = null;
    } else {
      final overlay = Overlay.of(context);
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero);

      final weekDays = _getWeekDays(_focusedDay); // 현재 주의 요일들 가져오기
      final DateTime rangeStart = weekDays.first; // 현재 주의 시작일
      final DateTime rangeEnd = weekDays.last; // 현재 주의 종료일

      _calendarOverlay = OverlayEntry(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              _calendarOverlay!.remove();
              _calendarOverlay = null;
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Positioned(
                  top: offset.dy + 66,
                  left: 16,
                  child: Material(
                    elevation: 4,
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.all(4),
                      color: Colors.white,
                      child: TableCalendar(
                        locale: 'ko_KR',
                        headerStyle: HeaderStyle(
                          headerPadding: EdgeInsets.all(2),
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          rangeHighlightScale: 1,
                          rangeHighlightColor: Colors.blue,
                          withinRangeTextStyle: TextStyle(color: Colors.white),
                          rangeStartDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          rangeStartTextStyle:
                              TextStyle(fontSize: 14, color: Colors.white),
                          rangeEndDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          rangeEndTextStyle:
                              TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        rangeStartDay: rangeStart,
                        // 범위의 시작일 설정
                        rangeEndDay: rangeEnd,
                        // 범위의 종료일 설정

                        focusedDay: _focusedDay,
                        firstDay: DateTime(2000),
                        lastDay: DateTime(2100),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          _toggleCalendarPopup(context); // 캘린더 닫기
                        },
                        calendarFormat: CalendarFormat.month,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
      overlay.insert(_calendarOverlay!);
    }
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 100),
      reverseTransitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) => Search(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // 오른쪽에서 시작
        const end = Offset.zero; // 화면 중앙에 정착
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  void _showDraggableTodoDetails(Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45, // 초기 높이 30%
          minChildSize: 0.45, // 최소 높이 30%
          maxChildSize: 1.0, // 최대 높이 100%
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 드래그 표시
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // 제목
                      TextField(
                        controller: TextEditingController(text: todo.title),
                        decoration: InputDecoration(
                          labelText: '제목',
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 16),
                      // 내용
                      TextField(
                        controller:
                            TextEditingController(text: todo.description),
                        decoration: InputDecoration(
                          labelText: '내용',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 10,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 16),
                      // 저장 버튼
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.save),
                          label: Text("저장"),
                          onPressed: () async {
                            // 저장 로직
                            todo.title = TextEditingController().text;
                            todo.description = TextEditingController().text;
                            await DatabaseHelper.instance.updateTodo(todo);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(_focusedDay);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 외부 클릭 시 포커스 해제
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          title: TextButton(
            onPressed: () {
              _toggleCalendarPopup(context);
            },
            child: Text(
              _getYearToDisplay(),
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(4),
              foregroundColor: Colors.white,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Settings(),
                    ),
                  );
                },
                icon: Icon(Icons.account_circle_outlined)),
            IconButton(
              visualDensity: VisualDensity(horizontal: -2, vertical: 0),
              onPressed: () {
                setState(() {
                  _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                });
              },
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
            IconButton(
              visualDensity: VisualDensity(horizontal: -2, vertical: 0),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime.now();
                });
                _scrollToToday();
              },
              icon: const Icon(Icons.radio_button_checked),
            ),
            IconButton(
              visualDensity: VisualDensity(horizontal: -2, vertical: 0),
              onPressed: () {
                setState(() {
                  _focusedDay = _focusedDay.add(const Duration(days: 7));
                });
              },
              icon: const Icon(Icons.arrow_forward_ios),
            ),
            IconButton(
              visualDensity: VisualDensity(horizontal: -2, vertical: 0),
              onPressed: () {
                Navigator.of(context).push(_createRoute());
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // ScrollController 연결
                itemCount: weekDays.length,
                itemBuilder: (context, index) {
                  final day = weekDays[index];
                  final todos = _getTodosForDay(day);
                  final dayLabel = DateFormat('E', 'ko_KR').format(day);
                  final dateLabel = DateFormat('MM월 dd일').format(day);
                  final controller = _getControllerForDay(day);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$dateLabel',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$dayLabel',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          todos.isEmpty
                              ? Container()
                              : Column(
                                  children: todos.map(
                                    (todo) {
                                      return GestureDetector(
                                        onTap: () {
                                          _showDraggableTodoDetails(todo);
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  decoration: BoxDecoration(
                                                    color: todo.isCompleted
                                                        ? Colors
                                                            .grey // 완료 상태일 때 회색
                                                        : _getColorFromName(todo
                                                            .color), // 기본 색상
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
                                                    todo.title,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        decoration: todo
                                                                .isCompleted
                                                            ? TextDecoration
                                                                .lineThrough // 완료 상태일 때 취소선
                                                            : TextDecoration
                                                                .none,
                                                        decorationColor: todo
                                                                .isCompleted
                                                            ? Colors.grey[600]
                                                            : null),
                                                  ),
                                                ),
                                                Checkbox(
                                                  value: todo.isCompleted,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      todo.isCompleted = value!;
                                                    });
                                                  },
                                                  shape: CircleBorder(),
                                                  activeColor: Colors.grey,
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey,
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                      hintText: '할 일 추가하기',
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey)),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 4)),
                                  style: TextStyle(fontSize: 14),
                                  onSubmitted: (value) async {
                                    if (value.trim().isNotEmpty) {
                                      await _addTodoForDay(
                                          day); // Enter 키 입력 시 할 일 추가
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditPage extends StatelessWidget {
  final Todo todo;

  const NoteEditPage({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController =
        TextEditingController(text: todo.title);
    TextEditingController descriptionController =
        TextEditingController(text: todo.description);

    return Scaffold(
      appBar: AppBar(
        title: const Text("노트 편집"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // 저장 동작 추가
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: '내용'),
              maxLines: 10,
            ),
          ],
        ),
      ),
    );
  }
}
