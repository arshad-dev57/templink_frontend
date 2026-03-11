import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:templink/Models/proposals_model.dart';
import 'package:templink/config/api_config.dart';

class ProposalController extends GetxController {
  var isLoading = false.obs;
  var proposalResponse = Rx<ProposalResponse?>(null);
  final baseurl = ApiConfig.baseUrl;

  Future<bool> submitProposal(ProposalRequest proposal) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("auth_token");
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('$baseurl/api/proposals/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(proposal.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw 'Connection timeout. Please try again.';
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        proposalResponse.value = ProposalResponse.fromJson(jsonResponse);
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Failed to submit proposal';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<PortfolioProject>> getPortfolioProjects() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      PortfolioProject(
        portfolioId: "65bcaf4d9c8e1d25e81f9911",
        title: "E-commerce App",
        description: "Complete e-commerce solution with Firebase backend",
        imageUrl: "https://yourcdn.com/project1.png",
        completionDate: "Jan 2024",
      ),
      PortfolioProject(
        portfolioId: "65bcaf4d9c8e1d25e81f9912",
        title: "Healthcare App",
        description: "Appointment booking and patient management",
        imageUrl: "https://yourcdn.com/project2.png",
        completionDate: "Nov 2023",
      ),
      PortfolioProject(
        portfolioId: "65bcaf4d9c8e1d25e81f9913",
        title: "Food Delivery App",
        description: "Restaurant and food delivery application",
        imageUrl: "https://yourcdn.com/project3.png",
        completionDate: "Jul 2023",
      ),
    ];
  }

  Future<String?> uploadFile(String filePath, String fileName) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return 'https://yourcdn.com/$fileName';
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload file: $e');
      return null;
    }
  }

  var proposals = <ProposalModel>[].obs;
  var filteredProposals = <ProposalModel>[].obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'All'.obs;

  // ✅ Proposal status + Contract status dono exclude honge
  final List<String> excludedProposalStatuses = ['completed', 'Completed', 'COMPLETED'];
  final List<String> excludedContractStatuses = ['COMPLETED', 'completed', 'Completed'];

  // ✅ Yeh method check karta hai ke proposal show hona chahiye ya nahi
  bool _shouldShowProposal(ProposalModel p) {
    if(p.statusType == 'withdrawn') return false;
    // Proposal ka apna status completed nahi hona chahiye
    if (excludedProposalStatuses.contains(p.displayStatus)) return false;

    // ✅ Contract ka status bhi COMPLETED nahi hona chahiye
    if (p.contractStatus != null &&
        excludedContractStatuses.contains(p.contractStatus)) return false;

    return true;
  }

  @override
  void onInit() {
    super.onInit();
    fetchMyProposals();
  }

  List<String> get statusTabs {
    final statuses = ['All'];
    final uniqueStatuses = proposals
        .where((p) => _shouldShowProposal(p))
        .map((p) => p.displayStatus)
        .toSet()
        .toList();
    statuses.addAll(uniqueStatuses);
    return statuses;
  }

  Future<void> fetchMyProposals() async {
    try {
      isLoading.value = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("auth_token");

      final response = await http.get(
        Uri.parse('$baseurl/api/proposals/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw 'Connection timeout. Please try again.';
        },
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final proposalsResponse = ProposalsResponse.fromJson(jsonResponse);
        proposals.value = proposalsResponse.proposals
            .where((p) => _shouldShowProposal(p))
            .toList();

        filterProposals();
      } else {
        throw 'Failed to load proposals: ${response.statusCode}';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch proposals: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("error in proposals $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterProposals() {
    // ✅ Pehle dono conditions se filter karo
    var filtered = proposals
        .where((p) => _shouldShowProposal(p))
        .toList();

    // Filter by status tab
    if (selectedStatus.value != 'All') {
      filtered = filtered
          .where((p) => p.displayStatus == selectedStatus.value)
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((p) {
        return p.project.title.toLowerCase().contains(query) ||
            p.project.employerSnapshot.displayName.toLowerCase().contains(query) ||
            p.coverLetter.toLowerCase().contains(query);
      }).toList();
    }

    filteredProposals.value = filtered;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    filterProposals();
  }

  void updateStatus(String status) {
    selectedStatus.value = status;
    filterProposals();
  }

  int getCountByStatus(String status) {
    if (status == 'All') {
      return proposals.where((p) => _shouldShowProposal(p)).length;
    }
    return proposals
        .where((p) => _shouldShowProposal(p))
        .where((p) => p.displayStatus == status)
        .length;
  }

  List<ProposalModel> getProposalsByStatusType(String statusType) {
    return proposals
        .where((p) => _shouldShowProposal(p))
        .where((p) => p.statusType == statusType)
        .where((p) {
          if (searchQuery.value.isEmpty) return true;
          final query = searchQuery.value.toLowerCase();
          return p.project.title.toLowerCase().contains(query) ||
              p.project.employerSnapshot.displayName.toLowerCase().contains(query);
        })
        .toList();
  }

  // ✅ Stats bhi sirf visible proposals ki count karengi
  int get totalProposals =>
      proposals.where((p) => _shouldShowProposal(p)).length;

  int get submittedCount => proposals
      .where((p) => _shouldShowProposal(p))
      .where((p) => p.statusType == 'submitted')
      .length;

  int get acceptedCount => proposals
      .where((p) => _shouldShowProposal(p))
      .where((p) => p.statusType == 'accepted')
      .length;

  int get rejectedCount => proposals
      .where((p) => _shouldShowProposal(p))
      .where((p) => p.statusType == 'rejected')
      .length;
Future<void> withdrawProposal(String proposalId) async {
  
    try {
      print("called withdwal");
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("auth_token");

      final response = await http.patch(
        Uri.parse('$baseurl/api/proposals/withdraw/$proposalId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw 'Connection timeout. Please try again.';
        },
      );
      print("withdral body");
print(response.body);
      if (response.statusCode == 200) {
        // ✅ API success — list refresh karo
        await fetchMyProposals();

        Get.snackbar(
          'Success',
          'Proposal withdrawn successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Failed to withdraw proposal';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}