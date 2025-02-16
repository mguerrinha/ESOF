class UserAuth {
  final String uid;
  final String email;
  String? profilePicURL;
  UserAuth({
    required this.uid,
    required this.email,
    this.profilePicURL,
  });

  Map<String, dynamic> json() {
    return {
      'uid': uid,
      'email': email,
      'profilePicURL': profilePicURL,
    };
  }

  static UserAuth fromJson(Map<String, dynamic> json) {
    return UserAuth(
        uid: json['uid'],
        email: json['email'],
        profilePicURL: json['profilePicURL']);
  }

   void updateProfilePicURL(String url) {
    profilePicURL = url;
  }
}
