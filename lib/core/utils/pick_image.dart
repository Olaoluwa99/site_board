import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImage() async {
  try {
    final inFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (inFile != null) {
      return File(inFile.path);
    }
    return null;
  } catch (e) {
    return null;
  }
}
