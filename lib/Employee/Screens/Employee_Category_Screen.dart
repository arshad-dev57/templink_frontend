  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Screens/Employee_Profile_Complete_Screen.dart';
import 'package:templink/Utils/colors.dart';

class EmployeeCategoryScreen extends StatefulWidget {
  const EmployeeCategoryScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeCategoryScreen> createState() =>
      _EmployeeCategoryScreenState();
}

class _EmployeeCategoryScreenState extends State<EmployeeCategoryScreen> {
  final List<String> categories = [
    "Mobile App Development",
    "Web Development",
    "UI / UX Design",
    "Graphic Design",
    "Digital Marketing",
    "Content Writing",
    "Video Editing",
    "SEO",
    "Data Entry",
  ];

  final RxList<String> selectedCategories = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Select Your Interests",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Choose categories so we can show you relevant jobs",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Obx(() => Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: categories.map((cat) {
                      final isSelected =
                          selectedCategories.contains(cat);
                      return GestureDetector(
                        onTap: () {
                          isSelected
                              ? selectedCategories.remove(cat)
                              : selectedCategories.add(cat);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? primary : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: primary),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
            ),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  if (selectedCategories.isEmpty) {
                    Get.snackbar(
                        "Error", "Please select at least one category");
                    return;
                  }
                  // Get.to(() => const EmployeeProfileCompleteScreen());
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
