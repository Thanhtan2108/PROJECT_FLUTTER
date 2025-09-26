// lib/pages/product_detail_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_app/models/product_model.dart';
import 'package:inventory_app/services/inventory_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _service = InventoryService();
  final _addQtyCtrl = TextEditingController();
  bool _loading = false;
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _addStock() async {
    final addQty = int.tryParse(_addQtyCtrl.text.trim()) ?? 0;
    if (addQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid quantity')),
      );
      return;
    }
    setState(() => _loading = true);
    await _service.updateProductQty(_product.code, addQty);
    final updatedProducts = await _service.getAllProducts();
    final updatedProduct = updatedProducts.firstWhere((p) => p.code == _product.code, orElse: () => _product);
    setState(() {
      _product = updatedProduct;
      _loading = false;
    });
    _addQtyCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$addQty units added to ${_product.name}')),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product from inventory?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteProduct(_product.code);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
    }
  }

  @override
  void dispose() {
    _addQtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Product Detail')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${_product.name}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Code: ${_product.code}', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text('Quantity: ${_product.qty}', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              if (_product.description.isNotEmpty) ...[
                Text('Description:', style: Theme.of(context).textTheme.titleSmall),
                Text(_product.description),
                const SizedBox(height: 8),
              ],
              
              // Hiển thị mã QR code
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    const Text('Product QR Code:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    QrImageView(
                      data: _product.code,
                      version: QrVersions.auto,
                      size: 180.0,
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              const Text('Add Stock:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addQtyCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Quantity to add',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _addStock,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 100),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Product'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  onPressed: _confirmDelete,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
