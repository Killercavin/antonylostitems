class UserModel {
  String? name;
  String? email;
  String? password;
  String? mobile;
  String? id;

  UserModel({this.name, this.email, this.password, this.mobile, this.id});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    password = json['password'];
    mobile = json['mobile'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['mobile'] = this.mobile;
    data['id'] = this.id;
    return data;
  }
}
