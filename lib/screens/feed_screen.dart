import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tweech/config/constants.dart';
import 'package:tweech/models/liveStream_model.dart';
import 'package:timeago/timeago.dart' as tg;
import 'package:tweech/resources/firestore_methods.dart';
import 'package:tweech/screens/broadcast_screen.dart';

import '../widget/loadingIndicator.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.03,
          ),
          Text(
            "Live Streams",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          StreamBuilder<dynamic>(
            stream: FirebaseFirestore.instance
                .collection(liveStreamCollection)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              }
              if (snapshot.hasData) {
                debugPrint("Yeah boy, gotchaaaaaa $snapshot");
              }

              if (snapshot.data.docs.length == 0) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Floating lottie file"),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: Text(
                            "Enjoy the streams that your friends start when they do.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    LiveStream livePost =
                        LiveStream.fromMap(snapshot.data.docs[index].data());
                    return InkWell(
                      onTap: () async {
                        await FirestoreMethods().modifyViewCounter(
                          context,
                          livePost.channelId,
                          true,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BroadCastScreen(
                                isBroadcaster: false,
                                channelId: livePost.channelId),
                          ),
                        );
                      },
                      child: Container(
                        height: size.height * 0.1,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(livePost.image),
                            ),
                             SizedBox(
                              width: size.width * 0.02,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    livePost.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    livePost.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text("${livePost.viewers} watching"),
                                  Expanded(
                                    child: Text("Started ${tg.format(
                                      livePost.createAt.toDate(),
                                    )}"),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_vert),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
