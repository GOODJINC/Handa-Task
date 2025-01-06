import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart';
import '../models/todo.dart';

class FirebaseSyncHelper {
  // SQLite → Firebase
  static Future<void> syncLocalToFirestore() async {
    try {
      // SQLite에서 수정된 데이터 가져오기
      final modifiedTodos = await DatabaseHelper.instance.getModifiedTodos();

      // Firebase에 업데이트
      for (final todo in modifiedTodos) {
        await FirebaseFirestore.instance
            .collection('todos')
            .doc(todo.id.toString()) // 문서 ID로 SQLite ID를 사용
            .set(todo.toMap(), SetOptions(merge: true)); // 병합 저장
      }

      print('Local to Firebase sync completed.');
    } catch (e) {
      print('Error syncing local to Firebase: $e');
    }
  }

  // Firebase → SQLite
  static Future<void> syncFirestoreToLocal() async {
    try {
      // SQLite에서 가장 최근 수정 시간 가져오기
      final lastSyncTime = await DatabaseHelper.instance.getLastSyncTime();

      // Firebase에서 이후에 수정된 데이터 가져오기
      final snapshot = await FirebaseFirestore.instance
          .collection('todos')
          .where('lastModified', isGreaterThan: lastSyncTime.toIso8601String())
          .get();

      // 가져온 데이터를 SQLite에 저장
      for (final doc in snapshot.docs) {
        final todo = Todo.fromMap(doc.data());
        await DatabaseHelper.instance.insertOrUpdateTodo(todo);
      }

      print('Firebase to local sync completed.');
    } catch (e) {
      print('Error syncing Firebase to local: $e');
    }
  }
}
