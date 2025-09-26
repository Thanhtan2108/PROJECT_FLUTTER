import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyCalculatorApp());
}

class MyCalculatorApp extends StatelessWidget {
  const MyCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme tối với nền đen
    return MaterialApp(
      title: 'Multi-Mode Calculator',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      debugShowCheckedModeBanner: false,
      home: const CalculatorHome(),
    );
  }
}

// Enum xác định 3 chế độ: Basic, History, Base Converter
enum CalculatorMode { basic, history, baseConverter }

// Enum để xác định hệ số mà người dùng nhập vào ở Base Converter
enum ConversionSystem { decimal, binary, hex, bcd }

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  // Mặc định chế độ Basic
  CalculatorMode _currentMode = CalculatorMode.basic;

  // Các biến cho phần hiển thị của Calculator chuẩn
  String userInput = '';
  String result = '0';

  // Lưu lịch sử tính toán
  List<String> calcHistory = [];

  // Các biến cho Base Converter (4 hệ số)
  String decimalInput = '';
  String binaryInput = '';
  String hexInput = '';
  String bcdInput = '';
  ConversionSystem? activeSystem;

  // Danh sách nút của máy tính Basic (không thay đổi)
  final List<String> basicButtons = [
    'C',
    '(',
    ')',
    '%',
    '7',
    '8',
    '9',
    '÷',
    '4',
    '5',
    '6',
    '×',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '=',
    '+',
  ];

  /// Hàm xử lý nút bấm cho chế độ Basic
  void onButtonPressed(String text) {
    setState(() {
      if (text == 'C') {
        userInput = '';
        result = '0';
      } else if (text == '+/-') {
        if (result.startsWith('-')) {
          result = result.substring(1);
        } else {
          result = '-$result';
        }
      } else if (text == '=') {
        final calcRes = calculateExpression(userInput);
        result = calcRes;
        calcHistory.add('$userInput = $result');
      } else {
        userInput += text;
      }
    });
  }

  /// Nút xóa 1 ký tự (⌫)
  void onDeleteOneChar() {
    setState(() {
      if (userInput.isNotEmpty) {
        userInput = userInput.substring(0, userInput.length - 1);
      }
      if (userInput.isEmpty) {
        result = '0';
      }
    });
  }

  /// Hàm tính toán biểu thức sử dụng ShuntingYardParser
  String calculateExpression(String expr) {
    try {
      // Xử lý phần trăm
      expr = expr.replaceAllMapped(
        RegExp(r'(\d+(\.\d+)?)%'),
        (match) => '(${match.group(1)}/100)',
      );

      // Thay thế các toán tử đặc biệt
      expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
      
      // Parse biểu thức
      ShuntingYardParser parser = ShuntingYardParser();
      Expression parsedExpression = parser.parse(expr);

      // Tạo ContextModel và định nghĩa các hàm toán học
      ContextModel cm = ContextModel();
      cm.bindVariableName('pi', Number(math.pi));

      // Evaluate biểu thức
      double eval = parsedExpression.evaluate(EvaluationType.REAL, cm);

      if (eval == eval.roundToDouble()) {
        return eval.toInt().toString();
      }
      return eval.toString();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: Biểu thức không hợp lệ')),
      );
      return 'Error';
    }
  }

  /// Hàm chuyển đổi số thập phân sang BCD
  String decimalToBCD(String decStr) {
    String result = '';
    for (int i = 0; i < decStr.length; i++) {
      var ch = decStr[i];
      if (ch == '-') {
        result += '-';
      } else if (RegExp(r'\d').hasMatch(ch)) {
        int d = int.parse(ch);
        String bin = d.toRadixString(2).padLeft(4, '0');
        result += bin;
        if (i < decStr.length - 1) result += ' ';
      } else {
        result += ch;
      }
    }
    return result;
  }

  /// Hàm chuyển đổi BCD sang số thập phân
  String bcdToDecimal(String bcdStr) {
    // Loại bỏ khoảng trắng trong chuỗi BCD
    String s = bcdStr.replaceAll(' ', '');
    
    // Kiểm tra độ dài chuỗi BCD phải là bội số của 4
    if (s.length % 4 != 0) return "Error";

    String dec = '';
    for (int i = 0; i < s.length; i += 4) {
      // Lấy từng nhóm 4 bit
      String digitBin = s.substring(i, i + 4);
      
      // Chuyển đổi nhóm 4 bit sang số thập phân
      int? digit = int.tryParse(digitBin, radix: 2);
      
      // Kiểm tra nếu không phải số hợp lệ hoặc lớn hơn 9
      if (digit == null || digit > 9) return "Error";
      
      // Thêm số thập phân vào kết quả
      dec += digit.toString();
    }
    return dec;
  }

  /// Hàm chuyển đổi dựa trên TextField được chỉnh sửa cho Base Converter
  void convertFromInput(String input, ConversionSystem system) {
    setState(() {
      activeSystem = system;
      switch (system) {
        case ConversionSystem.decimal:
          decimalInput = input;
          try {
            int value = int.parse(input);
            binaryInput = value.toRadixString(2);
            hexInput = value.toRadixString(16).toUpperCase();
            bcdInput = decimalToBCD(input);
          } catch (e) {
            binaryInput = 'Error';
            hexInput = 'Error';
            bcdInput = 'Error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: Giá trị không hợp lệ')),
            );
          }
          break;
        case ConversionSystem.binary:
          binaryInput = input;
          try {
            int value = int.parse(input, radix: 2);
            decimalInput = value.toString();
            hexInput = value.toRadixString(16).toUpperCase();
            bcdInput = decimalToBCD(value.toString());
          } catch (e) {
            decimalInput = 'Error';
            hexInput = 'Error';
            bcdInput = 'Error';
          }
          break;
        case ConversionSystem.hex:
          hexInput = input;
          try {
            int value = int.parse(input, radix: 16);
            decimalInput = value.toString();
            binaryInput = value.toRadixString(2);
            bcdInput = decimalToBCD(value.toString());
          } catch (e) {
            decimalInput = 'Error';
            binaryInput = 'Error';
            bcdInput = 'Error';
          }
          break;
        case ConversionSystem.bcd:
          bcdInput = input;
          try {
            // Chuyển đổi BCD sang Decimal
            String dec = bcdToDecimal(input);
            if (dec == "Error") {
              throw Exception("Invalid BCD");
            }
            decimalInput = dec;

            // Chuyển đổi Decimal sang Binary và Hex
            int value = int.parse(dec);
            binaryInput = value.toRadixString(2);
            hexInput = value.toRadixString(16).toUpperCase();
          } catch (e) {
            decimalInput = 'Error';
            binaryInput = 'Error';
            hexInput = 'Error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: Giá trị BCD không hợp lệ')),
            );
          }
          break;
      }
    });
  }

  /// Hàm chuyển đổi giữa các chế độ (toggle)
  void toggleMode(CalculatorMode mode) {
    setState(() {
      if (_currentMode == mode) {
        _currentMode = CalculatorMode.basic;
      } else {
        _currentMode = mode;
      }
    });
  }

  /// Reset toàn bộ giá trị của Base Converter
  void resetConverter() {
    setState(() {
      decimalInput = '';
      binaryInput = '';
      hexInput = '';
      bcdInput = '';
      activeSystem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tiêu đề
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 12, top: 8),
              child: const Text(
                "Ngô Thanh Tân, Trịnh Thiết Trình",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            
            // Vùng hiển thị input và result
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // cho phép cuộn ngang khi input quá dài
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true, // cuộn về phía cuối cùng (số mới nhất)
                        child: Text(
                          userInput,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Color(0xFF00FF00),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // cũng có thể cuộn ngang hoặc đặt maxLines=1
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          result.length > 15 ? '${result.substring(0, 15)}...' : result,
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Thanh Tag icon
            Container(
              height: 50,
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tag History / Keyboard
                  IconButton(
                    onPressed: () => toggleMode(CalculatorMode.history),
                    icon: (_currentMode == CalculatorMode.history)
                        ? const Icon(Icons.keyboard, color: Colors.green)
                        : const Icon(Icons.history, color: Colors.white),
                  ),
                  // Tag Base Converter / Keyboard
                  IconButton(
                    onPressed: () => toggleMode(CalculatorMode.baseConverter),
                    icon: (_currentMode == CalculatorMode.baseConverter)
                        ? const Icon(Icons.keyboard, color: Colors.green)
                        : const Icon(Icons.straighten, color: Colors.white),
                  ),
                  // Nút xóa 1 ký tự (⌫)
                  IconButton(
                    onPressed: onDeleteOneChar,
                    icon: const Icon(Icons.backspace, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Nội dung chính theo chế độ (IndexedStack)
            Expanded(
              flex: 7,
              child: IndexedStack(
                index: _currentMode.index,
                children: [
                  _buildBasicCalculator(),
                  _buildHistoryView(),
                  _buildBaseConverterView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chế độ Basic
  Widget _buildBasicCalculator() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(top: 10),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: basicButtons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final btnText = basicButtons[index];
          return CalcButton(
            text: btnText,
            onTap: () => onButtonPressed(btnText),
          );
        },
      ),
    );
  }

  /// Chế độ History
  Widget _buildHistoryView() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: calcHistory.length,
              separatorBuilder: (context, idx) => const Divider(color: Colors.grey),
              itemBuilder: (context, idx) => ListTile(
                title: Text(
                  calcHistory[idx],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                calcHistory.clear();
              });
            },
            child: const Text('Xóa nhật ký'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Chế độ Base Converter
  Widget _buildBaseConverterView() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          const Text(
            'Chuyển đổi cơ số',
            style: TextStyle(color: Color(0xFF00FF00), fontSize: 20),
          ),
          const SizedBox(height: 20),
          
          // TextField Decimal
          TextField(
            controller: TextEditingController(
              text: decimalInput,
            )..selection = TextSelection.collapsed(offset: decimalInput.length),
            onChanged: (val) => convertFromInput(val, ConversionSystem.decimal),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Decimal',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00FF00)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // TextField Binary
          TextField(
            controller: TextEditingController(text: binaryInput)
              ..selection = TextSelection.collapsed(offset: binaryInput.length),
            onChanged: (val) => convertFromInput(val, ConversionSystem.binary),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Binary',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00FF00)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // TextField Hex
          TextField(
            controller: TextEditingController(text: hexInput)
              ..selection = TextSelection.collapsed(offset: hexInput.length),
            onChanged: (val) => convertFromInput(val, ConversionSystem.hex),
            keyboardType: TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Hex',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00FF00)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // TextField BCD
          TextField(
            controller: TextEditingController(text: bcdInput)
              ..selection = TextSelection.collapsed(offset: bcdInput.length),
            onChanged: (val) => convertFromInput(val, ConversionSystem.bcd),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'BCD',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00FF00)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Nút Reset
          ElevatedButton(
            onPressed: resetConverter,
            child: const Text('Xóa hết'),
          ),
        ],
      ),
    );
  }
}

/// Widget nút bấm dùng chung cho Basic
class CalcButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CalcButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isOperator = _isOperator(text);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isOperator ? const Color(0xFF00FF00) : Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  bool _isOperator(String x) {
    return (x == '+' || x == '-' || x == '×' || x == '÷' || x == '%' || x == '=');
  }
}