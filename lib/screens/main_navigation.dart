import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'calendar_screen.dart';
import 'monthly_screen.dart';
import 'unpaid_screen.dart';
import 'other_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // ✅ 日付を共有
  final ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());

  @override
  void initState() {
    super.initState();

    // ✅ カレンダーで日付変更 → 自動でホームへ戻る
    selectedDate.addListener(() {
      setState(() {
        _currentIndex = 0; // ← これが「押したらホームへ戻る」の動き
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(selectedDate: selectedDate),
      CalendarScreen(selectedDate: selectedDate),
      MonthlyScreen(),
      UnpaidScreen(),
      OtherScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: '月の売上',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            label: '未払い',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'その他',
          ),
        ],
      ),
    );
  }
}
