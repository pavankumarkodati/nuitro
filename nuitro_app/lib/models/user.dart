class UserModel {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String userId;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    String? password,
    String? userId,
  })  : password = password ?? '',
        userId = userId ?? '';

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "user_id": userId,
    };
  }

  Map<String, dynamic> toSanitizedJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "user_id": userId,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      password: json["password"]?.toString(),
      userId: json["user_id"]?.toString(),
    );
  }
}
