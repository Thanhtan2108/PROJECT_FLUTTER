import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ClockView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ClockView({super.key, required this.onToggleTheme});

  @override
  State<ClockView> createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  late Timer _timer;
  DateTime _dateTime = DateTime.now();

  // Kích thước của đồng hồ
  final double clockSize = 250.0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { // cứ mỗi giây, cập nhật thời gian
      setState(() {
        _dateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() { // Hủy timer khi widget bị hủy
    _timer.cancel();
    super.dispose(); 
  }

  String _format(int n) => n.toString().padLeft(2, '0'); // Định dạng số với 2 chữ số (01, 02, ... 10, 11, 12)

  @override
  Widget build(BuildContext context) {
    // Xác định xem ứng dụng đang ở darkTheme hay lightTheme (để chọn hiệu ứng)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mặt đồng hồ analog
              Container(
                width: clockSize,
                height: clockSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // giữ nền trắng để số và vạch luôn rõ
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 0),
                      blurRadius: 10,
                      color: isDark
                          // ignore: deprecated_member_use
                          ? Colors.white.withOpacity(0.5)
                          // ignore: deprecated_member_use
                          : Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Vạch chia phút (60 vạch)
                    ...List.generate(60, (i) {
                      final double angle = i * 6 * pi / 180; // 6 độ = pi/30 radian
                      final double length = (i % 5 == 0) ? 12.0 : 6.0; // chiều dài vạch chia phút
                      final double thickness = (i % 5 == 0) ? 2.0 : 1.0; // độ dày vạch chia phút
                      return Transform.rotate(
                        angle: angle,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: thickness,
                            height: length,
                            color: Colors.black, // luôn dùng màu đen cho vạch chia
                          ),
                        ),
                      );
                    }),
                    
                    // Số giờ (1 đến 12)
                    ...List.generate(12, (i) {
                      final double angle = (i + 1) * 30 * pi / 180; // 30 độ = pi/6 radian
                      final double radius = clockSize / 2 - 30; // khoảng cách từ tâm đến số giờ
                      final double dx = radius * cos(angle - pi / 2); // -pi/2 để số giờ nằm đúng vị trí
                      final double dy = radius * sin(angle - pi / 2); // -pi/2 để số giờ nằm đúng vị trí
                      return Transform.translate(
                        offset: Offset(dx, dy),
                        child: Text(
                          // Số giờ luôn hiển thị màu đen (rõ trên mặt trắng)
                          // Nếu muốn đổi theo theme, thay const TextStyle(...color: ...) bằng biểu thức điều kiện
                          // Ví dụ: color: isDark ? Colors.white : Colors.black,
                          // Nhưng với mặt đồng hồ trắng, màu đen thường hiển thị tốt.
                          // Ở đây, ta để màu đen cho số giờ.
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                    
                    // Kim giờ
                    _buildHand(
                      angleDegree: _dateTime.hour * 30 + _dateTime.minute * 0.5,
                      rightLength: 90,
                      leftLength: 50, // càng tăng chiều dài này, chiều dài tại gốc càng ngắn lại
                      thickness: 6,
                      color: Colors.green,
                    ),
                    
                    // Kim phút
                    _buildHand(
                      angleDegree: _dateTime.minute * 6,
                      rightLength: 105,
                      leftLength: 60, // chiều dài này cũng có thể tăng lên
                      thickness: 4,
                      color: Colors.red,
                    ),
                    
                    // Kim giây
                    _buildHand(
                      angleDegree: _dateTime.second * 6,
                      rightLength: 120,
                      leftLength: 57,
                      thickness: 2,
                      color: Colors.deepPurple,
                    ),
                    
                    // Chấm tròn tâm
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Hiển thị thời gian số
              Text(
                '${_format(_dateTime.hour)} : ${_format(_dateTime.minute)} : ${_format(_dateTime.second)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Hiển thị ngày tháng
              Text(
                '${_format(_dateTime.day)}/${_format(_dateTime.month)}/${_format(_dateTime.year)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Hiển thị tên cá nhân (một phần phụ, có thể hiển thị ở vị trí phù hợp)
              const Text(
                "Ngô Thanh Tân - Trịnh Thiết Trình",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 10),
            ],
          ),
        ),
        
        // Nút chuyển đổi Dark/Light Mode ở góc trên bên phải, với hiệu ứng glow
        Positioned(
          top: 40,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      // ignore: deprecated_member_use
                      ? Colors.yellow.withOpacity(0.5)
                      // ignore: deprecated_member_use
                      : Colors.white.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.wb_sunny : Icons.nightlight_round,
                color: isDark ? Colors.yellow : Colors.white,
              ),
              tooltip: 'Chuyển Dark/Light Mode',
              onPressed: widget.onToggleTheme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHand({
    required double angleDegree,
    required double rightLength,
    required double leftLength,
    required double thickness,
    Color color = Colors.black,
  }) {
    final double angleRad = (angleDegree - 90) * pi / 180;
    return Transform.rotate(
      angle: angleRad,
      child: Container(
        width: rightLength + leftLength,
        height: thickness,
        alignment: Alignment.centerLeft,
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: rightLength,
            height: thickness,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
