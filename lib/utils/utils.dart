import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

// Navigation Helper Functions
navigateTo(BuildContext context, route) {
  Navigator.pushNamed(context, route);
}

navigateAndClearPrev(BuildContext context, route) {
  Navigator.pushReplacementNamed(context, route);
}

Future<Uint8List?> imagePicker() async {
  FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );
  if (pickedImage != null) {
    if (kIsWeb) {
      //bytes here has value because it's on the web.
      return pickedImage.files.single.bytes;
    }
    //Use path here, as it's on a mobile device.
    return await File(pickedImage.files.single.path!).readAsBytes();
  }
}
