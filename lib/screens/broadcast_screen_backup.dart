import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tweech/config/appId.dart';
import 'package:tweech/providers/user_provider.dart';

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
  late final RtcEngine _engine;
  int? _remoteUid;

  // List<int> _remoteUid = [];
  bool _localUserJoined = false;

  @override
  void initState() {
    super.initState();
    _initAgoraEngine();
  }

  Future<void> _initAgoraEngine() async {
    // // retrieve permissions
    // await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: agoraId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user <:${connection.localUid}:> joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            // _remoteUid.add(remoteUid);
            _remoteUid = _remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user <:$remoteUid:> left channel because $reason");
          setState(() {
            // _remoteUid.removeWhere((element) => element == remoteUid);
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint("User LeftChannel $stats");
          setState(() {
            // _remoteUid.clear();
          });
        },
      ),
    );
    // await _engine.setClientRole(
    //   // Either this user creates the stream (Broadcaster), or
    //   // joins a stream (Audience)
    //   role: ClientRoleType.clientRoleBroadcaster,
    // );
    if (widget.isBroadcaster) {
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    } else {
      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

    await _engine.joinChannel(
      token: agoraTempToken,
      channelId: agoraChannel,
      uid: 0,
      options: const ChannelMediaOptions(
        publishCustomAudioSourceId: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          // canvas: VideoCanvas(uid: _remoteUid[0]),
          canvas: VideoCanvas(uid: _remoteUid),
          rtcEngine: _engine,
          connection: RtcConnection(channelId: widget.channelId),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  void _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // retrieve permissions
      await [Permission.microphone, Permission.camera].request();
      await _engine.joinChannelWithUserAccount(
          token: agoraTempToken,
          channelId: agoraChannel,
          userAccount:
          Provider.of<UserProvider>(context, listen: false).user.uid);
    }
  }

  @override
  void dispose() {
    /* Other dispose logic */

    // Releases hardware resources
    // and should allow reconnection
    // with hot reload/restart
    _engine.release();

    super.dispose();
  }
}
