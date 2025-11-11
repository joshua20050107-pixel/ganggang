import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sale.dart';
import '../models/buyer_status.dart';
import 'team_ref.dart';
import 'member_store.dart';
import 'item_store.dart';

class SaleStore {
  static Box<Sale>? _box;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listener;

  static Future<void> init() async {
    await dispose();

    await MemberStore.init();
    await ItemStore.init();

    _box = await Hive.openBox<Sale>('sales');
    _startListener();
  }

  static void _startListener() {
    _listener?.cancel();

    _listener = TeamRef.sales
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) async {
          final box = _box;
          if (box == null || !box.isOpen) return;

          await box.clear();

          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data['placeholder'] == true) continue;

            final buyersRaw = (data['buyers'] as List?) ?? const [];
            final sale = Sale(
              id: doc.id,
              date: (data['date'] as Timestamp).toDate(),
              location: data['location'] ?? '',
              itemName: data['itemName'] ?? '',
              itemPrice: data['itemPrice'] ?? 0,
              sellerName: data['sellerName'] ?? '',
              note: data['note'],
              isPaid: data['isPaid'] ?? false,
              buyers: buyersRaw.map((b) {
                final m = b as Map<String, dynamic>;
                return BuyerStatus(
                  name: m['name'] ?? '',
                  isPaid: m['isPaid'] ?? false,
                );
              }).toList(),
            );

            await box.add(sale);
          }
        });
  }

  static Future<void> addSale({
    required DateTime date,
    required String location,
    required String itemName,
    required int itemPrice,
    required List<String> buyers,
    required String sellerName,
    String? note,
  }) async {
    await TeamRef.sales.add({
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'location': location,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'sellerName': sellerName,
      'note': note,
      'isPaid': false,
      'buyers': buyers.map((n) => {'name': n, 'isPaid': false}).toList(),
    });
  }

  static Future<void> updateSale(Sale sale) async {
    await TeamRef.sales.doc(sale.id).update({
      'isPaid': sale.isPaid,
      'buyers': sale.buyers
          .map((b) => {'name': b.name, 'isPaid': b.isPaid})
          .toList(),
    });
  }

  static Future<void> deleteSale(String saleId) async {
    await TeamRef.sales.doc(saleId).delete();
  }

  static Future<void> dispose() async {
    await _listener?.cancel();
    _listener = null;

    if (Hive.isBoxOpen('sales')) {
      await Hive.box<Sale>('sales').close();
    }
  }
}
