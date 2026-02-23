import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Screens/PostProjectScreen.dart';
import 'package:templink/Employeer/Screens/Post_Job_screen.dart';
import 'package:templink/Utils/colors.dart';

class SelectPostTypeScreen extends StatelessWidget {
  SelectPostTypeScreen({Key? key}) : super(key: key);

  final controller = Get.put(PostTypeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Create a Post",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What would you like to post?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Choose one option to continue",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Post a Project Option
            Obx(() => _postOption(
                  title: "Post a Project",
                  subtitle: "Showcase your project or idea",
                  icon: Icons.lightbulb_outline,
                  selected: controller.selectedType.value == PostType.project,
                  onTap: () => controller.select(PostType.project),
                )),

            const SizedBox(height: 16),

            // Hiring Post Option
            Obx(() => _postOption(
                  title: "Hiring Post",
                  subtitle: "Find talent for your job",
                  icon: Icons.work_outline,
                  selected: controller.selectedType.value == PostType.hiring,
                  onTap: () => controller.select(PostType.hiring),
                )),

            const Spacer(),

            // Continue Button
            Obx(() {
              final isSelected = controller.selectedType.value != null;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSelected
                      ? () {
                          if (controller.selectedType.value == PostType.project) {
                            Get.to(() => PostProjectScreen());
                          } else if (controller.selectedType.value == PostType.hiring) {
                            Get.to(() => JobPostScreen());
                          }
                        }
                      : null, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? primary : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _postOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected ? primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected ? primary : Colors.grey.shade200,
              child: Icon(icon, color: selected ? Colors.white : Colors.black54),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: selected ? primary : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: primary),
          ],
        ),
      ),
    );
  }
}



enum PostType { project, hiring }

class PostTypeController extends GetxController {
  final selectedType = Rx<PostType?>(null);

  void select(PostType type) {
    selectedType.value = type;
  }
}