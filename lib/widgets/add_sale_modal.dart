import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/sale_store.dart';
import '../data/member_store.dart';
import '../data/item_store.dart';

class AddSaleModal extends StatefulWidget {
  const AddSaleModal({super.key});

  @override
  State<AddSaleModal> createState() => _AddSaleModalState();
}

class _AddSaleModalState extends State<AddSaleModal> {
  final _formKey = GlobalKey<FormState>();

  // ✅ Active のみ取得
  List<String> get _sellers => MemberStore.getActive();
  List<String> get _items => ItemStore.getActive();

  String? _selectedSeller;
  String? _selectedItem;

  final _priceCtrl = TextEditingController(text: "4000");
  final _locationCtrl = TextEditingController();
  final _buyerCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<String> _buyers = [];

  void _addBuyer() {
    final name = _buyerCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _buyers.add(name);
      _buyerCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (_selectedSeller == null || _selectedItem == null) return;

    await SaleStore.addSale(
      location: _locationCtrl.text,
      itemName: _selectedItem!,
      itemPrice: int.tryParse(_priceCtrl.text) ?? 0,
      buyers: _buyers,
      sellerName: _selectedSeller!,
      note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Header ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "販売を追加",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ---- 売った人 ----
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final w = (constraints.maxWidth - 8) / 2;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _sellers.map((name) {
                            final selected = _selectedSeller == name;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSeller = name),
                              child: Container(
                                width: w,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.black
                                      : const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // ---- 商品 ----
                    Text(
                      "商品名",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final w = (constraints.maxWidth - 8) / 2;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _items.map((item) {
                            final selected = _selectedItem == item;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedItem = item),
                              child: Container(
                                width: w,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.black
                                      : const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // ---- 金額 ----
                    Text(
                      "金額（円）",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ---- 場所 ----
                    Text(
                      "場所（任意）",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    TextField(
                      controller: _locationCtrl,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ---- 買った人 ----
                    Text(
                      "買った人",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    TextField(
                      controller: _buyerCtrl,
                      onSubmitted: (_) => _addBuyer(),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _buyers.map((name) {
                        return Chip(
                          label: Text(name),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => setState(() => _buyers.remove(name)),
                          backgroundColor: const Color(0xFFF2F2F2),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // ---- 保存 ----
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "保存する",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
