import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// ★ models
import 'models/sale.dart';
import 'models/buyer_status.dart';
import 'models/item.dart';
import 'models/member.dart';

// ★ data store
import 'data/item_store.dart';
import 'data/member_store.dart';

// ★ screens
import 'screens/main_navigation.dart';

// ★ 追加（DatePicker に必要）
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ------------ Hive Adapter 登録（順番超重要） ------------
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(BuyerStatusAdapter());
  Hive.registerAdapter(ItemAdapter()); // ★ 追加
  Hive.registerAdapter(MemberAdapter()); // ★ 追加

  // ------------ Box Open（Sale は直接開く / Item & Member は Store 側で） ------------
  await Hive.openBox<Sale>('sales');

  await ItemStore.init(); // ★ Active/Inactive 対応済み
  await MemberStore.init(); // ★ Active/Inactive 対応済み

  // 日本語日付対応
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

      // ✅ ここだけ新しく追加（DatePickerのエラー修正）
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', 'JP')],

      home: const MainNavigation(),
    );
  }
}
