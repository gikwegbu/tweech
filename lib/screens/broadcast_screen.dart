import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:tweech/config/appId.dart';
import 'package:provider/provider.dart';
import 'package:tweech/config/constants.dart';
import 'package:tweech/providers/user_provider.dart';
import 'package:tweech/resources/firestore_methods.dart';
import 'package:tweech/responsive/layout.dart';
import 'package:tweech/utils/colors.dart';
import 'package:tweech/widget/chat.dart';
import 'package:http/http.dart' as http;
import 'package:tweech/widget/custom_button.dart';

import '../utils/utils.dart';

class BroadCastScreen extends StatefulWidget {
  const BroadCastScreen({
    Key? key,
    required this.isBroadcaster,
    required this.channelId,
  }) : super(key: key);
  static String routeName = "broadcast_screen";
  final bool isBroadcaster;
  final String channelId;

  @override
  State<BroadCastScreen> createState() => _BroadCastScreenState();
}

class _BroadCastScreenState extends State<BroadCastScreen> {
  List<int> _remoteUid = [];
  bool _localUserJoined = false;
  bool chooseCamera = false;
  bool muted = false;
  bool isSharingScreen = false;
  bool expandedView = false;
  late final RtcEngine _engine;

  // Due to the fact that i'm currently running this applicaiton with the android emulator,
  // I will be using 10.0.2.2:8080 as opposed to the localhost,
  // as the AVD (Android Virtual Device) uses 10.0.2.2 as an alias to my host loopback interface (i.e localhost)
  // String baseUrl = "http://localhost:8080";
  // String baseUrl = "http://10.0.2.2:8080";
  // https://flutter-twitch-server-production.up.railway.app/
  String baseUrl = serverUrl;
  String? autoGeneratedToken;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions

    //create the engine
    _engine = await RtcEngine.createWithContext(RtcEngineContext(agoraId));
    _addListeners();
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      await _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      await _engine.setClientRole(ClientRole.Audience);
    }

    _joinChannel();
  }

  Future<void> autoGenerateToken() async {
    String _uid = Provider.of<UserProvider>(context, listen: false).user.uid;
    final res = await http.get(
      Uri.parse(
        baseUrl +
            '/rtc/' +
            widget.channelId +
            '/publisher/userAccount/' +
            _uid +
            '/',
      ),
    );
    if (res.statusCode == 200) {
      autoGeneratedToken = res.body;
      autoGeneratedToken = jsonDecode(autoGeneratedToken!)['rtcToken'];
      setState(() {});
    } else {
      debugPrint("Oops!! Token Extraction not Successful");
    }
  }

  void _addListeners() async {
    _engine.setEventHandler(
      RtcEngineEventHandler(activeSpeaker: (i) {
        debugPrint("Active Speaker: $i");
      }, microphoneEnabled: (enable) {
        debugPrint("Microphone: " + enable.toString());
        // callingController.microphoneState.value = enable;
      }, warning: (warningCode) {
        print(warningCode.toString());
      }, rtcStats: (stats) {
        // Use the snackbar to show when a user joins
        debugPrint("User Count: ${stats.userCount}");
      }, connectionStateChanged: (state, reason) {
        debugPrint(
            "Connection Changed : ${state.toString()}, ${reason.toString()}");
      }, joinChannelSuccess: (String channel, int uid, int elapsed) {
        debugPrint(
            "JoinedChannelSuccess channel:$channel -> uid:$uid -> elapsed:$elapsed joined");
        setState(() {
          _localUserJoined = true;
        });
      }, userJoined: (int uid, int elapsed) {
        debugPrint("Remote user $uid joined");
        setState(() {
          _remoteUid.add(uid);
        });
      }, userOffline: (int uid, UserOfflineReason reason) {
        debugPrint("Remote user $uid left channel");
        setState(() {
          _remoteUid.removeWhere((element) => element == uid);
        });
      }, leaveChannel: (RtcStats stats) {
        debugPrint("Remote user $stats");
        setState(() {
          _remoteUid.clear();
        });
      }, tokenPrivilegeWillExpire: (token) async {
        // THis runs when the token expires
        await autoGenerateToken();
        await _engine.renewToken(autoGeneratedToken!);
      }),
    );
  }

  void _joinChannel() async {
    await autoGenerateToken();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await _engine.joinChannelWithUserAccount(
      autoGeneratedToken,
      widget.channelId,
      Provider.of<UserProvider>(context, listen: false).user.uid,
    );
  }

  _screenSharing() async {
    final helper = await _engine.getScreenShareHelper(
        appGroup: kIsWeb || Platform.isWindows ? null : 'io.agora');
    // Essentially, we are recreating the whole process, as the user sharing screen
    // Needs to like re-join the livestream and share screen
    await helper.disableAudio();
    await helper.enableVideo();
    await helper.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await helper.setClientRole(ClientRole.Broadcaster);
    var windowId = 0;
    var random = Random();
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      final windows = _engine
          .enumerateWindows(); // Enumerates the information of all the windows in the system.
      final index = random.nextInt(windows.length - 1);
      debugPrint("Screensharing current window with index: $index");
      windowId = windows[index].id;
    }
    await helper.startScreenCaptureByWindowId(windowId);
    isSharingScreen = true;
    setState(() {});
    await helper.joinChannelWithUserAccount(
      autoGeneratedToken,
      widget.channelId,
      Provider.of<UserProvider>(context, listen: false).user.uid,
    );
  }

  _exitScreenShare() async {
    final helper = await _engine.getScreenShareHelper();
    await helper.destroy().then((value) {
      isSharingScreen = false;
      setState(() {});
    }).catchError((err) {
      debugPrint("ScreenSharing Error: $err");
    });
  }

  _exitLiveStreaming() async {
    await _engine.leaveChannel();
    if ("${Provider.of<UserProvider>(context, listen: false).user.uid}${Provider.of<UserProvider>(context, listen: false).user.username}" ==
        widget.channelId) {
      await FirestoreMethods().exitLiveStreaming(context, widget.channelId);
    } else {
      await FirestoreMethods().modifyViewCounter(
        context,
        widget.channelId,
        false,
      );
    }
    navigateBack(context);
  }

  _showExitLiveStreamingDialog(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    bool isStreamer = "${user.uid}${user.username}" == widget.channelId;
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text(
        "Continue",
        style: TextStyle(color: red),
      ),
      onPressed: () {
        Navigator.pop(context);
        _exitLiveStreaming();
      },
    );

    // set up the AlertDialog
    final alert = Platform.isAndroid
        ? AlertDialog(
            title: Text(isStreamer ? "End Stream" : "Leave Stream"),
            content: Text(isStreamer
                ? "Are you sure you want to end this live stream?"
                : "Are you sure you want to leave this live stream?"),
            actions: [
              cancelButton,
              continueButton,
            ],
          )
        : CupertinoAlertDialog(
            title: Text(isStreamer ? "End Stream" : "Leave Stream"),
            content: Text(isStreamer
                ? "Are you sure you want to end this live stream?"
                : "Are you sure you want to leave this live stream?"),
            actions: [
              cancelButton,
              continueButton,
            ],
          );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final _supposedChannelId = "${user.uid}${user.username}";
    return WillPopScope(
      onWillPop: () async {
        await _showExitLiveStreamingDialog(context);
        return Future.value(true);
      },
      child: Scaffold(
        body: Layout(
          desktopLayout: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _renderVideo(user, isSharingScreen),
                    if (_supposedChannelId ==
                        widget
                            .channelId) // The person that joined the meeting, won't be able to see it
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!kIsWeb)
                            InkWell(
                              onTap: _chooseCamera,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Switch Camera"),
                              ),
                            ),
                          const SizedBox(height: 40),
                          InkWell(
                            onTap: _muteAudio,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(muted ? 'Unmute' : 'Mute'),
                            ),
                          ),
                          const SizedBox(height: 40),
                          InkWell(
                            onTap: isSharingScreen
                                ? _exitScreenShare
                                : _screenSharing,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(isSharingScreen
                                  ? "Stop Sharing"
                                  : "Start Screen Sharing"),
                            ),
                          ),
                          const SizedBox(height: 40),
                          if (!kIsWeb)
                            InkWell(
                              onTap: () {
                                _showExitLiveStreamingDialog(context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Back Button'),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ChatComponent(
                  channelId: widget.channelId,
                ),
              )
            ],
          ),
          // Mobile View Section
          mobileLayout: Column(
            children: [
              Stack(
                children: [
                  _renderVideo(user, isSharingScreen),
                  Positioned(
                    bottom: 5,
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          width: _size.width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.5),
                                Colors.white.withOpacity(0.2),
                              ],
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                              width: 1.5,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (_supposedChannelId == widget.channelId)
                                IconButton(
                                  splashRadius: 30,
                                  onPressed: _chooseCamera,
                                  icon: Icon(
                                    chooseCamera
                                        ? Icons.camera_front
                                        : Icons.camera_rear,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              IconButton(
                                splashRadius: 30,
                                onPressed: _muteAudio,
                                icon: Icon(
                                  muted ? Icons.volume_mute : Icons.volume_down,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                splashRadius: 30,
                                onPressed: () {
                                  expandedView = !expandedView;
                                  setState(() {});
                                },
                                icon: Icon(
                                  expandedView
                                      ? Icons.close_fullscreen
                                      : Icons.open_in_full,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: ChatComponent(
                    channelId: widget.channelId,
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: "${user.uid}${user.username}" == widget.channelId
            ? Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                child: CustomButton(
                  text: 'End Stream',
                  press: () {
                    _showExitLiveStreamingDialog(context);
                  },
                  buttonColor: red,
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                child: CustomButton(
                  text: 'Leave Stream',
                  press: () {
                    _showExitLiveStreamingDialog(context);
                  },
                  buttonColor: red,
                ),
              ),
      ),
    );
  }

  Widget _renderVideo(user, isSharingScreen) {
    return AspectRatio(
      // aspectRatio: 16 / 9,
      aspectRatio: expandedView ? 1 : 16 / 9,
      child: "${user.uid}${user.username}" ==
              widget
                  .channelId // Detecting if the current user started the live streaming...
          ? isSharingScreen
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : const RtcLocalView.SurfaceView(
                  zOrderMediaOverlay: true,
                  zOrderOnTop: true,
                )
          : isSharingScreen
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : _remoteUid
                      .isNotEmpty // Making sure the remote user is in the stream
                  ? kIsWeb // Checking if on web, then use SurfaceView else use TextureView
                      ? RtcRemoteView.SurfaceView(
                          uid: _remoteUid[0],
                          channelId: widget.channelId,
                        )
                      : RtcRemoteView.TextureView(
                          uid: _remoteUid[0],
                          channelId: widget.channelId,
                        )
                  : Container(),
    );
  }

  _chooseCamera() async {
    await _engine.switchCamera().then((value) {
      chooseCamera = !chooseCamera;
      setState(() {});
    }).catchError((error) {
      showSnackBar(context, "Camera error: $error");
    });
  }

  _muteAudio() {
    muted = !muted;
    setState(() {});
    _engine.muteLocalAudioStream(muted);
  }
}
