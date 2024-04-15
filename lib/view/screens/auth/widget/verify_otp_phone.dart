//import 'dart:convert';

import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyOTPPhone extends StatefulWidget {
  final String phone;
  final Function(bool isVerify)? onVerify;
  const VerifyOTPPhone({super.key, required this.phone, this.onVerify});

  @override
  State<VerifyOTPPhone> createState() => _VerifyOTPPhoneState();
}

class _VerifyOTPPhoneState extends State<VerifyOTPPhone> {
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
                text: 'Mã xác minh OTP xác minh tài khoản đã được gửi tới ',
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
                    text: '. Hãy nhập mã OTP trong tin nhắn SMS để tiếp tục xác minh tài khoản.',
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
                hintText: 'Nhập mã OTP đã gửi đến số điện thoại',
                maxLines: 1,
                inputAction: TextInputAction.done,
                inputType: TextInputType.text,
                isPassword: false,
                onSubmit: (text) {},
              ),
            ),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                children: [
                  CustomButton(
                    height: 45,
                    width: 120,
                    buttonText: 'Xác minh',
                    radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                    isBold: ResponsiveHelper.isDesktop(context) ? false : true,
                    onPressed: _verifyOTP,
                  ),
                  SizedBox(width: 16), // Add space between the two buttons
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      // Add any action you wish to perform upon 'Cancel' button press here
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Button padding size
                      foregroundColor: Colors.grey, // Sets the background color of the button to gray
                      backgroundColor: Colors.white, // Sets the text color to white
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0), // Button border radius
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 14.0, // Font size
                        fontWeight: FontWeight.bold, // Font weight
                      ),
                    ),
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
      phoneNumber: '+84${widget.phone}',
      verificationCompleted: (PhoneAuthCredential credential)  {
      },
      verificationFailed: (FirebaseAuthException e) {
        print('verificationFailed - +84${widget.phone}');
        print(e.message); // In ra thông báo lỗi để debug
        // Xử lý thông báo lỗi ở đây, ví dụ:
        if (e.code == 'invalid-verification-code') {
          showCustomSnackBar('Mã OTP không đúng, vui lòng thử lại.'); // Hiển thị thông báo cho người dùng
        } else if (e.code == 'invalid-verification-id') {
          showCustomSnackBar('Mã OTP đã hết hạn, vui lòng thử lại.'); // Hiển thị thông báo cho người dùng
        } else {
          showCustomSnackBar('Đã xảy ra lỗi trong quá trình xác minh OTP.'); // Hiển thị thông báo cho người dùng
        }
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
      print('Xác minh thành công!');
    }).catchError((error, stackTrace){
      showCustomSnackBar('Xác nhận thất bại.');
    });
  }
}