# inventory_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


* có lỗi cần fix: 
    - lỗi góc trên bên phải bị dòng chữ đỏ debug
    => thêm debugShowCheckedModeBanner: false , // tắt banner debug trong hàm build đầu tiên


* fix lỗi Launching lib\main.dart on sdk gphone64 x86 64 in debug mode...
Your project is configured with Android NDK 26.3.11579264, but the following plugin(s) depend on a different Android NDK version:
- mobile_scanner requires Android NDK 27.0.12077973
- shared_preferences_android requires Android NDK 27.0.12077973
Fix this issue by using the highest Android NDK version (they are backward compatible).
Add the following to D:\zip\UTE\TT_EMBEDED_SYSTEM\MAIN_FOLDER\week3\inventory_app\android\app\build.gradle.kts:

    android {
        ndkVersion = "27.0.12077973"
        ...
bằng các trong android/app/build.gradle.kts thay dòng ndkVersion = flutter.ndkVersion
bằng dòng ndkVersion = "27.0.12077973" trong android{...}

* import các file thư viện vào pubspec.yaml
  cupertino_icons: ^1.0.8
  mobile_scanner: ^6.0.10
  shared_preferences: ^2.5.3
  uuid: ^3.0.6
  provider: ^6.1.4
  qr_flutter: ^4.1.0