import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:templink/widgets/toast_widget.dart';

class RegisterController extends GetxController {
final String baseUrl = "http://192.168.100.29:5000/api/register";

  var isLoading = false.obs;

  Future<void> registerEmployee({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String jobPosition,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;

      final body = jsonEncode({
        "type": "employee",
        "fullName": fullName,
        "email": email,
        "phoneNumber": phoneNumber,
        "jobPosition": jobPosition,
        "password": password,
        "confirmPassword": confirmPassword,
      });

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Employee registered successfully!");
        print("Response: ${response.body}");
      } else {
        Get.snackbar("Error", "Failed to register employee");
        print("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      print("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerCompany({
    required String companyName,
    required String officialEmail,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;

      final body = jsonEncode({
        "type": "company",
        "companyName": companyName,
        "officialEmail": officialEmail,
        "phoneNumber": phoneNumber,
        "password": password,
        "confirmPassword": confirmPassword,
      });

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastWidget.show(
          context: Get.context!,
          title: "Success",
          type: ToastType.success,
          subtitle: "Company registered successfully!",
        );
        print("Response: ${response.body}");
      } else {
        ToastWidget.show(
          context: Get.context!,
          title: "Error",
          type: ToastType.error,
          subtitle: "Failed to register company",
        );
        print("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      ToastWidget.show(
        context: Get.context!,
        title: "Error",
        type: ToastType.error,
        subtitle: "Something went wrong: $e",
      );
      print("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
