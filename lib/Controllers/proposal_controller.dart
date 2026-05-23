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
  var sortBy = 'Date'.obs;

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

  // ✅ FETCH WITH DETAILED DEBUG LOGS
  Future<void> fetchMyProposals() async {
    try {
      isLoading.value = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("auth_token");

      print("\n🔵 ===== FLUTTER: FETCHING PROPOSALS =====");
      print("🔵 URL: $baseurl/api/proposals/my");
      print("🔵 Token exists: ${token != null}");

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

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body Length: ${response.body.length} chars");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // 🔍 DEBUG: Raw response structure
        print("\n📊 ===== RAW API RESPONSE STRUCTURE =====");
        print("📊 Response type: ${jsonResponse.runtimeType}");
        print("📊 Response keys: ${jsonResponse is Map ? jsonResponse.keys : 'NOT A MAP'}");
        
        if (jsonResponse is Map) {
          print("📊 Has 'proposals' key: ${jsonResponse.containsKey('proposals')}");
          print("📊 Has 'data' key: ${jsonResponse.containsKey('data')}");
          print("📊 Has 'total' key: ${jsonResponse.containsKey('total')}");
        }
        
        final proposalsResponse = ProposalsResponse.fromJson(jsonResponse);
        final rawProposals = proposalsResponse.proposals;
        
        print("\n📊 Total proposals from API: ${rawProposals.length}");
        
        // 🔍 DEBUG: Each proposal ka detailed info
        print("\n═══════════════════════════════════════");
        print("══════ INDIVIDUAL PROPOSAL DEBUG ══════");
        print("═══════════════════════════════════════");
        
        for (int i = 0; i < rawProposals.length; i++) {
          final p = rawProposals[i];
          
          print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          print("📋 Proposal #${i + 1}:");
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          print("   🔑 ID: ${p.id}");
          print("   📌 Raw Status: ${p.status}");
          print("   📌 Display Status: ${p.displayStatus}");
          print("   📌 Status Type: ${p.statusType}");
          print("   📁 Project ID: ${p.project.id}");
          print("   📁 Project Title: ${p.project.title}");
          print("   👤 Client: ${p.project.employerSnapshot.displayName}");
          print("   💰 Budget: ${p.displayBudget}");
          print("   📅 Date: ${p.displayDate}");
          print("   ⭐ Match Score: ${p.matchScore}%");
          
          // ✅ CONTRACT DATA
          print("   ─── CONTRACT INFO ───");
          print("   📄 Contract Status: ${p.contractStatus ?? 'NULL'}");
          print("   📄 Contract ID: ${p.contractId ?? 'NULL'}");
          print("   📄 Has Active Contract: ${p.hasActiveContract}");
          print("   📄 Contract Pending: ${p.contractPending}");
          print("   📄 Has Contract: ${p.hasContract}");
          
          if (p.hasContract) {
            print("   📄 Contract Button Text: ${p.contractButtonText}");
          }
          
          // ✅ BUTTON DECISION (Flutter: _getActionButtons logic)
          print("   ─── BUTTON DECISION ───");
          String buttonType = "UNKNOWN";
          String buttonLabel = "N/A";
          
          if (p.statusType == 'submitted') {
            buttonType = "WITHDRAW";
            buttonLabel = "Withdraw";
          } else if (p.statusType == 'accepted') {
            buttonType = "CHAT + CONTRACT";
            if (p.contractStatus == 'COMPLETED') {
              buttonLabel = "HIDDEN (Contract Completed)";
            } else if (p.hasActiveContract) {
              buttonLabel = "View Contract";
            } else {
              buttonLabel = "Sign Contract";
            }
          } else if (p.statusType == 'rejected') {
            buttonType = "FEEDBACK + SIMILAR";
            buttonLabel = "Feedback + Similar Projects";
          }
          
          print("   🎯 Button Type: $buttonType");
          print("   🎯 Button Label: $buttonLabel");
          
          // ✅ SHOW/HIDE logic
          print("   ─── VISIBILITY ───");
          print("   👁 Should Show (not withdrawn + not completed): ${_shouldShowProposal(p)}");
          print("   🚫 Is Withdrawn: ${p.statusType == 'withdrawn'}");
          print("   🚫 Is Contract Completed: ${p.contractStatus != null && excludedContractStatuses.contains(p.contractStatus)}");
        }
        
        // ✅ Filter and set
        proposals.value = proposalsResponse.proposals
            .where((p) => _shouldShowProposal(p))
            .toList();
        
        print("\n📊 ===== FILTERED RESULTS =====");
        print("📊 Before filter: ${rawProposals.length}");
        print("📊 After _shouldShowProposal: ${proposals.length}");
        print("   - Submitted: ${proposals.where((p) => p.statusType == 'submitted').length}");
        print("   - Accepted: ${proposals.where((p) => p.statusType == 'accepted').length}");
        print("   - Rejected: ${proposals.where((p) => p.statusType == 'rejected').length}");
        print("   - Withdrawn: ${proposals.where((p) => p.statusType == 'withdrawn').length}");

        filterProposals();
      } else {
        print("❌ Failed to load proposals: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        throw 'Failed to load proposals: ${response.statusCode}';
      }
    } catch (e) {
      print("❌ Exception in fetchMyProposals: $e");
      Get.snackbar(
        'Error',
        'Failed to fetch proposals: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print("🟢 ===== FETCH COMPLETE =====\n");
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

    // Sort by selected criteria
    switch (sortBy.value) {
      case 'Date':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Match Score':
        filtered.sort((a, b) => b.matchScore.compareTo(a.matchScore));
        break;
      case 'Budget':
        filtered.sort((a, b) {
          final budgetA = _parseBudget(a.displayBudget);
          final budgetB = _parseBudget(b.displayBudget);
          return budgetB.compareTo(budgetA);
        });
        break;
    }

    filteredProposals.value = filtered;
    
    print("🔍 filterProposals: ${filtered.length} results (status: ${selectedStatus.value}, search: '${searchQuery.value}', sort: '${sortBy.value}')");
  }

  double _parseBudget(String budgetString) {
    // Parse budget strings like "$500 - $1000" or "$500" to get the max value
    final regex = RegExp(r'[\$,\s]');
    final parts = budgetString.split(regex).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 0.0;
    try {
      return double.parse(parts.last);
    } catch (e) {
      return 0.0;
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    filterProposals();
  }

  void updateStatus(String status) {
    selectedStatus.value = status;
    filterProposals();
  }

  void updateSortBy(String sort) {
    sortBy.value = sort;
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
      print("\n🔴 ===== WITHDRAW PROPOSAL =====");
      print("🔴 Proposal ID: $proposalId");
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
      
      print("🔴 Withdraw Response Status: ${response.statusCode}");
      print("🔴 Withdraw Response Body: ${response.body}");

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
      print("❌ Withdraw error: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print("🟢 ===== WITHDRAW COMPLETE =====\n");
    }
  }
}