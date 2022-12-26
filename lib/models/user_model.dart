class User {
  final String uid;
  final String username;
  final String email;
  // final List<String> followers = [];

  User({
    required this.uid,
    required this.username,
    required this.email,
    // required this.followers,
  });

  User copyWith({
    String? username,
  }) =>
      User(
        uid: uid,
        username: username ?? this.username,
        email: email,
      );

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      // 'followers': followers,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? "",
      username: map['username'] ?? "",
      email: map['email'] ?? "",
      // followers: map['followers'] ?? "",
    );
  }
}
