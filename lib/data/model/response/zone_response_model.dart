class ZoneResponseModel {
  final bool _isSuccess;
  final List<int> _zoneIds;
  final String? _message;
  final List<ZoneData> _zoneData;
  ZoneResponseModel(this._isSuccess, this._message, this._zoneIds, this._zoneData);

  String? get message => _message;
  List<int> get zoneIds => _zoneIds;
  bool get isSuccess => _isSuccess;
  List<ZoneData> get zoneData => _zoneData;
}

class ZoneData {
  int? id;
  int? status;
  double? minimumShippingCharge;
  double? increasedDeliveryFee;
  double? increasedDeliveryFeeMuc1;
  double? increasedDeliveryFeeMuc2;
  double? increasedDeliveryFeeMuc3;
  int? increasedDeliveryFeeStatus;
  int? increasedDeliveryFeeStatusMuc1;
  int? increasedDeliveryFeeStatusMuc2;
  int? increasedDeliveryFeeStatusMuc3;
  String? increaseDeliveryFeeMessage;
  double? perKmShippingCharge;
  double? maxCodOrderAmount;
  double? maximumShippingCharge;

  ZoneData({
    this.id,
    this.status,
    this.minimumShippingCharge,
    this.increasedDeliveryFee,
    this.increasedDeliveryFeeMuc1,
    this.increasedDeliveryFeeMuc2,
    this.increasedDeliveryFeeMuc3,
    this.increasedDeliveryFeeStatus,
    this.increasedDeliveryFeeStatusMuc1,
    this.increasedDeliveryFeeStatusMuc2,
    this.increasedDeliveryFeeStatusMuc3,
    this.increaseDeliveryFeeMessage,
    this.perKmShippingCharge,
    this.maxCodOrderAmount,
    this.maximumShippingCharge,
  });

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    minimumShippingCharge = json['minimum_shipping_charge']?.toDouble();
    increasedDeliveryFee = json['increased_delivery_fee']?.toDouble();
    increasedDeliveryFeeMuc1 = json['increased_delivery_fee_muc1']?.toDouble();
    increasedDeliveryFeeMuc2 = json['increased_delivery_fee_muc2']?.toDouble();
    increasedDeliveryFeeMuc3 = json['increased_delivery_fee_muc3']?.toDouble();
    increasedDeliveryFeeStatus = json['increased_delivery_fee_status'];
    increasedDeliveryFeeStatusMuc1 = json['increased_delivery_fee_status_muc1'];
    increasedDeliveryFeeStatusMuc2 = json['increased_delivery_fee_status_muc2'];
    increasedDeliveryFeeStatusMuc3 = json['increased_delivery_fee_status_muc3'];
    increaseDeliveryFeeMessage = json['increase_delivery_charge_message'];
    perKmShippingCharge = json['per_km_shipping_charge']?.toDouble();
    maxCodOrderAmount = json['max_cod_order_amount']?.toDouble();
    maximumShippingCharge = json['maximum_shipping_charge']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['increased_delivery_fee'] = increasedDeliveryFee;
    data['increased_delivery_fee_muc1'] = increasedDeliveryFeeMuc1;
    data['increased_delivery_fee_muc2'] = increasedDeliveryFeeMuc2;
    data['increased_delivery_fee_muc3'] = increasedDeliveryFeeMuc3;
    data['increased_delivery_fee_status'] = increasedDeliveryFeeStatus;
    data['increased_delivery_fee_status_muc1'] = increasedDeliveryFeeStatusMuc1;
    data['increased_delivery_fee_status_muc2'] = increasedDeliveryFeeStatusMuc2;
    data['increased_delivery_fee_status_muc3'] = increasedDeliveryFeeStatusMuc3;
    data['increase_delivery_charge_message'] = increaseDeliveryFeeMessage;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['max_cod_order_amount'] = maxCodOrderAmount;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    return data;
  }
}

