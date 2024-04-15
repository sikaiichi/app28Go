class SignUpBody {
  String? fName;
  String? lName;
  String? phone;
  String? loaixe;
  String? bks;
  String? email;
  String? password;
  String? refCode;

  SignUpBody({this.fName, this.lName, this.phone, this.email='', this.password, this.refCode = ''});

  SignUpBody.fromJson(Map<String, dynamic> json) {
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    loaixe = json['loaixe'];
    bks = json['bks'];
    password = json['password'];
    refCode = json['ref_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['loaixe'] = loaixe;
    data['bks'] = bks;
    data['password'] = password;
    data['ref_code'] = refCode;
    return data;
  }
}
