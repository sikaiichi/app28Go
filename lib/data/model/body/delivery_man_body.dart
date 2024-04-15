class DeliveryManBody {
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? loaixe;
  String? bks;
  String? password;
  String? identityType;
  String? identityNumber;
  String? earning;
  String? zoneId;
  String? vehicleId;

  DeliveryManBody(
      {this.fName,
        this.lName,
        this.phone,
        this.email,
        this.loaixe,
        this.bks,
        this.password,
        this.identityType,
        this.identityNumber,
        this.earning,
        this.zoneId,
        this.vehicleId,
      });

  DeliveryManBody.fromJson(Map<String, dynamic> json) {
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    loaixe = json['loaixe'];
    bks = json['bks'];
    password = json['password'];
    identityType = json['identity_type'];
    identityNumber = json['identity_number'];
    earning = json['earning'];
    zoneId = json['zone_id'];
    vehicleId = json['vehicle_id'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['f_name'] = fName!;
    data['l_name'] = lName!;
    data['phone'] = phone!;
    data['email'] = email!;
    data['loaixe'] = loaixe!;
    data['bks'] = bks!;
    data['password'] = password!;
    data['identity_type'] = identityType!;
    data['identity_number'] = identityNumber!;
    data['earning'] = earning!;
    data['zone_id'] = zoneId!;
    data['vehicle_id'] = vehicleId!;
    return data;
  }
}
