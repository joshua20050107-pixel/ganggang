import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/sale_store.dart';
import '../data/member_store.dart';
import '../data/item_store.dart';

class AddSaleModal extends StatefulWidget {
  final DateTime selectedDate;

  const AddSaleModal({super.key, required this.selectedDate});

  @override
  State<AddSaleModal> createState() => _AddSaleModalState();
}

class _AddSaleModalState extends State<AddSaleModal> {
  final _formKey = GlobalKey<FormState>();

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
    if (_selectedSeller == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("人を選んでください")));
      return;
    }

    if (_selectedItem == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("商品名を選んでください")));
      return;
    }

    await SaleStore.addSale(
      date: widget.selectedDate,
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
    if (!Hive.isBoxOpen('members') ||
        !Hive.isBoxOpen('members_active') ||
        !Hive.isBoxOpen('items') ||
        !Hive.isBoxOpen('items_active')) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder(
      valueListenable: Hive.box<String>('members').listenable(),
      builder: (_, __, ___) {
        return ValueListenableBuilder(
          valueListenable: Hive.box<bool>('members_active').listenable(),
          builder: (_, __, ___) {
            return ValueListenableBuilder(
              valueListenable: Hive.box<String>('items').listenable(),
              builder: (_, __, ___) {
                return ValueListenableBuilder(
                  valueListenable: Hive.box<bool>('items_active').listenable(),
                  builder: (_, __, ___) {
                    final sellers = MemberStore.getActive();
                    final items = ItemStore.getAll();

                    return Center(
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.63,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ), // ← 少し縮める

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 4),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 7),

                                    _SectionTitle(""),
                                    const SizedBox(height: 6),
                                    _wrapSelection(
                                      sellers,
                                      _selectedSeller,
                                      (v) =>
                                          setState(() => _selectedSeller = v),
                                    ),

                                    const SizedBox(height: 10),
                                    _SectionTitle("商品名"),
                                    const SizedBox(height: 6),
                                    _wrapSelection(
                                      items,
                                      _selectedItem,
                                      (v) => setState(() => _selectedItem = v),
                                    ),

                                    const SizedBox(height: 14),
                                    _SectionTitle("金額（円）"),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _priceCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: inputStyle(),
                                    ),

                                    const SizedBox(height: 14),
                                    _SectionTitle("場所（任意）"),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _locationCtrl,
                                      decoration: inputStyle(),
                                    ),

                                    const SizedBox(height: 14),
                                    _SectionTitle("買った人"),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _buyerCtrl,
                                      onSubmitted: (_) => _addBuyer(),
                                      decoration: inputStyle(),
                                    ),
                                    const SizedBox(height: 8),

                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: _buyers
                                          .map(
                                            (name) => Chip(
                                              label: Text(name),
                                              deleteIcon: const Icon(
                                                Icons.close,
                                              ),
                                              onDeleted: () => setState(
                                                () => _buyers.remove(name),
                                              ),
                                              backgroundColor: const Color(
                                                0xFFF2F2F2,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),

                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _save,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _wrapSelection(
    List<String> list,
    String? selected,
    Function(String) onSelect,
  ) {
    if (list.isEmpty) return _EmptyHint("追加してください。");
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((name) {
            final isSelected = selected == name;
            return GestureDetector(
              onTap: () => onSelect(name),
              child: Container(
                width: w,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  InputDecoration inputStyle() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text),
  );
}
