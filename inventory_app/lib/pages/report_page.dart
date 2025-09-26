import 'package:flutter/material.dart';
import 'package:inventory_app/models/product_model.dart';
import 'package:inventory_app/services/inventory_service.dart';
import 'package:inventory_app/pages/product_detail_page.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _service = InventoryService();
  List<Product> _products = [];
  bool _loading = false;

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await _service.getAllProducts();

    // Bỏ đoạn tự động xóa sản phẩm khi số lượng bằng 0
    // for (var p in products) {
    //   if (p.qty == 0) {
    //     await _service.deleteProduct(p.code);
    //   }
    // }

    setState(() {
      _products = products; // Thay vì _products = updatedProducts
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No products in stock.'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(p.name),
                        subtitle: Text('Code: ${p.code}'),
                        trailing: Text('Qty: ${p.qty}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPage(product: p),
                            ),
                          ).then((_) => _loadProducts()); // reload sau khi trở lại
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
