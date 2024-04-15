import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:get/get.dart';


class GooglePlacesService {
  final GooglePlace googlePlace;

  GooglePlacesService(String apiKey) : googlePlace = GooglePlace(apiKey);

  Future<List<AutocompletePrediction>> getPlacePredictions(String input) async {
    try {
      var result = await googlePlace.autocomplete.get(input);
      return result?.predictions ?? [];
    } catch (error) {
      return [];
    }
  }
}


class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool isSubmitting = false; // Add this line
  int totalAmount = 0; // Define totalAmount here
  final List<String> imageUrls = [
    'https://doitac.28go.vn/booking-banner-1.png',
    'https://doitac.28go.vn/booking-banner-2.png',
    'https://doitac.28go.vn/booking-banner-3.png',
  ];

  LatLng? selectedLocation;
  LatLng defaultLocation = LatLng(20.8337371, 105.346488);
  String statusPayment = 'Chưa thanh toán';

  // New function for opening map picker for recipient address
  Future<void> _openMapPickerForRecipient() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        LatLng? tempSelectedLocation;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                width: double.maxFinite,
                height: 300.0,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    controller.animateCamera(CameraUpdate.newLatLng(defaultLocation));
                  },
                  initialCameraPosition: CameraPosition(
                    target: defaultLocation,
                    zoom: 17.0,
                  ),
                  onTap: (LatLng location) {
                    setState(() {
                      tempSelectedLocation = location;
                    });
                  },
                  markers: tempSelectedLocation != null
                      ? {
                    Marker(
                      markerId: MarkerId('selectedLocation'),
                      position: tempSelectedLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  }
                      : {},
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Đóng'),
                ),
                TextButton(
                  onPressed: () async {
                    if (tempSelectedLocation != null) {
                      List<Placemark> placemarks = await placemarkFromCoordinates(
                        tempSelectedLocation!.latitude,
                        tempSelectedLocation!.longitude,
                      );

                      Placemark selectedPlacemark = placemarks.first;
                      String street = selectedPlacemark.street ?? '';
                      String subLocality = selectedPlacemark.subLocality ?? '';
                      String locality = selectedPlacemark.locality ?? '';
                      String postalCode = selectedPlacemark.postalCode ?? '';
                      String country = selectedPlacemark.country ?? '';

                      String address = [
                        if (street.isNotEmpty) street,
                        if (subLocality.isNotEmpty) subLocality,
                        if (locality.isNotEmpty) locality,
                        if (postalCode.isNotEmpty) postalCode,
                        if (country.isNotEmpty) country,
                      ].join(', ');

                      recipientAddressController.text = address;
                      selectedLocation = tempSelectedLocation;
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Xác nhận chọn vị trí'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark currentPlacemark = placemarks.first;

      String street = currentPlacemark.street ?? '';
      String subLocality = currentPlacemark.subLocality ?? '';
      String locality = currentPlacemark.locality ?? '';
      String postalCode = currentPlacemark.postalCode ?? '';
      String country = currentPlacemark.country ?? '';

      // Join address components with commas
      String fullAddress = [
        if (street.isNotEmpty) street,
        if (subLocality.isNotEmpty) subLocality,
        if (locality.isNotEmpty) locality,
        if (postalCode.isNotEmpty) postalCode,
        if (country.isNotEmpty) country,
      ].join(', ');

      setState(() {
        senderAddressController.text = fullAddress.trim().isEmpty
            ? 'Không thể lấy được vị trí'
            : fullAddress.trim();
      });
    } catch (e) {
      print('Lỗi trong khi lấy vị trí: $e');
    }
  }

  final GooglePlacesService senderPlacesService =
  GooglePlacesService('AIzaSyAWMhT8dWVXhXV1fRf_ijQd-aUfkHMOdag');
  TextEditingController senderAddressController = TextEditingController();
  List<AutocompletePrediction> senderPredictions = [];

  final GooglePlacesService recipientPlacesService =
  GooglePlacesService('AIzaSyAWMhT8dWVXhXV1fRf_ijQd-aUfkHMOdag');
  TextEditingController recipientAddressController = TextEditingController();
  List<AutocompletePrediction> recipientPredictions = [];

  CarouselController _carouselController = CarouselController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController codController = TextEditingController(text: '0');
  TextEditingController recipientPhoneController = TextEditingController();
  TextEditingController recipientNameController = TextEditingController();
  TextEditingController deliveryNoteController = TextEditingController(); // Added for delivery note

  @override
  Widget build(BuildContext context) {
    // Helper function to format currency
    String formatCurrency(int amount) {
      final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
      return formatCurrency.format(amount.toDouble());
    }


    Future<void> _showQuickPayDialog(BuildContext context) async {
      final String userId = (Get.find<UserController>().userInfoModel?.id?.toString()) ?? 'TAIKHOANKHACH';

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thanh toán nhanh đơn hàng'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://qr.sepay.vn/img?acc=28000028&bank=Techcombank&amount=$totalAmount&template=compact&des=28GO $userId',
                  height: 250.0,
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Nội dung: 28GO $userId',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    Text(
                      'Số tiền: ${NumberFormat('#,##0').format(totalAmount)} đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),


                    Text(
                      'Hướng dẫn thanh toán: Bạn cần phải đăng nhập, nếu bạn chưa đăng nhập hãy nhập số điện thoại trong nội dung chuyển tiền của bạn. Nếu bạn đăng nhập, hệ thống sẽ nhận diện được tài khoản của bạn và nội dung chuyển khoản, đơn hàng sẽ được xử lý thanh toán tự động.',
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),


                  ],
                ),
              ),

            ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    totalAmount = 0;
                    statusPayment = 'Chưa thanh toán';
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Thanh toán tiền mặt'),
              ),
              TextButton(
                onPressed: () {
                  // Perform the action when "Xác nhận đã thanh toán" is pressed
                  // Set the totalAmount to 0
                  setState(() {
                    totalAmount = 0;
                    statusPayment = 'Đã thanh toán. (Delivery không thu tiền khách, chỉ nhận và giao hàng. Nếu phát sinh hơn số tiền trên sẽ thu chênh lệch. Số tiền đơn hàng sẽ được thanh toán vào tài khoản của Delivery sau 3-5 phút.)';
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Xác nhận đã thanh toán chuyển khoản'),
              ),

            ],
          );
        },
      );
    }






    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt giao hàng thần tốc, đi chợ hộ'),
        toolbarHeight: 50.0, // Adjust the height as needed
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: 150.0, // Adjust the height as needed
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: imageUrls.map((url) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0), // Clip the image with the same border radius
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Họ tên người gửi hàng',
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại người gửi',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: senderAddressController,
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ lấy (gửi) hàng (Nếu đi chợ, mua đồ hộ có thể bỏ qua)',
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.orange, // Set the color to yellow-orange
                          ),
                          onPressed: () {
                            _getCurrentLocation();
                          },
                        ),
                      ),
                      onChanged: (input) async {
                        if (input.isNotEmpty) {
                          List<AutocompletePrediction>? result =
                          await senderPlacesService.getPlacePredictions(input);
                          setState(() {
                            senderPredictions = result?.toList() ?? [];
                          });
                        } else {
                          setState(() {
                            senderPredictions = [];
                          });
                        }
                      },
                    ),
                    if (senderPredictions.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: senderPredictions
                            .map(
                              (prediction) => ListTile(
                            title: Text(prediction.description ?? ''),
                            onTap: () {
                              setState(() {
                                senderAddressController.text = prediction.description ?? '';
                                senderPredictions = [];
                              });
                            },
                          ),
                        )
                            .toList(),
                      ),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: recipientNameController,
                            decoration: InputDecoration(
                              labelText: 'Họ tên người nhận',
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: recipientPhoneController,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại người nhận',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: recipientAddressController,
                            decoration: InputDecoration(
                              labelText: 'Địa chỉ nhận/trả hàng',

                            ),
                            onChanged: (input) async {
                              if (input.isNotEmpty) {
                                List<AutocompletePrediction>? result =
                                await recipientPlacesService.getPlacePredictions(input);
                                setState(() {
                                  recipientPredictions = result?.toList() ?? [];
                                });
                              } else {
                                setState(() {
                                  recipientPredictions = [];
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.map,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            _openMapPickerForRecipient();
                          },
                        ),
                      ],
                    ),

                    if (recipientPredictions.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: recipientPredictions
                            .map(
                              (prediction) => ListTile(
                            title: Text(prediction.description ?? ''),
                            onTap: () {
                              setState(() {
                                recipientAddressController.text = prediction.description ?? '';
                                recipientPredictions = [];
                              });
                            },
                          ),
                        )
                            .toList(),
                      ),
                    SizedBox(height: 8.0),

                    TextField(
                      controller: codController,
                      onChanged: (value) {
                        setState(() {
                          int codAmountValue = int.tryParse(value) ?? 0;
                          totalAmount = codAmountValue + 30000;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Số tiền thu hộ (COD) hoặc tiền ứng mua hàng',
                        hintText: '0',
                        suffixText: 'VNĐ',
                      ),
                    ),

                    SizedBox(height: 8.0),
                    TextField(
                      controller: deliveryNoteController, // New text controller for delivery note
                      decoration: InputDecoration(
                        labelText: 'Ghi chú giao, mua đồ hộ (loại sản phẩm, số lượng)',
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Center(
                      child: Text(
                        'Tổng tiền đơn hàng (+ phí vận chuyển): ${formatCurrency(totalAmount)}',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Center(
                      child: Text(
                        'Lưu ý: Phí giao hàng siêu tốc là 30.000đ/đơn hàng (áp dụng trong TP. Hòa Bình). Nếu trong trường hợp đi chợ/mua đồ hộ, số tiền mua hàng hộ sẽ được kèm theo hóa đơn mua hàng khi đội ngũ Delivery giao hàng. Trân trọng cảm ơn!',
                        style: TextStyle(
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showQuickPayDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.green, // Set the background color to green
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(99.0),
                                  bottomLeft: Radius.circular(99.0),
                                ),
                              ),
                            ),
                            icon: Icon(Icons.payment),
                            label: Text('THANH TOÁN'),
                          ),
                        ),
                        SizedBox(width: 2.0),
                        Expanded(
                          flex: 5,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                              // Validate mandatory inputs
                              if (nameController.text.isEmpty ||
                                  phoneController.text.isEmpty ||
                                  recipientNameController.text.isEmpty ||
                                  recipientPhoneController.text.isEmpty ||
                                  recipientAddressController.text.isEmpty) {
                                // Show an error message or handle as needed
                                return;
                              }

                              setState(() {
                                isSubmitting = true;
                              });

                              // Gather information from text controllers
                              String senderName = nameController.text;
                              String senderPhone = phoneController.text;
                              String senderAddress = senderAddressController.text;
                              String recipientName = recipientNameController.text;
                              String recipientPhone = recipientPhoneController.text;
                              String recipientAddress = recipientAddressController.text;
                              String codAmount = codController.text;
                              String deliveryNote = deliveryNoteController.text;


                              // Calculate the total amount
                              int codAmountValue = int.tryParse(codAmount) ?? 0;
                              int totalAmount = codAmountValue + 30000;

                              // Compose email body
                              String emailBody = '''
                                Thông tin người gửi:
                                Họ và tên: $senderName
                                Điện thoại: $senderPhone
                                Địa chỉ: $senderAddress
                                
                                Thông tin người nhận:
                                Họ và tên: $recipientName
                                Điện thoại: $recipientPhone
                                Địa chỉ: $recipientAddress
                                Ghi chú giao hàng, mua đồ hộ: $deliveryNote
                                
                                Tiền thu hộ (COD): ${formatCurrency(codAmountValue)}
                                Phí giao hàng: 30.000đ
                                Tổng tiền đơn hàng: ${formatCurrency(totalAmount)}
                                Trạng thái thanh toán: $statusPayment
                              ''';

                              // Send email
                              String username = 'anhminhduongltd@gmail.com';
                              String password = 'xivs cixl raxl hgns';

                              final smtpServer = gmail(username, password);

                              final message = Message()
                                ..from = Address(username, '28Go')
                                ..recipients.addAll(['hi@28go.vn', 'cuongngo@28go.vn', 'sonbui@28go.vn', 'hainguyen@28go.vn'])
                                ..subject = 'Đơn hàng vận chuyển hỏa tốc 28GO'
                                ..text = emailBody;

                              try {
                                await send(message, smtpServer);
                                print('Email gửi thành công');
                                // Show success message
                                _showSuccessDialog(context);
                              } catch (error) {
                                print('Lỗi trong quá trình gửi Email: $error');
                                // Show error message
                                _showErrorDialog(context);
                              } finally {
                                setState(() {
                                  isSubmitting = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.orange, // Set the background color to green
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(99.0),
                                  bottomRight: Radius.circular(99.0),
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.delivery_dining, // Replace with the fast delivery bicycle icon
                              size: 24.0, // Adjust the size as needed
                            ),
                            label: Text('ĐẶT GIAO HÀNG'),
                          ),
                        ),


                      ],
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


// Add these methods
// Helper function to show success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Đặt đơn thành công!'),
          content: Text('Đơn hàng đã được yêu cầu thành công. Đội ngũ 28Go Delivery sẽ tiếp nhận và xử lý đơn hàng của bạn trong 3-5 phút. Nếu cần hỗ trợ hãy gọi hotline: 0889.000.365 để được trợ giúp nhanh nhất!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

// Helper function to show error dialog
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lỗi rồi, hãy kiểm tra lại thông tin'),
          content: Text('Đã xảy ra lỗi trong quá trình xử lý đơn hàng.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
