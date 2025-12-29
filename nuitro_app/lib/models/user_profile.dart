class UserProfile {
  String? gender;
  double? height;
  double? weight;
  List<String>? medicalCondition;
  List<String>? foodPreference;
  String? modeOfProgress;
  int? age;

  UserProfile({
    this.gender,
    this.height,
    this.weight,
    this.medicalCondition,
    this.foodPreference,
    this.modeOfProgress,
    this.age,
  });

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'height': height,
      'weight': weight,
      'medicalCondition': medicalCondition,
      'foodPreference': foodPreference,
      'modeOfProgress': modeOfProgress,
      'age': age,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      gender: json['gender'],
      height: json['height'],
      weight: json['weight'],
      medicalCondition: json['medicalCondition'] != null ? List<String>.from(json['medicalCondition']) : null,
      foodPreference: json['foodPreference'] != null ? List<String>.from(json['foodPreference']) : null,
      modeOfProgress: json['modeOfProgress'],
      age: json['age'],
    );
  }
}
