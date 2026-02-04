import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Utils/colors.dart';

class EmployeeProfileCompleteScreen extends StatelessWidget {
  const EmployeeProfileCompleteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController fullNameController =
        TextEditingController();
    final TextEditingController titleController =
        TextEditingController();
    final TextEditingController bioController =
        TextEditingController();
    final TextEditingController skillsController =
        TextEditingController();
    final TextEditingController experienceController =
        TextEditingController();
    final TextEditingController hourlyRateController =
        TextEditingController();
    final TextEditingController locationController =
        TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Complete Your Profile",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            /// PROFILE IMAGE
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primary.withOpacity(0.2),
                    child: const Icon(Icons.person,
                        size: 50, color: primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _sectionTitle("Basic Information"),
            _field("Full Name", fullNameController),
            _field("Professional Title (e.g Flutter Developer)", titleController),

            const SizedBox(height: 24),

            _sectionTitle("About You"),
            _field(
              "Short Bio",
              bioController,
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            _sectionTitle("Professional Details"),
            _field(
              "Skills (Flutter, Firebase, UI/UX)",
              skillsController,
            ),
            _field(
              "Experience (Years)",
              experienceController,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            _sectionTitle("Availability"),
            _field(
              "Hourly Rate (USD)",
              hourlyRateController,
              keyboardType: TextInputType.number,
            ),
            _field(
              "Location (Country / City)",
              locationController,
            ),

            const SizedBox(height: 36),

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
                  // Save profile data
                  // Get.offAll(() => HomeScreen());
                },
                child: const Text(
                  "Save & Continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  /// COMMON FIELD
  Widget _field(
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: primary),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
