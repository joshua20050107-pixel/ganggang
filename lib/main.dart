import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/sale.dart';
import 'models/buyer_status.dart'; // ★ 追加
import 'screens/main_navigation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:okami/data/item_store.dart';
import 'package:okami/data/member_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // ★ アダプタ登録（順番大事）
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(BuyerStatusAdapter()); // ← 追加

  // ★ ボックス開く
  await Hive.openBox<Sale>('sales');

  // ★ 今だけ一回だけデータ初期化したいならこれ
  //    → 実行後、コメントアウトしてOK
  // await Hive.box<Sale>('sales').clear();

  await ItemStore.init();
  await MemberStore.init();

  await initializeDateFormatting('ja_JP', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '売上管理',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MainNavigation(),
    );
  }
}
