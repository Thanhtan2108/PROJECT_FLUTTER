// main.dart - File chính cho ứng dụng Nhật ký trồng trọt và Truy xuất nguồn gốc

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_lib;
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhật Ký Trồng Trọt',
      debugShowCheckedModeBanner: false, // Loại bỏ nhãn DEBUG
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Ứng dụng Nông Nghiệp\n'),
        title: Text('Ngô Thanh Tân - Trịnh Thiết Trình'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlantingDiaryPage()),//truy cập vào page nhật ký trồng trọt
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: Text('Nhật Ký Trồng Trọt'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanPage()), //truy cập vào page quét mã QR
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: Text('Truy Xuất Nguồn Gốc'),
            ),
          ],
        ),
      ),
    );
  }
}

// Màn hình Nhật ký trồng trọt
class PlantingDiaryPage extends StatefulWidget {
  const PlantingDiaryPage({super.key});

  @override
  _PlantingDiaryPageState createState() => _PlantingDiaryPageState();
}

class _PlantingDiaryPageState extends State<PlantingDiaryPage> {
  List<PlantDiary> diaries = []; // LOAD Danh sách nhật ký trồng trọt từ database

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  _loadDiaries() async {
    final diaryList = await DatabaseHelper.instance.getDiaries();
    setState(() {
      diaries = diaryList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhật Ký Trồng Trọt'),
      ),
      body: diaries.isEmpty
          ? Center(
              child: Text('Chưa có nhật ký nào. Hãy thêm nhật ký mới!'), //Nếu danh sách database trống 
            )
          : ListView.builder(
              itemCount: diaries.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(diaries[index].plantName), //title theo tên đã đặt trong danh sách
                    subtitle: Text('Ngày tạo: ${DateFormat('dd/MM/yyyy').format(diaries[index].createdAt)}'),
                    onTap: () {
                      Navigator.push( //Lệnh này chuyển sang màn hình chi tiết của nhật ký .
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryDetailPage(diary: diaries[index]),
                        ),
                      ).then((_) => _loadDiaries());
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.qr_code), //icon QR
                      onPressed: () {
                        Navigator.push( // nháy vào nút icon ra màn hình mới tạo mã QR 
                          context,
                          MaterialPageRoute(
                            builder: (context) => GenerateQRPage(diary: diaries[index]),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton( //phần còn lại của body là nút thêm nhật ký mới
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDiaryPage()),
          ).then((_) => _loadDiaries());
        }, //Khi nhấn nút +, ứng dụng sẽ chuyển sang trang nhập thông tin để tạo nhật ký mới.
        tooltip: 'Thêm nhật ký mới',
        child: Icon(Icons.add),
      ),
    );
  }
}

// Màn hình thêm nhật ký mới
class AddDiaryPage extends StatefulWidget {
  const AddDiaryPage({super.key});

  @override
  _AddDiaryPageState createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plantNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _facilityController = TextEditingController();

  @override
  Widget build(BuildContext context) { // hàm tạo giao diện của một widget
    return Scaffold(
      appBar: AppBar( //thanh tiêu đề Appbar
        title: Text('Thêm nhật ký mới'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form( //Form là widget cha, cần một child để chứa nội dung.
          key: _formKey,
          child: SingleChildScrollView( //SingleChildScrollView là để cuộn nếu nội dung dài.
            child: Column( //Column là widget hiển thị các widget con theo chiều dọc.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[ //Column dùng children vì nó có thể chứa nhiều widget.
                TextFormField(
                  controller: _plantNameController,
                  decoration: InputDecoration(
                    labelText: 'Giống cây',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giống cây';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Địa điểm sản xuất',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa điểm sản xuất';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _facilityController,
                  decoration: InputDecoration(
                    labelText: 'Cơ sở sản xuất',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập cơ sở sản xuất';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) { //Nếu form hợp lệ thì sẽ tạo một đối tượng PlantDiary mới và thêm vào database
                        PlantDiary newDiary = PlantDiary(
                          id: 0,
                          plantName: _plantNameController.text,
                          location: _locationController.text,
                          facility: _facilityController.text,
                          createdAt: DateTime.now(),
                        );
                        await DatabaseHelper.instance.insertDiary(newDiary);
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text('Tạo nhật ký'), // được tạo bằng ElevatedButton
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Màn hình chi tiết nhật ký
class DiaryDetailPage extends StatefulWidget {
  final PlantDiary diary;

  const DiaryDetailPage({super.key, required this.diary});

  @override
  _DiaryDetailPageState createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadActivities();
  }

  _loadActivities() async {
    final activitiesList = await DatabaseHelper.instance.getActivities(widget.diary.id);
    setState(() {
      activities = activitiesList;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary.plantName), // tên đi theo tên của cây trồng
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Chăm sóc'),
            Tab(text: 'Thu hoạch'),
            Tab(text: 'Bảo quản'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityList('CARE'),
          _buildActivityList('HARVEST'),
          _buildActivityList('STORAGE'),
        ],
      ),
//Nếu là tab "Chăm sóc" (index = 0), thì loại hoạt động là "CARE".
//Nếu là tab "Thu hoạch" (index = 1), thì loại hoạt động là "HARVEST".
//Nếu là tab "Bảo quản" (index = 2), thì loại hoạt động là "STORAGE".
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String activityType = 'CARE';
          switch (_tabController.index) {
            case 0:
              activityType = 'CARE';
              break;
            case 1:
              activityType = 'HARVEST';
              break;
            case 2:
              activityType = 'STORAGE';
              break;
          }
          
          if (activityType == 'CARE') {
            _showCareActivityOptions();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddActivityPage(
                  diaryId: widget.diary.id,
                  activityType: activityType,
                  specificActivity: '',
                ),
              ),
            ).then((_) => _loadActivities());
          }
        },
        tooltip: 'Thêm hoạt động mới',
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCareActivityOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.eco),
                title: Text('Chăm sóc chung'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddActivity('CARE', 'Chăm sóc chung'); //dẫn đến màn hình thêm hoạt động với loại hoạt động là "CARE" và tiêu đề là "Chăm sóc chung".
                },
              ),
              ListTile(
                leading: Icon(Icons.compost),
                title: Text('Bón phân'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddActivity('CARE', 'Bón phân');
                },
              ),
              ListTile(
                leading: Icon(Icons.water_drop),
                title: Text('Tưới nước'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddActivity('CARE', 'Tưới nước');
                },
              ),
              ListTile(
                leading: Icon(Icons.science),
                title: Text('Phun thuốc'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddActivity('CARE', 'Phun thuốc');
                },
              ),
            ],
          ),
        );
      },
    );
  }
//Hàm _navigateToAddActivity có mục đích điều hướng người dùng đến màn hình nhập hoạt động 
// truyền các thông tin cần thiết để thêm một hoạt động vào nhật ký trồng trọt.
  void _navigateToAddActivity(String activityType, String specificActivity) { // hàm xử lí khi được gọi ở bên trên
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityPage(
          diaryId: widget.diary.id, //Truyền ID của nhật ký
          activityType: activityType, //Truyền loại hoạt động (ví dụ: "Thu hoạch")
          specificActivity: specificActivity, //Truyền tên hoạt động cụ thể
        ),
      ),
    ).then((_) => _loadActivities());
  }
//đây là màn hình hiển thị khi chưa có hoạt động nào trong các tab chăm sóc , thu hoạch , bảo quản
  Widget _buildActivityList(String type) {
    final filteredActivities = activities.where((a) => a.type == type).toList();
    
    if (filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Chưa có hoạt động nào. Hãy thêm hoạt động mới!'),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Thêm hoạt động'),
              onPressed: () {
                if (type == 'CARE') {
                  _showCareActivityOptions();
                } else {
                  _navigateToAddActivity(type, '');
                }
              },
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        Activity activity = filteredActivities[index];
        return Card(
          margin: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề hoạt động cụ thể nếu có
              if (activity.specificActivity != null && activity.specificActivity!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Text(
                    activity.specificActivity!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(activity.dateTime),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(activity.description),
              ),
              if (activity.imagePath != null && activity.imagePath!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Image.file(
                    File(activity.imagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Màn hình thêm hoạt động mới
class AddActivityPage extends StatefulWidget {
  final int diaryId;
  final String activityType;
  final String specificActivity;

  const AddActivityPage({super.key, required this.diaryId, required this.activityType, required this.specificActivity});

  @override
  _AddActivityPageState createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _imagePath;

  String get _activityTypeText {
    switch (widget.activityType) {
      case 'CARE':
        return widget.specificActivity.isNotEmpty ? widget.specificActivity : 'chăm sóc';
      case 'HARVEST':
        return 'thu hoạch';
      case 'STORAGE':
        return 'bảo quản';
      default:
        return '';
    }
  }
//Chụp ảnh bằng camera, lưu dưới dạng file và cập nhật đường dẫn ảnh vào biến _imagePath.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(image.path).copy('${directory.path}/$fileName');
      
      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }
//Mục đích: Hiển thị Date Picker để người dùng chọn ngày.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
// Hiển thị Time Picker để người dùng chọn giờ.
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
//Chi tiết body them hoạt động
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm hoạt động $_activityTypeText'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả hoạt động',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả hoạt động';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Ngày',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectTime(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Giờ',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
                        Icon(Icons.access_time, size: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Chụp ảnh'),
                      ),
                      SizedBox(height: 16),
                      if (_imagePath != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        DateTime activityDateTime = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedTime.hour,
                          _selectedTime.minute,
                        );
                        
                        Activity newActivity = Activity(
                          id: 0,
                          diaryId: widget.diaryId,
                          type: widget.activityType,
                          specificActivity: widget.specificActivity,
                          description: _descriptionController.text,
                          dateTime: activityDateTime,
                          imagePath: _imagePath,
                        );
                        
                        await DatabaseHelper.instance.insertActivity(newActivity);
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text('Lưu'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Màn hình tạo mã QR
class GenerateQRPage extends StatelessWidget {
  final PlantDiary diary; //Đây là đối tượng nhật ký cây trồng được truyền vào màn hình này.
  /*
Nó chứa các thông tin như:
diary.id: ID nhật ký
plantName: Tên cây
location: Địa điểm trồng
facility: Cơ sở sản xuất
  */

//Tạo một Map chứa thông tin nhật ký, sau đó mã hóa JSON để thành một chuỗi (qrString) – chính là nội dung để tạo mã QR.

  const GenerateQRPage({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> qrData = {
      'diaryId': diary.id,
      'plantName': diary.plantName,
      'location': diary.location,
      'facility': diary.facility,
    };

    String qrString = jsonEncode(qrData);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mã QR Truy xuất nguồn gốc'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mã QR cho ${diary.plantName}', //lấy tên giống cây
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            QrImageView( // Hiển thị mã QR lên màn hình.
              data: qrString,
              version: QrVersions.auto,
              size: 250,
            ),
            SizedBox(height: 20),
            Text('Quét mã QR này để xem thông tin về sản phẩm'),
          ],
        ),
      ),
    );
  }
}

// Màn hình quét mã QR
class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String? _scanResult; // Added field to store scan result
  PlantDiary? _diary;
  List<Activity> _activities = [];
  bool _isLoading = false;
  final MobileScannerController controller = MobileScannerController();
/*
_scanResult: để lưu chuỗi kết quả đọc được từ mã QR.
_diary: đối tượng PlantDiary lấy từ database theo ID trong mã QR.
_activities: danh sách hoạt động liên quan tới nhật ký đó.
_isLoading: cờ để hiển thị trạng thái "đang tải".
controller: điều khiển camera của trình quét.
*/
  Future<void> _processQrCode(String barcodeScanRes) async { //Đây là hàm xử lý khi quét được mã QR:
    if (barcodeScanRes.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _scanResult = barcodeScanRes;
      });

      try {
        Map<String, dynamic> qrData = jsonDecode(barcodeScanRes); // để giải mã chuỗi QR (dạng JSON).
        if (qrData.containsKey('diaryId')) {
          int diaryId = qrData['diaryId'];
          PlantDiary? diary = await DatabaseHelper.instance.getDiary(diaryId);
          List<Activity> activities = await DatabaseHelper.instance.getActivities(diaryId);

          setState(() {
            _diary = diary;
            _activities = activities;
          });
        }
      } catch (e) {
        print("Error parsing QR code: $e");
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Truy Xuất Nguồn Gốc'),
        actions: [
          IconButton(
            icon: Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _diary == null
              ? Stack(
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: (barcode, args) {
                        _processQrCode(barcode.rawValue!);
                      },
                    ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green.withOpacity(0.5),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 250,
                        width: 250,
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phần hiển thị kết quả quét (giữ nguyên code cũ)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thông tin sản phẩm',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Divider(),
                                Text('Giống cây: ${_diary!.plantName}'),
                                SizedBox(height: 8),
                                Text('Địa điểm sản xuất: ${_diary!.location}'),
                                SizedBox(height: 8),
                                Text('Cơ sở sản xuất: ${_diary!.facility}'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nhật ký trồng trọt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ..._buildActivityGroups(),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _diary = null;
                                _activities = [];
                              });
                            },
                            icon: Icon(Icons.qr_code_scanner),
                            label: Text('Quét mã QR khác'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  List<Widget> _buildActivityGroups() {
    Map<String, List<Activity>> groupedActivities = {
      'CARE': _activities.where((a) => a.type == 'CARE').toList(),
      'HARVEST': _activities.where((a) => a.type == 'HARVEST').toList(),
      'STORAGE': _activities.where((a) => a.type == 'STORAGE').toList(),
    };

    List<Widget> widgets = [];

    if (groupedActivities['CARE']!.isNotEmpty) {
      widgets.add(_buildActivitySection('Chăm sóc', groupedActivities['CARE']!));
    }

    if (groupedActivities['HARVEST']!.isNotEmpty) {
      widgets.add(_buildActivitySection('Thu hoạch', groupedActivities['HARVEST']!));
    }

    if (groupedActivities['STORAGE']!.isNotEmpty) {
      widgets.add(_buildActivitySection('Bảo quản', groupedActivities['STORAGE']!));
    }

    if (widgets.isEmpty) {
      widgets.add(
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Chưa có hoạt động nào được ghi lại.'),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildActivitySection(String title, List<Activity> activities) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            ...activities.map((activity) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activity.specificActivity != null && activity.specificActivity!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          activity.specificActivity!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: Colors.green,
                          ),
                        ),
                      ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(activity.dateTime),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(activity.description),
                    ),
                    if (activity.imagePath != null && activity.imagePath!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Image.file(
                          File(activity.imagePath!),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Divider(),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

// Lớp cơ sở dữ liệu
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('planting_diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = path_lib.join(dbPath, filePath); // Sử dụng path_lib thay vì join trực tiếp

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE diaries(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plant_name TEXT NOT NULL,
      location TEXT NOT NULL,
      facility TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE activities(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      diary_id INTEGER NOT NULL,
      type TEXT NOT NULL,
      specific_activity TEXT,
      description TEXT NOT NULL,
      date_time TEXT NOT NULL,
      image_path TEXT,
      FOREIGN KEY (diary_id) REFERENCES diaries (id) ON DELETE CASCADE
    )
    ''');
  }

  // Nhật ký trồng trọt CRUD
  Future<int> insertDiary(PlantDiary diary) async {
    final db = await instance.database;
    return await db.insert('diaries', diary.toMap());
  }

  Future<List<PlantDiary>> getDiaries() async {
    final db = await instance.database;
    final result = await db.query('diaries', orderBy: 'created_at DESC');
    return result.map((map) => PlantDiary.fromMap(map)).toList();
  }

  Future<PlantDiary?> getDiary(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'diaries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PlantDiary.fromMap(maps.first);
    }
    return null;
  }

  // Hoạt động CRUD
  Future<int> insertActivity(Activity activity) async {
    final db = await instance.database;
    return await db.insert('activities', activity.toMap());
  }

  Future<List<Activity>> getActivities(int diaryId) async {
    final db = await instance.database;
    final result = await db.query(
      'activities',
      where: 'diary_id = ?',
      whereArgs: [diaryId],
      orderBy: 'date_time DESC',
    );
    return result.map((map) => Activity.fromMap(map)).toList();
  }

  // Đóng kết nối cơ sở dữ liệu
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// Lớp đối tượng Nhật ký trồng trọt
class PlantDiary {
  final int id;
  final String plantName;
  final String location;
  final String facility;
  final DateTime createdAt;

  PlantDiary({
    required this.id,
    required this.plantName,
    required this.location,
    required this.facility,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'plant_name': plantName,
      'location': location,
      'facility': facility,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static PlantDiary fromMap(Map<String, dynamic> map) {
    return PlantDiary(
      id: map['id'],
      plantName: map['plant_name'],
      location: map['location'],
      facility: map['facility'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// Lớp đối tượng Hoạt động
class Activity {
  final int id;
  final int diaryId;
  final String type; // CARE, HARVEST, STORAGE
  final String? specificActivity; // Bón phân, Tưới nước, Phun thuốc, ...
  final String description;
  final DateTime dateTime;
  final String? imagePath;

  Activity({
    required this.id,
    required this.diaryId,
    required this.type,
    this.specificActivity,
    required this.description,
    required this.dateTime,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'diary_id': diaryId,
      'type': type,
      'specific_activity': specificActivity,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'image_path': imagePath,
    };
  }

  static Activity fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      diaryId: map['diary_id'],
      type: map['type'],
      specificActivity: map['specific_activity'],
      description: map['description'],
      dateTime: DateTime.parse(map['date_time']),
      imagePath: map['image_path'],
    );
  }
}