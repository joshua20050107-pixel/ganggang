import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late Box<Sale> _saleBox;

  @override
  void initState() {
    super.initState();
    _saleBox = Hive.box<Sale>('sales');
  }

  List<Sale> _getSalesForDay(DateTime day) {
    final sales = _saleBox.values.toList();
    return sales
        .where(
          (s) =>
              s.date.year == day.year &&
              s.date.month == day.month &&
              s.date.day == day.day,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSales = _selectedDay != null
        ? _getSalesForDay(_selectedDay!)
        : [];

    int total = 0;
    for (final s in selectedSales) {
      total += s.total is int ? s.total as int : (s.total as num).toInt();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("売上カレンダー")),
      body: Column(
        children: [
          // ← overflow対策：ここを Flexible で包む
          Flexible(
            child: TableCalendar(
              locale: 'ja_JP',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_selectedDay == null)
            const Text("日付をタップするとその日の売上を表示します")
          else
            Expanded(
              child: Column(
                children: [
                  Text(
                    "${_selectedDay!.year}/${_selectedDay!.month}/${_selectedDay!.day} の売上：¥$total",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: selectedSales.isEmpty
                        ? const Center(child: Text("この日の売上はありません"))
                        : ListView.builder(
                            itemCount: selectedSales.length,
                            itemBuilder: (context, index) {
                              final s = selectedSales[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  title: Text(
                                    "${s.itemName}（¥${s.itemPrice} × ${s.quantity} = ¥${s.total}）",
                                  ),
                                  subtitle: Text(
                                    "買: ${s.buyerName} ｜ 売: ${s.sellerName} ｜ ${s.location}",
                                  ),
                                  trailing: Icon(
                                    s.isPaid
                                        ? Icons.check_circle
                                        : Icons.access_time,
                                    color: s.isPaid
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
