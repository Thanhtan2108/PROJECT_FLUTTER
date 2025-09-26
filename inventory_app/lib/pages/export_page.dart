import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:inventory_app/models/product_model.dart';
import 'package:inventory_app/services/inventory_service.dart';
import 'package:inventory_app/pages/report_page.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _service = InventoryService();
  bool _loading = false;
  Product? _scannedProduct;

  Future<void> _scanQRCode() async {
    try {
      final code = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const QRScannerScreen()),
      );
      if (!mounted || code == null) return;

      setState(() {
        _codeCtrl.text = code;
        _nameCtrl.clear();
        _scannedProduct = null;
      });

      final products = await _service.getAllProducts();
      if (!mounted) return;

      final found = products.firstWhere(
        (p) => p.code == code,
        orElse: () => Product(name: '', code: '', qty: 0, description: ''),
      );
      if (found.name.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product not found in inventory!')),
          );
        }
      } else {
        setState(() {
          _scannedProduct = found;
          _nameCtrl.text = found.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning QR code: $e')),
        );
      }
    }
  }

  Future<void> _export() async {
    final code = _codeCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final qtyText = _qtyCtrl.text.trim();
    final qty = int.tryParse(qtyText);

    if (code.isEmpty || name.isEmpty || qty == null || qty <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid product details and quantity')),
        );
      }
      return;
    }

    try {
      setState(() => _loading = true);

      final products = await _service.getAllProducts();
      if (!mounted) return;

      final existingProduct = products.firstWhere(
        (p) => p.code == code,
        orElse: () => Product(name: '', code: '', qty: 0, description: ''),
      );

      if (existingProduct.name.isEmpty) {
        // Product does not exist
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product not found in inventory!')),
          );
        }
      } else if (existingProduct.qty == 0) {
        // Product is out of stock
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product is out of stock!')),
          );
        }
      } else if (existingProduct.qty < qty) {
        // Not enough quantity in stock
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough quantity in stock!')),
          );
        }
      } else {
        // Update product quantity
        await _service.updateProductQty(code, -qty);
        if (mounted) {
          // Cập nhật lại thông tin sản phẩm sau khi xuất hàng thành công
          final updatedProducts = await _service.getAllProducts();
          final updatedProduct = updatedProducts.firstWhere(
            (p) => p.code == code,
            orElse: () => Product(name: '', code: '', qty: 0, description: ''),
          );
          
          setState(() {
            _scannedProduct = updatedProduct;
            _loading = false;
            _codeCtrl.clear();
            _nameCtrl.clear();
            _qtyCtrl.clear();
          });
          
          // Kiểm tra mounted trước khi sử dụng context để hiển thị dialog
          if (!mounted) return;
          
          // Hiển thị thông báo thành công
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Export Successful'),
              content: Text('$qty units exported from product "$name".\nCurrent stock: ${updatedProduct.qty} units'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Đóng dialog
                  },
                  child: const Text('Continue'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Đóng dialog
                    // Mở trang báo cáo tồn kho
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportPage()),
                    );
                  },
                  child: const Text('View Stock'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting product: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _codeCtrl.clear();
          _nameCtrl.clear();
          _qtyCtrl.clear();
        });
      }
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Export Product')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
                onPressed: _scanQRCode,
              ),
              const SizedBox(height: 12),
              if (_scannedProduct != null) ...[
                Text(
                  'Scanned Product:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Name: ${_scannedProduct!.name}'),
                Text('Code: ${_scannedProduct!.code}'),
                Text('Quantity: ${_scannedProduct!.qty}'),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Product Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Export',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _export,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Export'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// QR Scanner Screen with one-time detection
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _detected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_detected) return;
          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;

          final code = barcodes.first.rawValue;
          if (code == null) return;

          _detected = true;
          _controller.stop();
          Navigator.pop(context, code);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}