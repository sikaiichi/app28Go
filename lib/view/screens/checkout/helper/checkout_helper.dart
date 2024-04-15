import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
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
    // if(restController.restaurant!.selfDeliverySystem == 0 && zoneData.increasedDeliveryFeeStatus == 1){
    //   deliveryCharge =
    //       deliveryCharge +
    //       (deliveryCharge * (zoneData.increasedDeliveryFee!/100)) +
    //       (deliveryCharge * (zoneData.increasedDeliveryFeeMuc1!/100)) +
    //       (zoneData.increasedDeliveryFeeMuc2!) + (zoneData.increasedDeliveryFeeMuc3!);
    //   charge =
    //       charge +
    //       charge * (zoneData.increasedDeliveryFee!/100) +
    //       charge * (zoneData.increasedDeliveryFeeMuc1!/100) +
    //       (zoneData.increasedDeliveryFeeMuc2!) +
    //       (zoneData.increasedDeliveryFeeMuc3!);
    // }
    if (restController.restaurant!.selfDeliverySystem == 0) {


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
}