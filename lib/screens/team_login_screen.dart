import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main_navigation.dart';
import '../data/sale_store.dart';
import '../data/team_ref.dart';

class TeamLoginScreen extends StatefulWidget {
  const TeamLoginScreen({super.key});

  @override
  State<TeamLoginScreen> createState() => _TeamLoginScreenState();
}

class _TeamLoginScreenState extends State<TeamLoginScreen> {
  final _teamController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isCreatingTeam = false;

  void _cancelInput() {
    FocusScope.of(context).unfocus();
    _teamController.clear();
    _passwordController.clear();
  }

  Future<void> _login() async {
    final team = _teamController.text.trim();
    final pass = _passwordController.text.trim();

    _cancelInput();

    final ok = await TeamRef.login(team, pass);
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("チーム名またはパスワードが違います")));
      return;
    }

    await Hive.box<String>('app_config').put("team", team);
    await SaleStore.init();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  Future<void> createTeam() async {
    final team = _teamController.text.trim();
    final password = _passwordController.text.trim();

    _cancelInput();

    if (team.isEmpty || password.isEmpty) return;

    try {
      final doc = FirebaseFirestore.instance.collection('teams').doc(team);
      final exists = await doc.get();

      if (exists.exists) {
        _showError("このチーム名は既に使われています");
        return;
      }

      await doc.set({'password': password});
      await doc.collection("members").doc("_init").set({"active": false});
      await doc.collection("items").doc("_init").set({"active": false});
      await doc.collection("sales").doc("_init").set({"placeholder": true});

      await Hive.box<String>('app_config').put("team", team);
      await SaleStore.init();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (_) => false,
      );
    } catch (_) {
      _showError("接続エラーが発生しました");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _teamController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isCreatingTeam ? "チームを作成" : "チームにログイン";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _cancelInput,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _teamController,
                  decoration: _input("チーム名"),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _input("パスワード"),
                ),
                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCreatingTeam ? createTeam : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isCreatingTeam ? "チームを作成" : "ログイン",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isCreatingTeam = !_isCreatingTeam);
                      _cancelInput();
                    },
                    child: Text(
                      _isCreatingTeam ? "既存のチームにログイン" : "新しいチームを作成する",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
