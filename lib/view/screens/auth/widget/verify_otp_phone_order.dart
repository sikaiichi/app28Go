//import 'dart:convert';

import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyOTPPhoneOrder extends StatefulWidget {
  final String phone;
  final Function(bool isVerify)? onVerify;
  const VerifyOTPPhoneOrder({super.key, required this.phone, this.onVerify});

  @override
  State<VerifyOTPPhoneOrder> createState() => _VerifyOTPPhoneOrderState();
}

class _VerifyOTPPhoneOrderState extends State<VerifyOTPPhoneOrder> {
  final TextEditingController _otpController = TextEditingController();
  String verificationID = '';

  late ConfirmationResult temp;
  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
      ),
      elevation: 0.0,
      child: Container(
        height: 250,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
        child: Column(
          children: [
            const Text('Xác nhận số điện thoại', style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),),
            const SizedBox(height: 10.0,),
            Text.rich(
              TextSpan(
                text: 'Mã xác minh đã được gửi tới ',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black, // Màu của phần văn bản không đậm
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${widget.phone}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Đặt đậm cho phần văn bản này
                      color: Colors.orange, // Màu của phần văn bản đậm
                    ),
                  ),
                  const TextSpan(
                    text: '. Hãy nhập mã OTP để xác thực tài khoản trước khi đặt đơn hàng.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black, // Màu của phần văn bản không đậm
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0,),

            Expanded(
              child: CustomTextField(
                controller: _otpController,
                hintText: 'Nhập mã OTP đã gửi về số điện thoại',
                maxLines: 1,
                inputAction: TextInputAction.done,
                inputType: TextInputType.text,
                isPassword: false,
                onSubmit: (text) {},
              ),
            ),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    height: 45,
                    width: 180,
                    buttonText: 'Xác minh',
                    radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                    isBold: ResponsiveHelper.isDesktop(context) ? false : true,
                    onPressed: _verifyOTP,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOTP() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: '${widget.phone}',
      verificationCompleted: (PhoneAuthCredential credential)  {
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Gửi thông tin xác thực lỗi!');
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationID = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    ).catchError((error, stackTrace) {
      print(error);
    });
  }

  void _verifyOTP()async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationID , smsCode: _otpController.text.trim());
    FirebaseAuth.instance.signInWithCredential(credential)
        .then((value){
      widget.onVerify!(true);
      print('Xác minh thông tin thành công');
    }).catchError((error, stackTrace){
      showCustomSnackBar('Xác nhận thất bại.');
    });
  }
}