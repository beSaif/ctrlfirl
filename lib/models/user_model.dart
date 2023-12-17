import 'package:image_picker/image_picker.dart';

class UserModel {
  String? uid;
  String? fullName;
  DateTime? dob;
  String? gender;
  String? profilePicture;
  String? phoneNumber;
  XFile? profileImageFile;

  UserModel({
    this.uid,
    this.fullName,
    this.dob,
    this.gender,
    this.profilePicture,
    this.phoneNumber,
    this.profileImageFile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('dbg json: $json');
    // print all null values
    json.forEach((key, value) {
      if (value == null) {
        print('dbg key: $key, value: $value');
      }
    });
    return UserModel(
      uid: json['uid'],
      fullName: json['fullName'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      gender: json['gender'],
      profilePicture: json['profilePicture'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    DateTime? dob,
    String? gender,
    List<String>? knownLanguages,
    String? profilePicture,
    String? phoneNumber,
    String? email,
    XFile? profileImageFile,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageFile: profileImageFile ?? this.profileImageFile,
    );
  }

  @override
  toString() => toJson().toString();
}
