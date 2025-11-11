import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TeamRef {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// ログイン（チーム名 + パスワード）
  static Future<bool> login(String team, String password) async {
    final doc = _db.collection("teams").doc(team);
    final snapshot = await doc.get();
    if (!snapshot.exists) return false;
    return snapshot.data()?['password'] == password;
  }

  /// 現在ログイン中の team ドキュメント
  static DocumentReference<Map<String, dynamic>> get teamDoc {
    final team = Hive.box<String>('app_config').get("team");
    if (team == null) throw Exception("team not selected");
    return _db.collection("teams").doc(team);
  }

  /// Firestore コレクション shortcuts
  static CollectionReference<Map<String, dynamic>> get sales =>
      teamDoc.collection("sales");

  static CollectionReference<Map<String, dynamic>> get members =>
      teamDoc.collection("members");

  static CollectionReference<Map<String, dynamic>> get items =>
      teamDoc.collection("items");
}
