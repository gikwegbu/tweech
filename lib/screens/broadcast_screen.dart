import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:tweech/config/appId.dart';
import 'package:provider/provider.dart';
import 'package:tweech/providers/user_provider.dart';
import 'package:tweech/resources/firestore_methods.dart';
import 'package:tweech/screens/home_screen.dart';
import 'package:tweech/widget/chat.dart';

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
  late final RtcEngine _engine;

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

    await _engine.joinChannel(agoraTempToken, widget.channelId, null, 0);
  }

  void _addListeners() async {
    _engine.setEventHandler(
      RtcEngineEventHandler(
          joinChannelSuccess: (String channel, int uid, int elapsed) {
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
      }),
    );
  }

  void _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await _engine.joinChannelWithUserAccount(
      agoraTempToken,
      widget.channelId,
      Provider.of<UserProvider>(context, listen: false).user.uid,
    );
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
    navigateAndClearPrev(context, HomeScreen.routeName);
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final _supposedChannelId = "${user.uid}${user.username}";
    return WillPopScope(
      onWillPop: () async {
        await _exitLiveStreaming();
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _renderVideo(user),
                if (_supposedChannelId == widget.channelId) // The person that started the meeting, won't be able to see it
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      child:  Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(muted ? 'Unmute' : 'Mute'),
                      ),
                    ),
                    const SizedBox(height: 40),
                    InkWell(
                      onTap:  _exitLiveStreaming,
                      child: const Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Text('Back Button'),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ChatComponent(
                    channelId: widget.channelId,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderVideo(user) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: "${user.uid}${user.username}" ==
              widget
                  .channelId // Detecting if the current user started the live streaming...
          ? const RtcLocalView.SurfaceView(
              zOrderMediaOverlay: true,
              zOrderOnTop: true,
            )
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

  _chooseCamera() async{
    await _engine.switchCamera().then((value) {
      print("George this is the switched camera: value ${_engine.switchCamera()}");
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
