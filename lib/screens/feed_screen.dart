import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tweech/config/constants.dart';
import 'package:tweech/models/liveStream_model.dart';
import 'package:timeago/timeago.dart' as tg;
import 'package:tweech/resources/firestore_methods.dart';
import 'package:tweech/responsive/layout.dart';
import 'package:tweech/screens/broadcast_screen.dart';
import 'package:tweech/utils/mediaUtils.dart';

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
                        Lottie.asset(MediaFileUtils.emptyFileLottie),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: Text(
                            "Oops!!! no one is streaming currently",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
                child: Layout(
                  desktopLayout: GridView.builder(
                      itemCount: snapshot.data.docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemBuilder: (context, index) {
                        LiveStream livePost = LiveStream.fromMap(
                          snapshot.data.docs[index].data(),
                        );
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
                                  channelId: livePost.channelId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Image.network(
                                      livePost.image,
                                      // fit: BoxFit.cover,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Text("Started ${tg.format(
                                        livePost.createAt.toDate(),
                                      )}"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  mobileLayout: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      LiveStream livePost =
                          LiveStream.fromMap(snapshot.data.docs[index].data());
                      return GestureDetector(
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
                                channelId: livePost.channelId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: size.height * 0.12,
                          margin: const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 5,
                                blurRadius: 5,
                                color: Colors.grey.shade400,
                                offset: const Offset(2, 2),
                              ),
                              const BoxShadow(
                                spreadRadius: 5,
                                blurRadius: 5,
                                color: Colors.white,
                                offset: Offset(-2, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: livePost.image,
                                  placeholder: (context, url) => Lottie.asset(
                                      MediaFileUtils.loadingIndicatorLottie),
                                  errorWidget: (context, url, error) =>
                                      Lottie.asset(MediaFileUtils.ghostLottie),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.02,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        livePost.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "@${livePost.username}",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        "${livePost.viewers} watching",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Started ${tg.format(
                                            livePost.createAt.toDate(),
                                          )}",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // IconButton(
                              //   onPressed: () {},
                              //   icon: const Icon(Icons.more_vert),
                              // )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
