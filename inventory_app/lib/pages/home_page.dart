// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'declare_page.dart';
import 'import_page.dart';
import 'export_page.dart';
import 'report_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      {'title': 'Declare Product', 'icon': Icons.add_box, 'page': const DeclarePage()},
      {'title': 'Import', 'icon': Icons.login, 'page': const ImportPage()},
      {'title': 'Export', 'icon': Icons.logout, 'page': const ExportPage()},
      {'title': 'Report', 'icon': Icons.table_chart, 'page': const ReportPage()},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // chỉ Text + waving hand, không toggle button
            Row(
              children: const [
                Text(
                  'Welcome to Warehouse App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.waving_hand),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'This app helps you manage your warehouse with 4 core features:\n'
                  '• Declare new products\n'
                  '• Import products via QR code\n'
                  '• Export products via QR code\n'
                  '• View stock report summary',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: cards.map((c) => InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => c['page'] as Widget),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(c['icon'] as IconData, size: 48),
                      const SizedBox(height: 8),
                      Text(c['title'] as String, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
