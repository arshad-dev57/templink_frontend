import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class JobPostController extends GetxController {
  final descriptionController = TextEditingController();

  final isBold = false.obs;
  final isItalic = false.obs;

  final images = <File>[].obs;

  TextStyle get currentTextStyle {
    return TextStyle(
      fontWeight: isBold.value ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic.value ? FontStyle.italic : FontStyle.normal,
      fontSize: 14,
    );
  }

  void toggleBold() {
    isBold.value = !isBold.value;
  }

  void toggleItalic() {
    isItalic.value = !isItalic.value;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      images.add(File(picked.path));
    }
  }

  void removeImage(int index) {
    images.removeAt(index);
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}
