import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/body/social_log_in_body.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLoginWidget extends StatelessWidget {
  const SocialLoginWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    return Get.find<SplashController>().configModel!.socialLogin!.isNotEmpty && (Get.find<SplashController>().configModel!.socialLogin![0].status!
    || Get.find<SplashController>().configModel!.socialLogin![1].status!) ? Column(children: [

      Center(child: Text('social_login'.tr, style: robotoMedium)),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Row(mainAxisAlignment: MainAxisAlignment.center, children: [


        // Get.find<SplashController>().configModel!.socialLogin![0].status! ? InkWell(
        //   onTap: () async {
        //   // Mở popup Firebase Authentication khi nhấn vào ảnh SMS
        //     showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return FireBaseAuthenticationPopup();
        //       },
        //     );
        //   },
        //   child: Container(
        //     height: 40,width: 40,
        //     padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: const BorderRadius.all(Radius.circular(5)),
        //       boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5)],
        //     ),
        //     child: Image.asset(Images.smsotp),
        //   ),
        // ) : const SizedBox(),
        // SizedBox(width: Get.find<SplashController>().configModel!.socialLogin![0].status! ? Dimensions.paddingSizeLarge : 0),

        Get.find<SplashController>().configModel!.socialLogin![0].status! ? InkWell(
          onTap: () async {
            GoogleSignInAccount googleAccount = (await googleSignIn.signIn())!;
            GoogleSignInAuthentication auth = await googleAccount.authentication;
            Get.find<AuthController>().loginWithSocialMedia(SocialLogInBody(
              email: googleAccount.email, token: auth.idToken, uniqueId: googleAccount.id, medium: 'google',
            ));
          },
          child: Container(
            height: 40,width: 40,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5)],
            ),
            child: Image.asset(Images.google),
          ),
        ) : const SizedBox(),
        // SizedBox(width: Get.find<SplashController>().configModel!.socialLogin![0].status! ? Dimensions.paddingSizeLarge : 0),

        Get.find<SplashController>().configModel!.socialLogin![1].status! ? Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
          child: InkWell(
            onTap: () async{
              LoginResult result = await FacebookAuth.instance.login(permissions: ["public_profile", "email"]);
              if (result.status == LoginStatus.success) {
                Map userData = await FacebookAuth.instance.getUserData();
                Get.find<AuthController>().loginWithSocialMedia(SocialLogInBody(
                  email: userData['email'], token: result.accessToken!.token, uniqueId: result.accessToken!.userId, medium: 'facebook',
                ));
              }

            },
            child: Container(
              height: 40, width: 40,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5)],
              ),
              child: Image.asset(Images.facebookIcon),
            ),
          ),
        ) : const SizedBox(),
        // const SizedBox(width: Dimensions.paddingSizeLarge),

        Get.find<SplashController>().configModel!.appleLogin!.isNotEmpty && Get.find<SplashController>().configModel!.appleLogin![0].status!
        && !GetPlatform.isAndroid && !GetPlatform.isWeb ? Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
          child: InkWell(
            onTap: () async {
              final credential = await SignInWithApple.getAppleIDCredential(scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName,
              ],
                // webAuthenticationOptions: WebAuthenticationOptions(
                //   clientId: Get.find<SplashController>().configModel.appleLogin[0].clientId,
                //   redirectUri: Uri.parse('https://6ammart-web.6amtech.com/apple'),
                // ),
              );
              Get.find<AuthController>().loginWithSocialMedia(SocialLogInBody(
                email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode, medium: 'apple',
              ));
            },
            child: Container(
              height: 40, width: 40,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5)],
              ),
              child: Image.asset(Images.appleLogo),
            ),
          ),
        ) : const SizedBox(),

      ]),
      const SizedBox(height: Dimensions.paddingSizeSmall),

    ]) : const SizedBox();
  }
}

class FireBaseAuthenticationPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Đặt border-radius là 20%
      ),

      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tiêu đề
            Center(
              child: Text(
                "Đăng nhập nhanh",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.0), // Khoảng cách giữa tiêu đề và nội dung

            // Input nhập số điện thoại
            Text('Để đăng nhập nhanh bằng số điện thoại, bạn hãy nhập số điện thoại của bạn vào ô bên dưới và bấm nút gửi mã OTP. Sau khi nhận được mã OTP (SMS) hãy nhập vào ô bên dưới để tiếp tục đăng nhập!'),
            SizedBox(width: 8.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Số điện thoại'),
                  ),
                ),
                SizedBox(width: 8.0),
                // Nút Gửi mã OTP với hình ảnh từ tài nguyên
                IconButton(
                  onPressed: () {
                    // Xử lý logic khi nhấn nút gửi mã OTP
                  },
                  icon: Image.asset(
                    Images.otp,
                    width: 80.0,
                    height: 35.0,
                  ),
                ),
              ],
            ),
            // Input điền mã OTP
            TextFormField(
              decoration: InputDecoration(labelText: 'Mã OTP (Tin nhắn SMS):'),
            ),
            SizedBox(height: 16.0),
            // Nút xác nhận đăng nhập nhanh
            ElevatedButton(
              onPressed: () {
                // Xử lý logic khi nhấn nút xác nhận đăng nhập nhanh
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text('Xác nhận đăng nhập nhanh'),
            ),
          ],
        ),
      ),
    );
  }
}



