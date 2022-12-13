import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tweech/models/liveStream_model.dart';
import 'package:tweech/providers/user_provider.dart';
import 'package:tweech/resources/storage_methods.dart';
import 'package:tweech/utils/utils.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storageMethods = StorageMethods();

  Future<String> startLiveStream(
      BuildContext context, String title, Uint8List? imageFile) async {
    final _user = Provider.of<UserProvider>(context, listen: false).user;
    String _channelId = '';
    try {
      if (title.isNotEmpty && imageFile != null) {
        // Checking if current User already has a livestream going on

        // if ((await _firestore.collection('livestream').doc('${_user.uid}${_user.username}').get())
        if ((await _firestore.collection('livestream').doc(_user.uid).get())
            .exists) {
          showSnackBar(context, "Oops!! you're already liveStreaming...");
        } else {
          String _thumbnailUrl = await _storageMethods.imageUploader(
            'Livestream-thumbnails',
            imageFile,
            _user.uid,
          );

          _channelId = '${_user.uid}${_user.username}';

          LiveStream liveStream = LiveStream(
            title: title,
            image: _thumbnailUrl,
            uid: _user.uid,
            username: _user.username,
            createAt: DateTime.now(),
            viewers: 0,
            channelId: _channelId,
          );

          _firestore
              .collection('livestream')
              .doc(_channelId)
              .set(liveStream.toMap());
        }
      } else {
        showSnackBar(context, "All field's are required.");
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return _channelId;
  }
}
