# Xây Dựng App Điều Khiển Nhiều Thiết Bị Trong Nhiều Phòng Có Liên Kết Với DB

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## [Xem trước 1 vài định nghĩa, khái niệm quan trọng trong Flutter tại đây](./Explain/DEFINE.md)

## Liên Kết Với Database

[Xem hướng dẫn liên kết tại đây](https://www.youtube.com/watch?v=dyYiqlKBBKM)

### Liên kết DB với code

#### Trong main.dart, thực hiện

```dart
import 'package:firebase_core/firebase_core.dart';
```

và đoạn code ở đầu chương trình để khởi tạo kết nối với Fireabse

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Chuẩn bị engine
  await Firebase.initializeApp(); // Bắt đầu kết nối Firebase, đợi hoàn tất
  runApp(const MyApp()); // Khi mọi thứ sẵn sàng, chạy giao diện app
}
```

**[Đọc thêm giải thích trong main.dart để hiểu rõ hơn về file main.dart](./Explain/ExplainMain.md)**

**[Hoặc chỉ đọc giải thích liên quan đến Firebase trong main](./Explain/ExplainMain.md#6-ý-nghĩa-các-phương-thức-trong-đoạn-code-hàm-main)**

#### Trong các file.dart thư viện muốn kết nối với firebase, thực hiện

```dart
import 'package:firebase_database/firebase_database.dart';
```

##### Tham chiếu đến đường dẫn trên Database

Ở đầu class của file.dart thành phần, dùng lệnh để chỉ rõ đường dẫn trên firebase để truy cập vào nơi lưu datadata:

```dart
final DatabaseReference _variablePath = FirebaseDatabase.instance.ref('Đường dẫn đến nơi muốn lưu data trên firebase realtime',);
```

###### 🧩 1. FirebaseDatabase là gì?

- `FirebaseDatabase` là lớp đại diện cho `Firebase Realtime Database` trong Flutter.

- Nó là “cửa ngõ” để bạn làm mọi thứ với `database`:

  - đọc dữ liệu

  - ghi dữ liệu

  - lắng nghe thay đổi

  - lấy `reference` đến một vị trí trong `tree của database`

###### 🧩 2 .instance là gì?

- `instance` = `Singleton pattern`.

- Firebase sử dụng singleton để đảm bảo:

  - Ứng dụng của bạn chỉ có `1` kết nối tới `Realtime Database`, không bị mở nhiều kết nối lãng phí tài nguyên.

  - `FirebaseDatabase.instance` nghĩa là:

    - Lấy ra đối tượng `FirebaseDatabase` duy nhất trong ứng dụng (chỉ tạo duy nhất 1 đối tượng)

    - Không tạo mới mỗi lần bạn gọi

    - Tưởng tượng nó như:

    ```dart
    FirebaseDatabase database = FirebaseDatabase.instance;
    ```

###### 🧩 3 .ref() là gì?

- `.ref()` viết đầy đủ là: `DatabaseReference ref()`

- Nó trả về một `DatabaseReference` — là một "điểm" trong `cây Realtime Database`.

- Ví dụ database của bạn:

```text
root
 ├── users
 ├── products
 └── settings
```

- Khi bạn gọi:

```dart
FirebaseDatabase.instance.ref()
```

→ bạn đang lấy reference đến root (/) của database.

\* **📌 Bạn có thể đi sâu hơn bằng cách truyền path:**

- Lấy đến node con:

```dart
FirebaseDatabase.instance.ref('users');
```

- Lấy đến node cụ thể:

```dart
FirebaseDatabase.instance.ref('users/user123');
```

##### Set/Get data Firebase

Tất cả việc “lấy data từ database về” đều được thực hiện thông qua `StreamBuilder<DatabaseEvent>`. Đây chính là nơi app lắng nghe dữ liệu thay đổi từ Firebase và cập nhật giao diện theo thời gian thực.

###### Get data từ firebase về app

Trong `StreamBuilder<DatabaseEvent>` thực hiện đoạn code sau để lấy dữ liệu đúng với kiểu dữ liệu của đối tượng

Tổng quát

```dart
final value = snapshot.data?.snapshot.value;

final int intValue = int.tryParse(value.toString()) ?? 0;
final double doubleValue = double.tryParse(value.toString()) ?? 0.0;
final bool boolValue = value.toString() == "true" || value.toString() == "1";
final String stringValue = value.toString();
```

Áp dụng và tinh chỉnh nhẹ trong code, Lấy dữ liệu dạng bool từ firebase

```dart
StreamBuilder<DatabaseEvent>(
  stream: _variablePath.child('đối tượng cần lấy data trên Firebase').onValue, // Lấy dữ liệu của đối tượng từ Firebase
  builder: (context, snapshot) {
    final bool variableState = (snapshot.data?.snapshot.value ?? 0) == 1 ; // Dữ liệu nhận về
  },
)
```

**Phân tích đoạn code lấy dữ liệu dạng bool:**

```dart
final bool variableState = (snapshot.data?.snapshot.value ?? 0) == 1 ;

phân tích rõ ra là:
final data = snapshot.data?.snapshot.value;
final value = data ?? 0;
final bool isOn = value == 1;
```

Cụ thể:

🧩 1️⃣ Phân tích đoạn code

```dart
final bool isOn = (snapshot.data?.snapshot.value ?? 0) == 1;
```

Chúng ta đang quan tâm đến phần này:

```dart
(snapshot.data?.snapshot.value ?? 0)
```

🧠 2️⃣ Trường hợp 1: snapshot.data `null`

Nếu `snapshot.data` là `null`, thì toán tử `?.` sẽ dừng ở đó và trả về `null`.

Khi đó biểu thức này:

```dart
snapshot.data?.snapshot.value
```

→ trả về `null`

Sau đó `?? 0` sẽ được kích hoạt:

```dart
(null ?? 0) → 0
```

Kết quả cuối cùng của toàn biểu thức:

```dart
(0 == 1) → false
```

✅ Không lỗi, isOn = false.

🧠 3️⃣ Trường hợp 2: `snapshot.data` `không null`, và `snapshot.value = null`

```dart
snapshot.data?.snapshot.value → null
(null ?? 0) → 0
(0 == 1) → false
```

✅ Kết quả vẫn an toàn, isOn = false.

🧠 4️⃣ Trường hợp 3: `snapshot.value không null`

Giả sử Firebase có dữ liệu, ví dụ:

| Giá trị Firebase (`snapshot.value`) | Kết quả | Diễn giải |
| --- | --- | --- |
| `1` | ✅ `true` | Switch đang bật |
| `0` | ✅ `false` | Switch đang tắt |
| `"1"` (chuỗi) | ✅ `true` | Chuỗi "1" được chuyển thành số 1 |
| `true` | ⚠️ có thể lỗi | Kiểu bool không thể so sánh trực tiếp với số 1 |
| `{}` hoặc `[]` | ⚠️ lỗi kiểu dữ liệu | Không thể so sánh object/array với 1 |

🧩 5️⃣ Diễn giải logic chính xác khi `snapshot.value` có dữ liệu

Giả sử:

```dart
snapshot.data?.snapshot.value = 1
```

Thì:

```dart
(snapshot.data?.snapshot.value ?? 0) == 1
→ (1 ?? 0) == 1
→ 1 == 1
→ true
```

✅ Kết quả cuối cùng:

isOn = true;

🧩 6️⃣ Nếu `snapshot.value` `không null` nhưng kiểu dữ liệu khác

Trường hợp Firebase lưu giá trị kiểu bool:

```dart
snapshot.value = true;
```

Thì:

```dart
(true ?? 0) == 1
```

→ true == 1 → ❌ Sai (vì true và 1 khác kiểu)

Cách khắc phục:

```dart
final bool isOn = snapshot.data?.snapshot.value == true;
```

hoặc

```dart
final bool isOn = (snapshot.data?.snapshot.value == 1 || snapshot.data?.snapshot.value == true);
```

Lấy dữ liệu có thể thay đổi kiểu từ firebase

```dart
StreamBuilder<DatabaseEvent>(
  stream: _variablePath.child('đối tường cần lấy data trên Firebase').onValue, // Lấy dữ liệu
  builder: (context, snapshot) {
    final dynamic value = snapshot.data?.snapshot.value ?? 0;
  },
)
```

Sau khi lấy dữ liệu về và lưu vào các biến tương ứng, có thể dùng các biến này (variableState, value) để thực hiện các chức năng điều khiển trên App.

### Set data từ App lên Firebase

Có nhiều cách để gửi data từ App lên firebase như:

| Mục đích                                 | Lệnh dùng            | Mô tả                                              |
| ---------------------------------------- | -------------------- | -------------------------------------------------- |
| Ghi (thay thế toàn bộ giá trị tại path)  | `.set(value)`        | Ghi dữ liệu mới, xóa dữ liệu cũ tại node đó        |
| Cập nhật một phần (giữ lại dữ liệu khác) | `.update({...})`     | Cập nhật một số trường con mà không ghi đè toàn bộ |
| Thêm phần tử mới (tạo key tự động)       | `.push().set(value)` | Dùng để thêm đối tượng mới vào danh sách           |
| Xóa dữ liệu                              | `.remove()`          | Xóa giá trị tại path đó                            |

Nhưng áp dụng trong code, thực hiện phương thức set để gửi dữ liệu, cập nhật toàn bộ dữ liệu cho đối tượng luôn.

```dart
_variablePath.child('đối tượng cần thay thế data trên Firebase').set(value);
```

## Giao diện từng phòng

### Giao diện Drawer

![ListViewDrawer](./assets/images/ListviewDrawer.png)

### Giao diện Bedroom

![Bedroomm](./assets/images/Bedroom.png)

![FirebaseBedroom](./assets/images/firebaseBedroom.png)

### Giao diện Livingroom

![Livingroom](./assets/images/Livingroom.png)

![FirebaseLivingroom](./assets/images/firebaseLivingroom.png)

### Giao diện Kitchen

![Kitchen](./assets/images/Kitchen.png)

![FirebaseKitchen](./assets/images/firebaseKitchen.png)

## Ẩn file google-services.json để không lộ key secret

Nếu chưa từng `git add` vào repo, chỉ cần thêm lệnh

```dart
/android/app/google-services.json
```

vào file `.gitignore`, sau đó thực hiện các lệnh

```bash
git add .
git commit -m 'note message'
git push origin <branch name>
```

file `google-services.json` sẽ bị ẩn hoàn toàn khỏi repo kể cả trên máy local và trên Github

### Dùng cách như trên, nó sẽ hide cả file trên cả repo local, tốt nhất là tạo 1 file mẫu để khi ai clone về thì tự set file `google-services.json` của mình vào `android/app/`
