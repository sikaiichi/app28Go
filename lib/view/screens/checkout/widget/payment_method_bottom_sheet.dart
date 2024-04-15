import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
//import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/offline_payment_button.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/payment_button_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';




Future<void> _saveQRImage(BuildContext context, String imageUrl) async {
  try {
    // Tải ảnh từ URL
    final response = await http.get(Uri.parse(imageUrl));

    // Kiểm tra xem yêu cầu đã thành công hay không
    if (response.statusCode == 200) {
      // Lấy thư mục lưu trữ ứng dụng
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;

      // Lưu ảnh vào thư mục ứng dụng
      final String fileName = 'qr_image.png';
      final File file = File('$path/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ảnh đã được lưu vào $path/$fileName.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải ảnh. Mã trạng thái: ${response.statusCode}'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xảy ra lỗi khi tải ảnh: $e'),
      ),
    );
  }
}

class PaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final double totalPrice;
  final bool isSubscriptionPackage;
  const PaymentMethodBottomSheet({
    Key? key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.totalPrice, this.isSubscriptionPackage = false, required this.isOfflinePaymentActive}) : super(key: key);

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  final JustTheController tooltipController = JustTheController();
  final String userId = (Get.find<UserController>().userInfoModel?.id?.toString() ?? 'TAIKHOANKHACH');
  @override
  void initState() {
    super.initState();

    print('-----ss-----: ${!widget.isSubscriptionPackage} || ${!Get.find<AuthController>().isGuestLoggedIn()}');
    if(!widget.isSubscriptionPackage && !Get.find<AuthController>().isGuestLoggedIn()){
      double walletBalance = Get.find<UserController>().userInfoModel!.walletBalance!;
      if(walletBalance < widget.totalPrice){
        canSelectWallet = false;
      }
      if(Get.find<OrderController>().isPartialPay){
        notHideWallet = false;
        if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'cod'){
          notHideCod = true;
          notHideDigital = false;
        } else if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'digital_payment'){
          notHideCod = false;
          notHideDigital = true;
        } else if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'both'){
          notHideCod = true;
          notHideDigital = true;
        }
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return SizedBox(
      width: 550,
      child: GetBuilder<OrderController>(builder: (orderController) {
          return GetBuilder<AuthController>(builder: (authController) {
              return Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.vertical(top: const Radius.circular(Dimensions.radiusLarge), bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusLarge : 0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
                child: Column(mainAxisSize: MainAxisSize.min, children: [

                  ResponsiveHelper.isDesktop(context) ? Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 30, width: 30,
                        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
                        child: const Icon(Icons.clear),
                      ),
                    ),
                  ) : Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 4, width: 35,
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(alignment: Alignment.center, child: Text('payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          //!widget.isSubscriptionPackage && notHideCod ? Align(alignment: Alignment.center, child: Text('choose_payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault))) : const SizedBox(height: Dimensions.paddingSizeLarge),
                          SizedBox(height: !widget.isSubscriptionPackage && notHideCod ? Dimensions.paddingSizeExtraSmall : 0),
                          Align(
                            alignment: Alignment.center,
                            child: !widget.isSubscriptionPackage && notHideCod ? Text(
                              'click_one_of_the_option_below'.tr,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                              textAlign: TextAlign.center,
                            ) : SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          ),
                          SizedBox(height: !widget.isSubscriptionPackage && notHideCod ? Dimensions.paddingSizeExtraSmall : 0),
                          GetBuilder<AuthController>(
                            builder: (walletController) {
                              return SingleChildScrollView(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  width: context.width * 0.9,
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://qr.sepay.vn/img?acc=280000000028&bank=mbbank&des=28GO $userId',
                                        width: context.width * 0.6,
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        'Hướng dẫn thanh toán: Quét mã QRCODE và nhập số tiền cần nạp. Đơn hàng nạp tiền sẽ được xử lý thanh toán tự động sau 3-5 giây từ khi bạn chuyển tiền qua hình thức quét mã QRCODE phía trên. Sau đó bạn có thể đặt đơn hàng bằng hình thức thanh toán qua Ví.',
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                        textAlign: TextAlign.center,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _saveQRImage(context, 'https://qr.sepay.vn/img?acc=280000000028&bank=mbbank&des=28GO $userId');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          // primary: Colors.blue,
                                          // onPrimary: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8), // Điều chỉnh độ cong của góc
                                            side: BorderSide(color: Colors.blue), // Thêm viền cho nút
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min, // Chỉ chiếm khoảng cách tối thiểu cần thiết
                                          children: [
                                            Text(
                                              '     Tải mã QR CODE về thiết bị   ',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(width: 4), // Khoảng cách giữa văn bản và biểu tượng
                                            Icon(Icons.download_outlined), // Biểu tượng download
                                          ],
                                        ),
                                      ),

                                      Text(
                                        '',
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Align(alignment: Alignment.center, child: Text('Bạn muốn thanh toán qua hình thức nào?'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          !widget.isSubscriptionPackage ? Row(children: [
                            widget.isCashOnDeliveryActive && notHideCod ? Expanded(
                              child: PaymentButtonNew(
                                icon: Images.codIcon,
                                title: 'cash_on_delivery'.tr,
                                isSelected: orderController.paymentMethodIndex == 0,
                                onTap: () {
                                  orderController.setPaymentMethod(0);
                                },
                              ),
                            ) : const SizedBox(),
                            SizedBox(width: widget.isWalletActive && notHideWallet && !orderController.subscriptionOrder && isLoggedIn ? Dimensions.paddingSizeLarge : 0),

                            widget.isWalletActive && notHideWallet && !orderController.subscriptionOrder && isLoggedIn ? Expanded(
                              child: PaymentButtonNew(
                                icon: Images.partialWallet,
                                title: 'pay_via_wallet'.tr,
                                isSelected: orderController.paymentMethodIndex == 1,
                                onTap: () {
                                  if(canSelectWallet) {
                                    orderController.setPaymentMethod(1);
                                  } else if(orderController.isPartialPay){
                                    showCustomSnackBar('you_can_not_user_wallet_in_partial_payment'.tr);
                                    Get.back();
                                  } else{
                                    showCustomSnackBar('your_wallet_have_not_sufficient_balance'.tr);
                                    Get.back();
                                  }
                                },
                              ),
                            ) : const SizedBox(),

                          ]) : const SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          // Ẩn chức năng thanh toán
                          widget.isOfflinePaymentActive && !orderController.subscriptionOrder ? OfflinePaymentButton(
                            isSelected: orderController.paymentMethodIndex == 3,
                            offlineMethodList: orderController.offlineMethodList!,
                            isOfflinePaymentActive: widget.isOfflinePaymentActive,
                            onTap: () => orderController.setPaymentMethod(3),
                            orderController: orderController, tooltipController: tooltipController,
                          ) : const SizedBox(),

                        ],
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: CustomButton(
                        buttonText: 'select'.tr,
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                ]),
              );
            }
          );
        }
      ),
    );
  }
}
