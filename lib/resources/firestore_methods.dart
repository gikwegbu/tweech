import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tweech/config/constants.dart';
import 'package:tweech/models/liveStream_model.dart';
import 'package:tweech/providers/user_provider.dart';
import 'package:tweech/resources/storage_methods.dart';
import 'package:tweech/utils/utils.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storageMethods = StorageMethods();
  final storageRef = FirebaseStorage.instance.ref();

  Future<String> startLiveStream(
      BuildContext context, String title, Uint8List? imageFile) async {
    final _user = Provider.of<UserProvider>(context, listen: false).user;
    String _channelId = '';
    try {
      if (title.isNotEmpty && imageFile != null) {
        // Checking if current User already has a livestream going on

        if ((await _firestore
                .collection(liveStreamCollection)
                .doc('${_user.uid}${_user.username}')
                .get())
            .exists) {
          showSnackBar(context, "Oops!! you're already liveStreaming...");
        } else {
          String _thumbnailUrl = await _storageMethods.imageUploader(
            liveStreamThumbnails,
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
              .collection(liveStreamCollection)
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

  Future<void> exitLiveStreaming(BuildContext context, String channelId) async {
    final _user = Provider.of<UserProvider>(context, listen: false).user;
    try {
      // Getting all the comments under the livestream thread, so we can delete them
      QuerySnapshot snap = await _firestore
          .collection(liveStreamCollection)
          .doc(channelId)
          .collection(liveStreamCommentsCollection)
          .get();

      for (int i = 0; i < snap.docs.length; i++) {
        await _firestore
            .collection(liveStreamCollection)
            .doc(channelId)
            .collection(liveStreamCommentsCollection)
            .doc(((snap.docs[i].data()! as dynamic)['commentId']))
            .delete();
      }
      await _firestore.collection(liveStreamCollection).doc(channelId).delete();
      // delete the thumbnail from the storage bucket...
      // Create a reference to the file to delete
      final desertRef = storageRef.child("$liveStreamThumbnails/${_user.uid}");

      // // Delete the file
      await desertRef.delete();
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> modifyViewCounter(
      BuildContext context, String id, bool isStepping) async {
    try {
      await _firestore.collection(liveStreamCollection).doc(id).update({
        // 1, means you're entering the livestream
        // -1 means you're leaving the livestream
        'viewers': FieldValue.increment(isStepping ? 1 : -1),
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> chatting(BuildContext context, String msg, String id) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    try {
      String commentId = const Uuid().v1();
      await _firestore
          .collection(liveStreamCollection)
          .doc(id)
          .collection(liveStreamCommentsCollection)
          .doc(commentId)
          .set({
        "username": user.username,
        "message": msg,
        "uid": user.uid,
        "createdAt": DateTime.now(),
        "commentId": commentId,
      });
      print("Message was successfully sent...");
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}
