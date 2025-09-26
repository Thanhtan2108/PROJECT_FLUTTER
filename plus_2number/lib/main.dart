import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Widget gốc của ứng dụng
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cộng 2 Số',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SumCalculatorCustom(),
    );
  }
}

// Enum để xác định ô đang active (Số A, Số B hoặc không)
enum ActiveField { numberA, numberB, none }

class SumCalculatorCustom extends StatefulWidget {
  const SumCalculatorCustom({super.key});

  @override
  SumCalculatorCustomState createState() => SumCalculatorCustomState();
}

class SumCalculatorCustomState extends State<SumCalculatorCustom> {
  String numberA = "";
  String numberB = "";
  String result = "";
  ActiveField activeField = ActiveField.none;

  // Hàm xử lý khi nhấn các phím trên bàn phím số
  void onKeyPressed(String key) {
    setState(() {
      if (key == "C") {
        // Reset toàn bộ dữ liệu
        numberA = "";
        numberB = "";
        result = "";
        activeField = ActiveField.none;
      } else if (key == "X") {
        // Xóa 1 chữ số cuối cùng của ô đang active
        if (activeField == ActiveField.numberA && numberA.isNotEmpty) {
          numberA = numberA.substring(0, numberA.length - 1);
        } else if (activeField == ActiveField.numberB && numberB.isNotEmpty) {
          numberB = numberB.substring(0, numberB.length - 1);
        }
      } else if (key == "=") {
        // Tính tổng nếu cả hai ô đều có dữ liệu
        if (numberA.isNotEmpty && numberB.isNotEmpty) {
          int sum = int.parse(numberA) + int.parse(numberB);
          result = sum.toString();
        }
      } else {
        // Nhấn các phím số (0-9)
        if (activeField == ActiveField.numberA) {
          numberA += key;
        } else if (activeField == ActiveField.numberB) {
          numberB += key;
        }
      }
    });
  }

  // Hàm thay đổi ô active khi người dùng nhấn vào ô hiển thị
  void setActiveField(ActiveField field) {
    setState(() {
      activeField = field;
    });
  }

  // Widget tạo một hàng có nhãn và ô hình chữ nhật hiển thị giá trị
  Widget buildDisplayRow(String label, String value, bool isActive, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Giảm khoảng cách xuống 4.0
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 150,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isActive ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(value, style: const TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget tạo giao diện cho từng phím trên bàn phím số
  Widget buildKeyButton(String label) {
    return ElevatedButton(
      onPressed: () => onKeyPressed(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(10),
        textStyle: const TextStyle(fontSize: 40),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tính Tổng 2 Số"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // Dùng spaceEvenly cho toàn bộ Column để cân đối các hàng
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Hàng 1: Số A (nhãn và ô hiển thị)
                      buildDisplayRow(
                        "Số A:",
                        numberA,
                        activeField == ActiveField.numberA,
                            () => setActiveField(ActiveField.numberA),
                      ),
                      // Hàng 2: Dấu "+"
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0), // Giảm khoảng cách
                        child: Center(
                          child: Text("+",
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      // Hàng 3: Số B (nhãn và ô hiển thị)
                      buildDisplayRow(
                        "Số B:",
                        numberB,
                        activeField == ActiveField.numberB,
                            () => setActiveField(ActiveField.numberB),
                      ),
                      // Hàng 4: Ô dấu "=" để tính tổng (kích thước thu nhỏ)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: GestureDetector(
                          onTap: () => onKeyPressed("="),
                          child: Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("=",
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      // Hàng 5: Kết quả (nhãn và ô hiển thị)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Kết quả:", style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Container(
                            width: 150,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(result,
                                style: const TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Bàn phím số: Sắp xếp theo lưới với các phím 0-9, "C" và "X"
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          ...List.generate(9,
                                  (index) => buildKeyButton((index + 1).toString())),
                          buildKeyButton("C"),
                          buildKeyButton("0"),
                          buildKeyButton("X"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
