import 'package:flutter/material.dart';
import 'package:okami/data/item_store.dart';
import 'package:okami/data/member_store.dart';
import 'package:okami/data/sale_store.dart';

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
  final ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initStores();

    selectedDate.addListener(() {
      if (mounted) setState(() => _currentIndex = 0);
    });
  }

  Future<void> _initStores() async {
    await ItemStore.dispose();
    await MemberStore.dispose();
    await SaleStore.dispose();

    await ItemStore.init();
    await MemberStore.init();
    await SaleStore.init();

    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    selectedDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      HomeScreen(selectedDate: selectedDate),
      CalendarScreen(selectedDate: selectedDate),
      const MonthlyScreen(),
      const UnpaidScreen(),
      const OtherScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black38,
        elevation: 8,
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
