import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

/// Service quản lý lưu trữ sản phẩm và lịch sử sử dụng SharedPreferences
class InventoryService {
  static const String _productsKey = 'inventory_products';
  static const String _historyKey = 'inventory_history';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Lấy danh sách tất cả sản phẩm
  Future<List<Product>> getAllProducts() async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_productsKey) ?? [];
    return jsonList
        .map((str) => Product.fromJson(json.decode(str)))
        .toList();
  }

  /// Thêm sản phẩm mới vào kho
  Future<void> addProduct(Product product) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_productsKey) ?? [];
    final products = list.map((str) => Product.fromJson(json.decode(str))).toList();

    // Kiểm tra nếu sản phẩm đã tồn tại
    final existingProduct = products.firstWhere(
      (p) => p.code == product.code,
      orElse: () => Product(name: '', code: '', qty: 0, description: ''),
    );

    if (existingProduct.name.isEmpty) {
      // Sản phẩm chưa tồn tại, thêm mới
      list.add(product.toJsonString());
      await prefs.setStringList(_productsKey, list);
      
      // Thêm sự kiện lịch sử cho sản phẩm mới
      await addHistoryEvent(product.code, 'import', product.qty, product.name);
    } else {
      // Sản phẩm đã tồn tại, cập nhật số lượng
      await updateProductQty(product.code, product.qty);
    }
  }

  /// Cập nhật số lượng sản phẩm (delta có thể âm)
  Future<void> updateProductQty(String code, int delta) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_productsKey) ?? [];
    final products = list.map((str) => Product.fromJson(json.decode(str))).toList();
    final idx = products.indexWhere((p) => p.code == code);

    if (idx >= 0) {
      // Cập nhật số lượng sản phẩm
      products[idx].qty += delta;
      if (products[idx].qty < 0) products[idx].qty = 0;

      // Lưu lại danh sách sản phẩm
      final updated = products.map((p) => p.toJsonString()).toList();
      await prefs.setStringList(_productsKey, updated);

      // Ghi lịch sử cập nhật
      final action = delta > 0 ? 'import' : 'export';
      await addHistoryEvent(code, action, delta.abs(), products[idx].name);
    }
  }

  /// Xóa sản phẩm theo code (chỉ khi qty == 0 bên UI kiểm soát)
  Future<void> deleteProduct(String code) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_productsKey) ?? [];
    final products = list.map((str) => Product.fromJson(json.decode(str))).toList();
    
    // Tìm sản phẩm cần xóa để lấy tên
    final productToDelete = products.firstWhere(
      (p) => p.code == code,
      orElse: () => Product(name: '', code: code, qty: 0, description: ''),
    );
    final productName = productToDelete.name;

    // Xóa sản phẩm
    products.removeWhere((p) => p.code == code);

    // Lưu lại danh sách sản phẩm
    final updated = products.map((p) => p.toJsonString()).toList();
    await prefs.setStringList(_productsKey, updated);

    // Ghi lịch sử xóa
    await addHistoryEvent(code, 'delete', 0, productName);
  }

  /// Lấy danh sách lịch sử nhập/xuất
  Future<List<HistoryEvent>> getHistoryEvents() async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    return jsonList
        .map((str) => HistoryEvent.fromJson(json.decode(str)))
        .toList();
  }

  /// Thêm một sự kiện lịch sử nhập hoặc xuất
  Future<void> addHistoryEvent(String code, String action, int qty, [String? productName]) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_historyKey) ?? [];
    
    // Nếu không có productName, tìm tên sản phẩm từ danh sách sản phẩm
    String name = productName ?? '';
    if (name.isEmpty) {
      final products = await getAllProducts();
      final product = products.firstWhere(
        (p) => p.code == code,
        orElse: () => Product(name: '', code: code, qty: 0, description: ''),
      );
      name = product.name;
    }
    
    final event = HistoryEvent(
      code: code,
      action: action,
      qty: qty,
      timestamp: DateTime.now(),
      productName: name,
    );

    // Thêm sự kiện vào danh sách
    list.add(event.toJsonString());
    await prefs.setStringList(_historyKey, list);
  }

  /// Xóa tất cả lịch sử
  Future<void> clearHistory() async {
    final prefs = await _prefs;
    await prefs.remove(_historyKey);
  }
}
