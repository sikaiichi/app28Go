import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/wallet_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AddFundDialogue extends StatefulWidget {
  const AddFundDialogue({Key? key}) : super(key: key);

  @override
  State<AddFundDialogue> createState() => _AddFundDialogueState();
}

class _AddFundDialogueState extends State<AddFundDialogue> {
  final String userId = (Get.find<UserController>().userInfoModel?.id?.toString() ?? 'TAIKHOANKHACH');

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().isTextFieldEmpty('', isUpdate: false);
    Get.find<WalletController>().changeDigitalPaymentName('', isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(3),
                child: const Icon(Icons.clear),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          GetBuilder<WalletController>(
            builder: (walletController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                ),
                width: context.width * 0.9,
                height: 550,
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Text(
                      'Nạp tiền vào ví'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'add_fund_form_secured_digital_payment_gateways'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    // Add your image here
                    Image.network(
                      'https://qr.sepay.vn/img?acc=280000000028&bank=mbbank&des=28GO $userId',
                      width: context.width * 0.6,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(
                      '- Số tài khoản: 280000000028\n- Ngân hàng: MBBank (Quân Đội)\n- CÔNG TY TNHH 28GO',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      textAlign: TextAlign.left, // Căn trái
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(
                      'Hướng dẫn thanh toán: Quét mã QRCODE và nhập số tiền cần nạp. Đơn hàng nạp tiền sẽ được xử lý thanh toán tự động sau 3-5 giây từ khi bạn chuyển tiền qua hình thức quét mã QRCODE phía trên.',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      textAlign: TextAlign.center,
                    ),


                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
