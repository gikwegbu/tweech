bool isDev = true;

String liveStreamCollection = isDev ? "devLivestream" : "livestream";

String liveStreamCommentsCollection = isDev ? "devComments" : "comments";

String liveStreamCommentOrderingFactor = "createdAt";

String liveStreamThumbnails = isDev? "devLivestream-thumbnails": "Livestream-thumbnails";

String usersCollection = isDev ? "devUsers" : "users";

String serverUrl = "https://flutter-twitch-server-production.up.railway.app";
String pubUserAccount = "/publisher/userAccount/";
String rtcLink = "/rtc/";
