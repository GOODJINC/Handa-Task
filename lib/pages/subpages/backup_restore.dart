import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:handa/database/database_helper.dart';
import 'package:handa/models/todo.dart';

class BackupRestorePage extends StatelessWidget {
  const BackupRestorePage({super.key});

  // JSON으로 내보내기
  Future<void> _exportToJson(BuildContext context) async {
    try {
      // 모든 todos 가져오기
      final todos = await DatabaseHelper.instance.getTodos();

      // JSON 문자열로 변환
      final jsonData = json.encode(todos.map((todo) => todo.toMap()).toList());

      // 문서 디렉토리 가져오기
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'todos_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      // 파일 저장
      await file.writeAsString(jsonData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('JSON 파일이 저장되었습니다: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내보내기 실패: $e')),
      );
    }
  }

  // JSON에서 가져오기
  Future<void> _importFromJson(BuildContext context) async {
    try {
      // 파일 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final List<dynamic> jsonData = json.decode(jsonString);

        // 기존 데이터 삭제
        await DatabaseHelper.instance.deleteAllTodos();

        // 새 데이터 추가
        for (var todoMap in jsonData) {
          await DatabaseHelper.instance.insertTodo(Todo.fromMap(todoMap));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('JSON 파일에서 데이터를 가져왔습니다.')),
        );

        // 이전 화면으로 돌아가면서 데이터가 변경되었음을 알림
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가져오기 실패: $e')),
      );
    }
  }

  // CSV로 내보내기
  Future<void> _exportToCsv(BuildContext context) async {
    try {
      final todos = await DatabaseHelper.instance.getTodos();

      // CSV 데이터 생성
      List<List<dynamic>> csvData = [
        ['제목', '내용', '완료여부', '생성일', '수정일', '색상', '태그'], // 헤더
        ...todos.map((todo) => [
              todo.title,
              todo.description,
              todo.isCompleted ? '완료' : '미완료',
              todo.createdAt.toIso8601String(),
              todo.lastModified.toIso8601String(),
              todo.color,
              todo.tag ?? '',
            ]),
      ];

      String csv = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'todos_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV 파일이 저장되었습니다: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내보내기 실패: $e')),
      );
    }
  }

  // CSV에서 가져오기
  Future<void> _importFromCsv(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final csvString = await file.readAsString();
        final List<List<dynamic>> csvData =
            const CsvToListConverter().convert(csvString);

        // 헤더 제거
        csvData.removeAt(0);

        // 기존 데이터 삭제
        await DatabaseHelper.instance.deleteAllTodos();

        // 새 데이터 추가
        for (var row in csvData) {
          final todo = Todo(
            title: row[0].toString(),
            description: row[1].toString(),
            isCompleted: row[2] == '완료',
            createdAt: DateTime.parse(row[3]),
            lastModified: DateTime.parse(row[4]),
            color: row[5].toString(),
            tag: row[6].toString().isEmpty ? null : row[6].toString(),
          );
          await DatabaseHelper.instance.insertTodo(todo);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV 파일에서 데이터를 가져왔습니다.')),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가져오기 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('백업/복원'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.upload_file),
            title: Text('JSON으로 내보내기'),
            onTap: () => _exportToJson(context),
          ),
          ListTile(
            leading: Icon(Icons.download),
            title: Text('JSON에서 가져오기'),
            onTap: () => _importFromJson(context),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.upload_file),
            title: Text('CSV로 내보내기'),
            onTap: () => _exportToCsv(context),
          ),
          ListTile(
            leading: Icon(Icons.download),
            title: Text('CSV에서 가져오기'),
            onTap: () => _importFromCsv(context),
          ),
        ],
      ),
    );
  }
}
