class LiveStream {
  final String title;
  final String image;
  final String uid;
  final String username;
  final createAt;
  final int viewers;
  final String channelId;
  bool public = false;

  LiveStream({
    required this.title,
    required this.image,
    required this.uid,
    required this.username,
    required this.createAt,
    required this.viewers,
    required this.channelId,
  });

Map<String, dynamic> toMap() {
  return {
    'title': title,
    'image': image,
    'uid': uid,
    'username': username,
    'viewers': viewers,
    'channelId': channelId,
    'createAt': createAt,
  };
}

  factory LiveStream.fromMap(Map<String, dynamic> map) {
    return LiveStream(
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      createAt: map['createAt'] ?? '',
      viewers: map['viewers']?.toInt() ?? 0,
      channelId: map['channelId'] ?? '',
    );
  }
}
