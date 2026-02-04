import 'package:get/get.dart';

enum PostType { project, hiring }

class PostTypeController extends GetxController {
  final selectedType = PostType.project.obs;

  void select(PostType type) {
    selectedType.value = type;
  }
}
