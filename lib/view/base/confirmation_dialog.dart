import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ConfirmationDialog extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;
  final bool isLogOut;
  final Function? onNoPressed;
  final Color? titleColor;
  final bool? isDelete;
  const ConfirmationDialog({Key? key, required this.icon, this.title, required this.description, required this.onYesPressed,
    this.isLogOut = false, this.onNoPressed, this.titleColor = Colors.red, this.isDelete = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: EdgeInsets.all(isDelete == true ? 22 : 30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(width: 500, child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Image.asset(icon, width: 50, height: 50),
            ),

            title != null ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Text(
                title!, textAlign: TextAlign.center,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: titleColor),
              ),
            ) : const SizedBox(),

            Padding(
              padding: EdgeInsets.all(isDelete == true ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge),
              child: Text(description, style: isDelete == true? robotoRegular : robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            GetBuilder<UserController>(builder: (userController) {
                return GetBuilder<OrderController>(builder: (orderController) {
                  return (orderController.isLoading || userController.isLoading) ? const Center(child: CircularProgressIndicator()) : Row(children: [
                    Expanded(child: TextButton(
                      onPressed: () => isLogOut ? onYesPressed() : onNoPressed != null ? onNoPressed!() : Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: isDelete == true ? Theme.of(context).colorScheme.error : Theme.of(context).disabledColor.withOpacity(0.3), minimumSize: const Size(Dimensions.webMaxWidth, 40), padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),
                      child: Text(
                        isLogOut ? isDelete == true ? 'delete'.tr : 'yes'.tr : isDelete == true ? 'cancel'.tr : 'no'.tr, textAlign: TextAlign.center,
                        style: robotoBold.copyWith(color: isDelete == true ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    Expanded(child: CustomButton(
                      color: isDelete == true ? Theme.of(context).disabledColor.withOpacity(0.3) : Theme.of(context).primaryColor,
                      textColor: isDelete == true ? Theme.of(context).disabledColor : Theme.of(context).cardColor,
                      buttonText: isLogOut ? isDelete == true ? 'cancel'.tr : 'no'.tr : isDelete == true ? 'delete'.tr : 'yes'.tr,
                      onPressed: () => isLogOut ? Get.back() : onYesPressed(),
                      radius: Dimensions.radiusSmall, height: 40,
                    )),

                  ]);
                });
              }
            ),

          ]),
        )),
      ),
    );
  }
}
