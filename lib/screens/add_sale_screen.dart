import 'package:flutter/material.dart';
import '../data/sale_store.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _itemCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: "4000");
  final _qtyCtrl = TextEditingController(text: "1");
  final _locationCtrl = TextEditingController();
  final _buyerCtrl = TextEditingController();
  final _sellerCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _isPaid = false;

  // 🧩 複数人管理リスト
  List<String> _buyers = [];

  @override
  void dispose() {
    _itemCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _locationCtrl.dispose();
    _buyerCtrl.dispose();
    _sellerCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await SaleStore.addSale(
      location: _locationCtrl.text,
      itemName: _itemCtrl.text,
      itemPrice: int.tryParse(_priceCtrl.text) ?? 0,
      buyers: _buyers, // ✅ 複数人を保存
      sellerName: _sellerCtrl.text,
      note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _addBuyer() {
    final name = _buyerCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _buyers.add(name);
      _buyerCtrl.clear();
    });
  }

  void _removeBuyer(String name) {
    setState(() => _buyers.remove(name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        title: const Text('販売を追加'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _itemCtrl,
                decoration: const InputDecoration(
                  labelText: "商品名（固定リストから選択予定）",
                ),
                validator: (v) => (v == null || v.isEmpty) ? "必須項目です" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: "金額（円）"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(labelText: "個数"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: "売れた場所（任意）"),
              ),
              const SizedBox(height: 20),

              // 🧍‍♂️ 買った人追加エリア
              const Text(
                "買った人",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _buyerCtrl,
                      decoration: const InputDecoration(
                        labelText: "名前を入力",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addBuyer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _buyers.map((name) {
                  return Chip(
                    label: Text(name),
                    backgroundColor: Colors.grey[200],
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _removeBuyer(name),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _sellerCtrl,
                decoration: const InputDecoration(labelText: "売った人の名前"),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("支払い完了"),
                value: _isPaid,
                onChanged: (v) => setState(() => _isPaid = v),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: "メモ（任意）"),
              ),
              const SizedBox(height: 24),

              // 💾 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "保存する",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
