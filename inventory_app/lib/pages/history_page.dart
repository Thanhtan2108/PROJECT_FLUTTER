// lib/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_app/models/product_model.dart';
import 'package:inventory_app/services/inventory_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  final _service = InventoryService();
  late Future<List<HistoryEvent>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _service.getHistoryEvents();
    });
  }
  
  // Phương thức để refresh lịch sử từ bên ngoài
  void refreshHistory() {
    _loadHistory();
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all history records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.clearHistory();
      setState(() {
        _loadHistory();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History cleared')),
      );
    }
  }

  // Hiển thị dữ liệu thô từ SharedPreferences
  Future<void> _showRawData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getStringList('inventory_history') ?? [];
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Raw History Data'),
        content: SingleChildScrollView(
          child: Text('Records: ${rawData.length}\n\n${rawData.join('\n\n')}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          // Thêm nút debug
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Debug Data',
            onPressed: _showRawData,
          ),
          // Thêm nút refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh History',
            onPressed: _loadHistory,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear History',
            onPressed: _confirmClearHistory,
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryEvent>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(child: Text('No import/export/delete history'));
          }

          // Sort by time descending
          events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          // Remove duplicate entries (chỉ dựa vào code, action và qty, bỏ qua timestamp)
          final seen = <String>{};
          final uniqueEvents = events.where((e) {
            final key = '${e.code}_${e.action}_${e.qty}';
            if (seen.contains(key)) return false;
            seen.add(key);
            return true;
          }).toList();

          return ListView.separated(
            itemCount: uniqueEvents.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final e = uniqueEvents[index];
              final action = e.action.toLowerCase();

              IconData icon;
              Color iconColor;
              String title;
              
              // Hiển thị tên sản phẩm nếu có, nếu không thì hiển thị mã
              final displayName = e.productName.isNotEmpty ? e.productName : e.code;

              if (action == 'import') {
                icon = Icons.add_circle;
                iconColor = Colors.green;
                title = 'Imported $e.qty units of product "$displayName"';
              } else if (action == 'export') {
                icon = Icons.remove_circle;
                iconColor = Colors.red;
                title = 'Exported $e.qty units of product "$displayName"';
              } else if (action == 'delete') {
                icon = Icons.delete;
                iconColor = Colors.grey;
                title = 'Deleted product "$displayName"';
              } else {
                icon = Icons.info;
                iconColor = Colors.blueGrey;
                title = 'Unknown action';
              }

              return ListTile(
                leading: Icon(icon, color: iconColor),
                title: Text(title),
                subtitle: Text(
                  'Code: ${e.code}\n${e.timestamp.toLocal().toString().split('.')[0]}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
