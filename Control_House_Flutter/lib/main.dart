// Link DB: https://console.firebase.google.com/project/manager-device-in-room/database/manager-device-in-room-default-rtdb/data/~2F?fb_gclid=Cj0KCQjw0NPGBhCDARIsAGAzpp3Cs1n7D_yJ2dhnCUKxyBl5iLDx2RZvkhS-XNgCl4ShmXXGVNL1EDcaAtKuEALw_wcB

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login/login.dart';

// **Mọi thành phần giao diện đều là widget**

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Chuẩn bị engine
  await Firebase.initializeApp(); // Bắt đầu kết nối Firebase, đợi hoàn tất
  runApp(const MyApp()); // Khi mọi thứ sẵn sàng, chạy giao diện app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // phương thức build là phương thức trừu tường hóa nên cần ghi đè
  @override
  // phương thức build có tác dụng xây dựng UI cho 1 widget
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {'login': (context) => mylogin()},
    );
  }
}
