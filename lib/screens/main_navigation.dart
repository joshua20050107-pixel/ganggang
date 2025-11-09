import 'package:flutter/material.dart';

// 各画面
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'monthly_screen.dart';
import 'unpaid_screen.dart';
import 'other_screen.dart'; // ← ここ大事!!!

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    MonthlyScreen(),
    UnpaidScreen(),
    OtherScreen(), // ← ✅ これで表示される!
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
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
