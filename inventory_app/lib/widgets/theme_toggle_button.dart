// lib/widgets/theme_toggle_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

/// Nút chuyển đổi theme Light/Dark
/// Hiển thị:
/// - Khi Light: biểu tượng mặt trăng màu trắng trên glow đen
/// - Khi Dark: biểu tượng mặt trời màu vàng trên glow vàng
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    // Màu icon: vàng cho sun, trắng cho moon
    final iconColor = isDark ? Colors.yellow : Colors.white;
    // Glow màu: vàng bán trong suốt cho sun, đen bán trong suốt cho moon
    final glowColor = isDark
        ? Colors.yellow.withAlpha((0.6 * 255).round())
        : Colors.black.withAlpha((0.6 * 255).round());

    return IconButton(
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: glowColor,
              spreadRadius: 4,
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          isDark ? Icons.wb_sunny : Icons.nights_stay,
          color: iconColor,
        ),
      ),
      onPressed: () => context.read<ThemeProvider>().toggleTheme(),
      tooltip: isDark ? 'Switch to light' : 'Switch to dark',
    );
  }
}
