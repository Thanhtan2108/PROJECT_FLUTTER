# CÁC KHÁI NIỆM TRONG FLUTTER

## Toán tử ?, ?., ??

Các toán tử `?`, `?.`, và `??` trong Dart (ngôn ngữ lập trình được sử dụng trong Flutter) được gọi là toán tử null-aware (toán tử nhận biết null). Chúng giúp bạn xử lý các giá trị có thể là null một cách an toàn và hiệu quả hơn.

- Toán tử `?`: Được sử dụng để khai báo một biến có thể nhận giá trị null. Ví dụ: `int? a;` có nghĩa là biến `a` có thể là một số nguyên hoặc null.

- Toán tử `?.`: Được sử dụng để truy cập thuộc tính hoặc phương thức của một đối tượng chỉ khi đối tượng đó không phải là null. Nếu đối tượng là null, biểu thức sẽ trả về null thay vì gây ra lỗi. Ví dụ: `obj?.property` sẽ trả về giá trị của `property` nếu `obj` không phải là null, ngược lại sẽ trả về null.

- Toán tử `??`: Được sử dụng để cung cấp một giá trị thay thế khi biểu thức bên trái là null. Ví dụ: `a ?? b` sẽ trả về giá trị của `a` nếu `a` không phải là null, ngược lại sẽ trả về giá trị của `b`.

## Future

`Future` trong Dart (và Flutter) là một đối tượng đại diện cho một giá trị sẽ có sẵn trong tương lai, thường là kết quả của một phép toán bất đồng bộ (asynchronous operation). `Future` cho phép bạn thực hiện các tác vụ mà không làm gián đoạn luồng chính của ứng dụng, chẳng hạn như tải dữ liệu từ mạng, đọc/ghi tệp, hoặc thực hiện các phép tính phức tạp.

## await

`await` là một từ khóa trong Dart được sử dụng để chờ đợi kết quả của một `Future`. Khi bạn sử dụng `await`, luồng thực thi sẽ tạm dừng tại điểm đó cho đến khi `Future` hoàn thành và trả về giá trị. Điều này giúp bạn viết mã bất đồng bộ một cách dễ đọc và dễ hiểu hơn, giống như mã đồng bộ truyền thống.

## final

`final` là một từ khóa trong Dart được sử dụng để khai báo một biến mà giá trị của nó chỉ có thể được gán một lần duy nhất. Khi bạn khai báo một biến với `final`, bạn không thể thay đổi giá trị của biến đó sau khi nó đã được khởi tạo. Tuy nhiên, nếu biến đó là một đối tượng (như danh sách hoặc bản đồ), bạn vẫn có thể thay đổi các thuộc tính hoặc phần tử bên trong đối tượng đó.

## async

`async` là một từ khóa trong Dart được sử dụng để đánh dấu một hàm là bất đồng bộ (asynchronous). Khi một hàm được đánh dấu là `async`, nó có thể sử dụng từ khóa `await` bên trong để chờ đợi các `Future`. Hàm `async` luôn trả về một `Future`, ngay cả khi bạn không trả về giá trị cụ thể nào.

## engine

`Engine` trong Flutter đề cập đến phần lõi của framework chịu trách nhiệm quản lý việc hiển thị giao diện người dùng, xử lý sự kiện, và tương tác với hệ điều hành. Engine của Flutter được viết chủ yếu bằng ngôn ngữ C++ và sử dụng thư viện đồ họa Skia để vẽ các thành phần giao diện người dùng trên màn hình. Engine này cung cấp một môi trường hiệu suất cao để chạy các ứng dụng Flutter trên nhiều nền tảng khác nhau, bao gồm iOS, Android, web và desktop. Nó xử lý các tác vụ như:

- Quản lý vòng đời ứng dụng

- Xử lý sự kiện đầu vào từ người dùng

- Quản lý bộ nhớ và tài nguyên

- Kết xuất đồ họa và hoạt hình

- `WidgetsFlutterBinding.ensureInitialized();`: Đảm bảo rằng các liên kết giữa Flutter và hệ thống nền tảng đã được khởi tạo trước khi sử dụng bất kỳ tính năng nào của Flutter, đặc biệt là khi bạn cần thực hiện các thao tác bất đồng bộ trong hàm `main()` trước khi gọi `runApp()`.

## Widget

`Widget` là thành phần cơ bản để xây dựng giao diện người dùng trong Flutter. Mọi thứ trong Flutter đều là widget, từ các thành phần đơn giản như nút bấm, văn bản, hình ảnh cho đến các bố cục phức tạp hơn.

- Mọi thứ bạn thấy trên màn hình trong Flutter đều là widget:

  - Text

  - Button

  - Image
  - Icon

  - Container

  - AppBar

  - ListView

  - Scaffold

  … thậm chí cả layout, padding, margin, animation đều là widget.

`Widget` có thể được phân loại thành hai loại chính:

- `StatelessWidget`: Là widget không có trạng thái, nghĩa là nó không thể thay đổi sau khi được tạo ra.

  - Không có trạng thái bên trong.

  - Không thay đổi sau khi được tạo.

  - UI cố định cho đến khi rebuild từ bên ngoài.

  - Dùng cho các thành phần tĩnh (static UI).

  - Ví dụ: một text, icon, header đơn giản.

- `StatefulWidget`: Là widget có trạng thái, nghĩa là nó có thể thay đổi và cập nhật giao diện dựa trên trạng thái bên trong nó.

  - Có state (trạng thái) bên trong.

  - UI có thể thay đổi khi gọi `setState()`.

  - Ví dụ:

    - Nút bấm tăng counter.

    - Form nhập dữ liệu.

    - Trang có animation thay đổi.

## UI

Giao diện người dùng (UI) trong Flutter được xây dựng bằng cách kết hợp các widget với nhau. Mỗi widget đại diện cho một phần của giao diện, và bạn có thể lồng các widget để tạo ra bố cục phức tạp hơn.

Ví dụ, bạn có thể sử dụng các widget như `Container`, `Row`, `Column`, `Stack` để tạo bố cục cho ứng dụng của mình. Bạn cũng có thể sử dụng các widget như `Text`, `Image`, `Button` để hiển thị nội dung và tương tác với người dùng.

`Scaffold` cung cấp cấu trúc cơ bản cho một màn hình trong ứng dụng Flutter, bao gồm các thành phần như `AppBar`, `Drawer`, `BottomNavigationBar` và `Body`. Nó giúp bạn dễ dàng xây dựng giao diện người dùng theo chuẩn `Material Design`.

- `AppBar` là thanh tiêu đề nằm ở đầu màn hình, thường chứa tiêu đề của trang, các nút hành động và menu điều hướng. Nó giúp người dùng nhận biết vị trí hiện tại trong ứng dụng và cung cấp các chức năng điều hướng.

- `Drawer` là một thanh điều hướng ẩn nằm bên cạnh màn hình, thường được truy cập bằng cách vuốt từ cạnh trái hoặc nhấn vào biểu tượng menu trong `AppBar`. `Drawer` chứa các liên kết đến các phần khác nhau của ứng dụng, giúp người dùng dễ dàng chuyển đổi giữa các màn hình.

- `BottomNavigationBar` là thanh điều hướng nằm ở dưới cùng của màn hình, thường chứa các biểu tượng hoặc nhãn để chuyển đổi giữa các phần chính của ứng dụng. Nó giúp người dùng dễ dàng truy cập các chức năng quan trọng mà không cần phải quay lại `Drawer` hoặc `AppBar`.

- `Body` là phần chính của màn hình, nơi bạn đặt nội dung và các widget khác để hiển thị thông tin và tương tác với người dùng. Nó có thể chứa các widget như `ListView`, `GridView`, `Column`, `Row` để tổ chức và hiển thị dữ liệu.

## MaterialApp

`MaterialApp` là một widget cấp cao trong Flutter, cung cấp cấu trúc cơ bản và các tính năng cần thiết để xây dựng ứng dụng theo phong cách `Material Design`. Nó quản lý các khía cạnh quan trọng của ứng dụng như chủ đề (theme), định tuyến (routing), tiêu đề (title) và màn hình chính (home screen).

`MaterialApp` giúp bạn dễ dàng thiết lập và quản lý các yếu tố quan trọng của ứng dụng, đồng thời cung cấp một môi trường nhất quán cho việc xây dựng giao diện người dùng theo chuẩn `Material Design`.

## Vì sao lúc thì return MaterialApp, lúc thì return Scaffold?

Trong Flutter, `MaterialApp` và `Scaffold` đều là các widget quan trọng, nhưng chúng phục vụ các mục đích khác nhau trong cấu trúc của ứng dụng.

- `MaterialApp` là widget cấp cao nhất, cung cấp cấu trúc và các tính năng cơ bản cho toàn bộ ứng dụng. Nó quản lý các khía cạnh như chủ đề (theme), định tuyến (routing), tiêu đề (title) và màn hình chính (home screen). Khi bạn sử dụng `MaterialApp`, bạn đang thiết lập môi trường tổng thể cho ứng dụng của mình.

- `Scaffold` là widget cấp thấp hơn, được sử dụng để xây dựng cấu trúc cơ bản của một màn hình cụ thể trong ứng dụng. Nó cung cấp các thành phần như `AppBar`, `Drawer`, `BottomNavigationBar` và `Body`, giúp bạn tổ chức và hiển thị nội dung trên màn hình. Khi bạn sử dụng `Scaffold`, bạn đang tạo ra bố cục và giao diện người dùng cho một trang cụ thể trong ứng dụng.

- Vì vậy, bạn thường sẽ thấy `MaterialApp` được sử dụng ở cấp cao nhất của ứng dụng, trong khi `Scaffold` được sử dụng bên trong các widget con để xây dựng giao diện người dùng cho các màn hình cụ thể. Khi bạn viết hàm `build()` trong một widget con, bạn sẽ thường trả về `Scaffold` để tạo cấu trúc cho màn hình đó, trong khi `MaterialApp` thường được trả về ở cấp cao nhất của ứng dụng để thiết lập môi trường tổng thể.

## super.key

`super.key` là một cách để truyền tham số `key` từ lớp con đến lớp cha trong Dart, đặc biệt khi bạn làm việc với các widget trong Flutter.

- `key` là một tham số tùy chọn được sử dụng để xác định duy nhất một widget trong cây widget, giúp Flutter quản lý và tối ưu hóa việc xây dựng lại giao diện người dùng. `Key` lưu trữ thông tin về vị trí của widget trong cây widget, giúp Flutter nhận biết khi nào một widget đã thay đổi hoặc cần được tái sử dụng.

- Khi bạn định nghĩa một lớp widget con, bạn có thể sử dụng `super.key` trong hàm khởi tạo của lớp con để truyền giá trị của `key` đến lớp cha (thường là `StatelessWidget` hoặc `StatefulWidget`). Điều này đảm bảo rằng `key` được xử lý đúng cách và giúp Flutter nhận biết các widget khi chúng được xây dựng lại.

## State, createState() và setState()

`State` là một khái niệm quan trọng trong Flutter, đặc biệt khi làm việc với `StatefulWidget`. Nó đại diện cho trạng thái nội bộ của một widget, bao gồm các biến và dữ liệu mà widget sử dụng để xác định cách hiển thị và hành vi của nó. Khi trạng thái thay đổi, widget có thể cập nhật giao diện người dùng để phản ánh những thay đổi đó.

`createState()` là một phương thức trong `StatefulWidget` được sử dụng để tạo và trả về một đối tượng `State` liên kết với widget đó. Đối tượng `State` chứa trạng thái và logic của widget, bao gồm các biến trạng thái và phương thức để cập nhật giao diện người dùng. Khi bạn tạo một `StatefulWidget`, bạn cần triển khai phương thức `createState()` để cung cấp đối tượng `State` tương ứng, từ đó quản lý trạng thái và hành vi của widget trong suốt vòng đời của nó. Mọi `StatefulWidget` đều cần `createState()` để Flutter biết sẽ dùng `State` nào để quản lý trạng thái. `StatelessWidget` không có `createState()` vì nó không có `state` nội bộ.

`setState()` là một phương thức quan trọng trong `StatefulWidget` dùng để thông báo cho Flutter rằng trạng thái của widget đã thay đổi và cần phải cập nhật giao diện người dùng. Khi bạn gọi `setState()`, Flutter sẽ gọi lại phương thức `build()` của widget, từ đó tạo lại giao diện dựa trên trạng thái mới. Điều này cho phép bạn thay đổi giao diện người dùng một cách động dựa trên các tương tác hoặc dữ liệu mới.

## Cách viết `class _nameState extends State<name>` có ý nghĩa

Khi bạn viết `class _nameState extends State<name>`, bạn đang định nghĩa một lớp trạng thái (`State class`) cho một `StatefulWidget` có tên là `name`. Dưới đây là ý nghĩa của từng phần trong câu lệnh này:

- `class _nameState`: Đây là định nghĩa của một lớp mới có tên `_nameState`. Dấu gạch dưới (`_`) ở đầu tên lớp cho biết rằng lớp này là riêng tư (private) và chỉ có thể được truy cập trong cùng một tệp Dart. Điều này giúp bảo vệ trạng thái của widget khỏi bị truy cập từ bên ngoài, đảm bảo tính toàn vẹn của dữ liệu.

- `extends State<name>`: Phần này chỉ ra rằng lớp `_nameState` kế thừa từ lớp `State` và liên kết với `StatefulWidget` có tên là `name`. Điều này có nghĩa là `_nameState` sẽ chứa trạng thái và logic của widget `name`. Bằng cách kế thừa từ `State<name>`, lớp `_nameState` có thể truy cập các phương thức và thuộc tính của lớp `State`, bao gồm phương thức `setState()` để cập nhật giao diện người dùng khi trạng thái thay đổi. Điều này cho phép bạn quản lý trạng thái của widget `name` một cách hiệu quả và linh hoạt trong suốt vòng đời của nó.

## Tại sao hầu như luôn thấy trong Widget build(BuildContext context) luôn có BuildContext context?

Trong Flutter, `BuildContext` là một đối tượng quan trọng được sử dụng để xác định vị trí của một widget trong cây widget (widget tree) và cung cấp thông tin về môi trường xung quanh widget đó. Khi bạn thấy `Widget build(BuildContext context)` trong một lớp widget, đặc biệt là trong các phương thức `build()` của `StatelessWidget` hoặc `StatefulWidget`, có một số lý do quan trọng tại sao `BuildContext` được truyền vào:

1. **Xác định vị trí trong cây widget**: `BuildContext` giúp xác định vị trí của widget hiện tại trong cây widget. Điều này rất quan trọng vì nó cho phép widget truy cập các thông tin liên quan đến bố cục, chủ đề (theme), và các widget cha (parent widgets) trong cây.

2. **Truy cập tài nguyên và thông tin môi trường**: Thông qua `BuildContext`, widget có thể truy cập các tài nguyên như chủ đề (theme), kích thước màn hình, và các thông tin khác liên quan đến môi trường xung quanh. Ví dụ, bạn có thể sử dụng `Theme.of(context)` để lấy thông tin về chủ đề hiện tại của ứng dụng.

3. **Tương tác với các widget cha**: `BuildContext` cho phép widget tương tác với các widget cha trong cây. Ví dụ, bạn có thể sử dụng `Navigator.of(context)` để điều hướng giữa các màn hình hoặc `Scaffold.of(context)` để truy cập các phương thức của `Scaffold` từ bên trong một widget con.

4. **Cung cấp ngữ cảnh cho việc xây dựng giao diện**: Khi phương thức `build()` được gọi, `BuildContext` cung cấp ngữ cảnh cần thiết để xây dựng giao diện người dùng một cách chính xác dựa trên vị trí và môi trường hiện tại của widget. Điều này giúp đảm bảo rằng giao diện được xây dựng đúng cách và phù hợp với các yếu tố xung quanh.

Tóm lại, `BuildContext` là một phần quan trọng của hệ thống widget trong Flutter, giúp xác định vị trí, truy cập tài nguyên, tương tác với các widget cha và cung cấp ngữ cảnh cần thiết để xây dựng giao diện người dùng một cách chính xác.
