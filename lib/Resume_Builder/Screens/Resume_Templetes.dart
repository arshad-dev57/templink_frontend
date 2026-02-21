import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
import 'package:templink/Utils/colors.dart';

class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResumeController>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Professional Template',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a design that best represents your professional brand',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Templates Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: controller.templates.length,
            itemBuilder: (context, index) {
              final template = controller.templates[index];
              return Obx(() => GestureDetector(
                onTap: () => controller.selectTemplate(index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.selectedTemplateIndex.value == index
                          ? primary
                          : Colors.grey[300]!,
                      width: controller.selectedTemplateIndex.value == index ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template Preview
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: template.backgroundColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: template.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Simulated template layout
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: template.accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              if (template.showSidebar)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 40,
                                    color: template.primaryColor.withOpacity(0.3),
                                  ),
                                ),
                              Positioned(
                                top: 50,
                                left: 20,
                                right: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 8,
                                      width: 80,
                                      color: template.primaryColor,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 6,
                                      width: 60,
                                      color: template.secondaryColor,
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 4,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Template Name & Selected Badge
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  template.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (controller.selectedTemplateIndex.value == index)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Selected',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            },
          ),
        ],
      ),
    );
  }
}