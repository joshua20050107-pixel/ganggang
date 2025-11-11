import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// ★ models
import 'models/sale.dart';
import 'models/buyer_status.dart';

// ★ screens
import 'screens/main_navigation.dart';
import 'screens/team_login_screen.dart';

// ★ DatePickerに必要

import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  /// ✅ モデル登録（順番そのまま）
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(BuyerStatusAdapter());

  /// ✅ app_config は *必ず最初に開く*（team 判定に必要）
  await Hive.openBox<String>('app_config');

  /// ✅ チーム選択後に同期される Box（初期は空でOK）
  await Hive.openBox<Sale>('sales');
  await Hive.openBox<String>('members');
  await Hive.openBox<bool>('members_active');
  await Hive.openBox<String>('items');
  await Hive.openBox<bool>('items_active');

  await initializeDateFormatting('ja_JP', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<String>('app_config');
    final team = box.get("team");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '売上管理',
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', 'JP')],

      /// ✅ チーム未選択ならログイン画面 → 選択後同期開始
      home: team == null ? const TeamLoginScreen() : const MainNavigation(),
    );
  }
}
