// lib/models/product_model.dart
import 'dart:convert';

/// Model đại diện cho một sản phẩm trong kho
class Product {
  String name;
  String code;
  int qty;
  String description;

  Product({
    required this.name,
    required this.code,
    required this.qty,
    required this.description,
  });

  /// Chuyển sang JSON map để lưu
  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'qty': qty,
        'description': description,
      };

  /// Tạo từ JSON map
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        name: json['name'],
        code: json['code'],
        qty: json['qty'],
        description: json['description'],
      );

  /// Chuyển sang chuỗi JSON
  String toJsonString() => json.encode(toJson());
}

/// Model cho một sự kiện lịch sử nhập/xuất
class HistoryEvent {
  String code;
  String action; // 'import' hoặc 'export'
  int qty;
  DateTime timestamp;
  String productName;

  HistoryEvent({
    required this.code,
    required this.action,
    required this.qty,
    required this.timestamp,
    this.productName = '',
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'action': action,
        'qty': qty,
        'timestamp': timestamp.toIso8601String(),
        'productName': productName,
      };

  factory HistoryEvent.fromJson(Map<String, dynamic> json) => HistoryEvent(
        code: json['code'],
        action: json['action'],
        qty: json['qty'],
        timestamp: DateTime.parse(json['timestamp']),
        productName: json['productName'] ?? '',
      );

  String toJsonString() => json.encode(toJson());
}