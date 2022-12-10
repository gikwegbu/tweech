import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> imageUploader(
      String childName, Uint8List imageFile, String uid) async {
    //One user can start livestream at a time,
    //To have multiple/dynamic ones, chain another .child(<randonGeneratedText>);
    Reference _ref = _storage.ref().child(childName).child(uid);
    UploadTask uploadTask = _ref.putData(
      imageFile,
      SettableMetadata(
        contentType: 'image/jpg',
      ),
    );
    TaskSnapshot snapshot = await uploadTask;
    String _downloadUrl = await snapshot.ref.getDownloadURL();
    return _downloadUrl;
  }
}
