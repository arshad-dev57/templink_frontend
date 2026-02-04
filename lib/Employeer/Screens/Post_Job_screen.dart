import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/job_post_controller.dart';
import 'package:templink/Utils/colors.dart';

class JobPostScreen extends StatelessWidget {
  JobPostScreen({Key? key}) : super(key: key);

  final controller = Get.put(JobPostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Post a New Job",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("JOB DESCRIPTION"),
            const SizedBox(height: 6),
            _descriptionBox(),
            const SizedBox(height: 10),
            _editorActions(),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label("MEDIA GALLERY"),
                TextButton(
                  onPressed: controller.pickImage,
                  child: const Text("Add More"),
                )
              ],
            ),
            const SizedBox(height: 12),
            _mediaGallery(),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Publish Post",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
    );
  }

  Widget _descriptionBox() {
    return Obx(
      () => TextField(
        controller: controller.descriptionController,
        maxLines: 6,
        style: controller.currentTextStyle,
        decoration: InputDecoration(
          hintText: "Describe the role, responsibilities, and requirements...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _editorActions() {
    return Obx(
      () => Row(
        children: [
          _iconButton(
            Icons.format_bold,
            active: controller.isBold.value,
            onTap: controller.toggleBold,
          ),
          _iconButton(
            Icons.format_italic,
            active: controller.isItalic.value,
            onTap: controller.toggleItalic,
          ),
         
        
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon,
      {required VoidCallback onTap, bool active = false}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: active ? primary : Colors.black54,
      ),
    );
  }

  Widget _mediaGallery() {
    return Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _uploadBox(),
          ...List.generate(
            controller.images.length,
            (index) => _pickedImage(controller.images[index], index),
          )
        ],
      ),
    );
  }

  Widget _uploadBox() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.grey),
            SizedBox(height: 4),
            Text("Upload", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _pickedImage(File file, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removeImage(index),
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
