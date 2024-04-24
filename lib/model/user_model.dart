class UserModel {
  String firstname;
  String lastname;
  String username;
  String email;
  String phoneNumber;
  String uid;
  String createdAt;
  String dob; // Date of birth


  UserModel({
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.uid,
    required this.createdAt,
    required this.dob,

  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      firstname: map['firstname'] ?? '',
      lastname: map['lastname'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      uid: map['uid'] ?? '',
      createdAt: map['createdAt'] ?? '',
      dob: map['dob'] ?? '',
       // Added password mapping
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "firstname": firstname,
      "lastname": lastname,
      "username": username,
      "email": email,
      "uid": uid,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt,
      "dob": dob,
       // Added password mapping
    };
  }
}
