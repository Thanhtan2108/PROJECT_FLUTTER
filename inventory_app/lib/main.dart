// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_provider.dart';
import 'widgets/theme_toggle_button.dart';
import 'pages/home_page.dart';
import 'pages/history_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(prefs),
      child: const InventoryApp(),
    ),
  );
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      // Chỉ hiển thị banner khi đang ở chế độ debug
      // Chế độ release không hiển thị banner
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.purple.shade50,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  static const _titles = ['Thanh Tân - Thiết Trình', 'History'];
  final _pages = const [HomePage(), HistoryPage()];
  
  // Tham chiếu đến trang History để có thể refresh
  final _historyPageKey = GlobalKey<HistoryPageState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: const [ThemeToggleButton()],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _pages[0],
          HistoryPage(key: _historyPageKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 28,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        onTap: (index) {
          if (index == 1) {
            // Khi chuyển sang tab History, refresh dữ liệu
            _historyPageKey.currentState?.refreshHistory();
          }
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
