import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/body/dateMonthBody.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:get/get.dart';

class CheckoutHelper {

  static double? getDeliveryCharge({required RestaurantController restController, required OrderController orderController, bool returnDeliveryCharge = true, bool returnMaxCodOrderAmount = false}) {

    ZoneData zoneData = Get.find<LocationController>().getUserAddress()!.zoneData!.firstWhere((data) => data.id == restController.restaurant!.zoneId);
    double perKmCharge = restController.restaurant!.selfDeliverySystem == 1 ? restController.restaurant!.perKmShippingCharge!
        : zoneData.perKmShippingCharge ?? 0;

    double minimumCharge = restController.restaurant!.selfDeliverySystem == 1 ? restController.restaurant!.minimumShippingCharge!
        :  zoneData.minimumShippingCharge ?? 0;

    double? maximumCharge = restController.restaurant!.selfDeliverySystem == 1 ? restController.restaurant!.maximumShippingCharge
        : zoneData.maximumShippingCharge;

    double deliveryCharge = orderController.distance! * perKmCharge;
    double charge = orderController.distance! * perKmCharge;

    if(deliveryCharge < minimumCharge) {
      deliveryCharge = minimumCharge;
      charge = minimumCharge;
    }

    if(restController.restaurant!.selfDeliverySystem == 0 && orderController.extraCharge != null){
      deliveryCharge = deliveryCharge + orderController.extraCharge!;
      charge = charge + orderController.extraCharge!;
    }

    if(maximumCharge != null && deliveryCharge > maximumCharge){
      deliveryCharge = maximumCharge;
      charge = maximumCharge;
    }

    // ĐOẠN CODE NÀY HIỂN THỊ KHÔNG ĐÚNG, TỔNG ĐƠN ĐÚNG
    if (restController.restaurant!.selfDeliverySystem == 0) {
      // deliveryCharge = deliveryCharge;
      // charge = charge;

      if (zoneData.increasedDeliveryFee != null &&
          zoneData.increasedDeliveryFee! > 0 &&
          zoneData.increasedDeliveryFeeStatus == 1) {
        deliveryCharge += (deliveryCharge * (zoneData.increasedDeliveryFee!/100));
        charge += (deliveryCharge * (zoneData.increasedDeliveryFee!/100));
      }

      if (zoneData.increasedDeliveryFeeMuc1 != null &&
          zoneData.increasedDeliveryFeeMuc1! > 0 &&
          zoneData.increasedDeliveryFeeStatusMuc1 == 1) {
        deliveryCharge += (deliveryCharge * (zoneData.increasedDeliveryFeeMuc1!/100))!;
        charge += (deliveryCharge * (zoneData.increasedDeliveryFeeMuc1!/100))!;
      }

      if (zoneData.increasedDeliveryFeeMuc2 != null &&
          zoneData.increasedDeliveryFeeMuc2! > 0 &&
          zoneData.increasedDeliveryFeeStatusMuc2 == 1) {
        deliveryCharge += zoneData.increasedDeliveryFeeMuc2!;
        charge += zoneData.increasedDeliveryFeeMuc2!;
      }

      // Check if the current time is between 22:00 and 04:30 before applying increasedDeliveryFeeMuc3
      DateTime now = DateTime.now();
      if (zoneData.increasedDeliveryFeeMuc3 != null &&
          zoneData.increasedDeliveryFeeMuc3! > 0 &&
          zoneData.increasedDeliveryFeeStatusMuc3 == 1 &&
          now.hour >= 22 &&
          now.minute >= 0 &&
          now.hour <= 4 &&
          now.minute <= 30) {
        deliveryCharge += zoneData.increasedDeliveryFeeMuc3!;
        charge += zoneData.increasedDeliveryFeeMuc3!;
      }
    }

    // ĐOẠN CODE NÀY HIỂN THỊ KHÔNG ĐÚNG, TỔNG ĐƠN ĐÚNG

    if(restController.restaurant!.selfDeliverySystem == 0 && Get.find<SplashController>().configModel!.freeDeliveryDistance != null && Get.find<SplashController>().configModel!.freeDeliveryDistance! >= orderController.distance!){
      deliveryCharge = 0;
      charge = 0;
    }

    if(restController.restaurant!.selfDeliverySystem == 1 && restController.restaurant!.freeDeliveryDistanceStatus! && restController.restaurant!.freeDeliveryDistanceValue! >= orderController.distance!){
      deliveryCharge = 0;
      charge = 0;
    }

    double? maxCodOrderAmount;
    if(zoneData.maxCodOrderAmount != null) {
      maxCodOrderAmount = zoneData.maxCodOrderAmount;
    }

    if(returnMaxCodOrderAmount) {
      return maxCodOrderAmount;
    } else {
      if(returnDeliveryCharge) {
        return deliveryCharge;
      }else {
        return charge;
      }
    }

  }

  static int getSubscriptionQty({required OrderController orderController, required bool restaurantSubscriptionActive}) {
    int subscriptionQty = orderController.subscriptionOrder ? 0 : 1;
    if(restaurantSubscriptionActive){
      if(orderController.subscriptionOrder && orderController.subscriptionRange != null) {
        if(orderController.subscriptionType == 'weekly') {
          List<int> weekDays = [];
          for(int index=0; index<orderController.selectedDays.length; index++) {
            if(orderController.selectedDays[index] != null) {
              weekDays.add(index + 1);
            }
          }
          subscriptionQty = DateConverter.getWeekDaysCount(orderController.subscriptionRange!, weekDays);
        }else if(orderController.subscriptionType == 'monthly') {
          List<int> days = [];
          for(int index=0; index<orderController.selectedDays.length; index++) {
            if(orderController.selectedDays[index] != null) {
              days.add(index + 1);
            }
          }
          subscriptionQty = DateConverter.getMonthDaysCount(orderController.subscriptionRange!, days);
        }else {
          subscriptionQty = orderController.subscriptionRange!.duration.inDays + 1;
        }
      }
    }
    return subscriptionQty;
  }

  static bool canSelectDate({required int duration, required DateTime value}) {
    List<DateMonthBody> date = [];
    for(int i=0; i<duration; i++){
      date.add(DateMonthBody(date: DateTime.now().add(Duration(days: i)).day, month: DateTime.now().add(Duration(days: i)).month));
    }
    bool status = false;
    for(int i=0; i<date.length; i++){
      if(date[i].month == value.month && date[i].date == value.day){
        status = true;
        break;
      } else {
        status = false;
      }
    }
    return status;
  }

  static double calculatePrice(List<CartModel>? cartList) {
    double price = 0;
    double variationPrice = 0;
    for (var cartModel in cartList!) {

      price = price + (cartModel.product!.price! * cartModel.quantity!);

      for(int index = 0; index< cartModel.product!.variations!.length; index++) {
        for(int i=0; i<cartModel.product!.variations![index].variationValues!.length; i++) {
          if(cartModel.variations![index][i]!) {
            variationPrice += (cartModel.product!.variations![index].variationValues![i].optionPrice! * cartModel.quantity!);
          }
        }
      }
    }
    return PriceConverter.toFixed(price + variationPrice);
  }

  static double calculateAddonsPrice(List<CartModel>? cartList) {
    double addonPrice = 0;
    for (var cartModel in cartList!) {
      List<AddOns> addOnList = [];
      for (var addOnId in cartModel.addOnIds!) {
        for (AddOns addOns in cartModel.product!.addOns!) {
          if (addOns.id == addOnId.id) {
            addOnList.add(addOns);
            break;
          }
        }
      }
      for (int index = 0; index < addOnList.length; index++) {
        addonPrice = addonPrice + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
      }
    }
    return PriceConverter.toFixed(addonPrice);
  }

  static double calculateDiscountPrice(List<CartModel>? cartList, RestaurantController restController, double price, double addOns) {
    double? discount = 0;
    if(restController.restaurant != null) {
      for (var cartModel in cartList!) {
        double? dis = (restController.restaurant!.discount != null
            && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
            ? restController.restaurant!.discount!.discount : cartModel.product!.discount;
        String? disType = (restController.restaurant!.discount != null
            && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
            ? 'percent' : cartModel.product!.discountType;

        double d = ((cartModel.product!.price! - PriceConverter.convertWithDiscount(cartModel.product!.price!, dis, disType)!) * cartModel.quantity!);
        discount = discount! + d;
        discount = discount + calculateVariationPrice(restController: restController, cartModel: cartModel);


      }

      if (restController.restaurant != null && restController.restaurant!.discount != null) {
        if (restController.restaurant!.discount!.maxDiscount != 0 && restController.restaurant!.discount!.maxDiscount! < discount!) {
          discount = restController.restaurant!.discount!.maxDiscount;
        }
        if (restController.restaurant!.discount!.minPurchase != 0 && restController.restaurant!.discount!.minPurchase! > (price + addOns)) {
          discount = 0;
        }
      }

    }
    return PriceConverter.toFixed(discount!);
  }

  static double calculateVariationPrice({required RestaurantController restController, required CartModel? cartModel}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if(restController.restaurant != null && cartModel != null) {

      double? discount = (restController.restaurant!.discount != null
          && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
          ? restController.restaurant!.discount!.discount : cartModel.product!.discount;
      String? discountType = (restController.restaurant!.discount != null
          && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
          ? 'percent' : cartModel.product!.discountType;

      for(int index = 0; index< cartModel.product!.variations!.length; index++) {
        for(int i=0; i<cartModel.product!.variations![index].variationValues!.length; i++) {
          if(cartModel.variations![index][i]!) {
            variationPrice += (PriceConverter.convertWithDiscount(cartModel.product!.variations![index].variationValues![i].optionPrice!, discount, discountType, isVariation: true)! * cartModel.quantity!);
            variationDiscount += (cartModel.product!.variations![index].variationValues![i].optionPrice! * cartModel.quantity!);
          }
        }
      }
    }

    return variationDiscount - variationPrice;
  }

  static double calculateSubTotal(double price, double addOnsPrice) {
    double subTotal = price + addOnsPrice;
    return PriceConverter.toFixed(subTotal);
  }

  static double calculateOrderAmount(double price, double addOnsPrice, double discount, double couponDiscount) {
    double orderAmount = (price - discount) + addOnsPrice - couponDiscount;
    return PriceConverter.toFixed(orderAmount);
  }

  static double calculateTax(bool taxIncluded, double orderAmount, double? taxPercent) {
    double tax = 0;
    if(taxIncluded){
      tax = orderAmount * taxPercent! /(100 + taxPercent);
    }else {
      tax = PriceConverter.calculation(orderAmount, taxPercent, 'percent', 1);
    }
    return PriceConverter.toFixed(tax);
  }

  static double calculateTotal(
      double subTotal, double deliveryCharge, double discount, double couponDiscount,
      bool taxIncluded, double tax, bool showTips, double tips, double additionalCharge, double additionalMaxCharge) {

    double total = subTotal + deliveryCharge - discount - couponDiscount + (taxIncluded ? 0 : tax)
        + (showTips ? tips : 0) + additionalCharge + additionalMaxCharge;

    return PriceConverter.toFixed(total);
  }

}