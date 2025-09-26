// lib/pages/declare_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_app/models/product_model.dart';
import 'package:inventory_app/services/inventory_service.dart';

class DeclarePage extends StatefulWidget {
  const DeclarePage({super.key});

  @override
  State<DeclarePage> createState() => _DeclarePageState();
}

class _DeclarePageState extends State<DeclarePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _service = InventoryService();
  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final qtyVal = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final desc = _descCtrl.text.trim();

    final products = await _service.getAllProducts();
    if (!mounted) return;

    final existingIndex =
        products.indexWhere((p) => p.code == code || p.name == name);
    if (existingIndex < 0) {
      // Thêm mới
      final p = Product(
        name: name,
        code: code,
        qty: qtyVal,
        description: desc,
      );
      await _service.addProduct(p);
      // Thêm sự kiện lịch sử khi thêm mới
      await _service.addHistoryEvent(code, 'import', qtyVal);
    } else {
      // Cập nhật qty - updateProductQty đã tự động gọi addHistoryEvent
      final existing = products[existingIndex];
      await _service.updateProductQty(existing.code, qtyVal);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product declared/imported successfully')),
    );
    _formKey.currentState!.reset();
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _qtyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Declare Product')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(), // Thêm dòng này để có khung viền
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Enter name' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Product Code',
                    border: OutlineInputBorder(), // Thêm dòng này để có khung viền
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Enter code' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _qtyCtrl,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(), // Thêm dòng này để có khung viền
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Invalid quantity';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(), // Thêm dòng này để có khung viền
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Declare Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
