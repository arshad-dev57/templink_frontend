import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:flutter/material.dart';

class SearchingController extends GetxController {
  // ==================== OBSERVABLES ====================
  var isLoading = false.obs;
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  var selectedTab = 'all'.obs;
  var errorMessage = ''.obs;

  // Results
  var projects = <Map<String, dynamic>>[].obs;
  var jobs = <Map<String, dynamic>>[].obs;
  var talents = <Map<String, dynamic>>[].obs;

  // Suggestions
  var suggestions = <Map<String, dynamic>>[].obs;
  var showSuggestions = false.obs;

  // Search History (local)
  var searchHistory = <String>[].obs;

  final String baseUrl = ApiConfig.baseUrl;

  // ==================== TABS CONFIGURATION ====================
  final List<Map<String, dynamic>> tabs = const [
    {'id': 'all', 'label': 'All', 'icon': Icons.search},
    {'id': 'projects', 'label': 'Projects', 'icon': Icons.folder},
    {'id': 'jobs', 'label': 'Jobs', 'icon': Icons.work},
    {'id': 'talents', 'label': 'Talents', 'icon': Icons.person},
  ];

  // ==================== GETTERS ====================
  List<Map<String, dynamic>> get currentResults {
    switch (selectedTab.value) {
      case 'projects':
        return projects;
      case 'jobs':
        return jobs;
      case 'talents':
        return talents;
      default:
        // Merge all results for 'all' tab
        return [
          ...projects.map((p) => {...p, 'type': 'project'}),
          ...jobs.map((j) => {...j, 'type': 'job'}),
          ...talents.map((t) => {...t, 'type': 'talent'}),
        ];
    }
  }

  int get totalResults {
    return projects.length + jobs.length + talents.length;
  }

  bool get hasResults {
    return projects.isNotEmpty || jobs.isNotEmpty || talents.isNotEmpty;
  }

  // ==================== INIT ====================
  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
    
    // Debounce for search
    debounce(
      searchQuery,
      (_) {
        if (searchQuery.value.length >= 2) {
          performSearch();
        } else if (searchQuery.value.isEmpty) {
          clearResults();
        }
      },
      time: const Duration(milliseconds: 500),
    );
  }

  // ==================== SEARCH HISTORY ====================
  Future<void> _loadSearchHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? history = prefs.getStringList('search_history');
      if (history != null) {
        searchHistory.value = history;
      }
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  Future<void> _saveToHistory(String query) async {
    try {
      if (query.trim().isEmpty) return;
      
      // Remove if already exists
      searchHistory.remove(query);
      // Add to beginning
      searchHistory.insert(0, query);
      // Keep only last 10
      if (searchHistory.length > 10) {
        searchHistory.removeRange(10, searchHistory.length);
      }
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', searchHistory);
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  void clearHistory() {
    searchHistory.clear();
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('search_history');
    });
  }

  // ==================== SEARCH METHODS ====================
  void onSearchChanged(String query) {
    searchQuery.value = query;
    
    if (query.length >= 1) {
      getSuggestions();
    } else {
      suggestions.clear();
      showSuggestions.value = false;
    }
  }

  Future<void> getSuggestions() async {
    if (searchQuery.value.length < 1) {
      suggestions.clear();
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/search/suggestions?q=${Uri.encodeComponent(searchQuery.value)}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        suggestions.value = List<Map<String, dynamic>>.from(data['suggestions'] ?? []);
        showSuggestions.value = suggestions.isNotEmpty;
      } else {
        suggestions.clear();
      }
    } catch (e) {
      print('Suggestions error: $e');
      suggestions.clear();
    }
  }

  Future<void> performSearch() async {
    if (searchQuery.value.length < 2) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      showSuggestions.value = false;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/search/all?q=${Uri.encodeComponent(searchQuery.value)}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Connection timeout. Please try again.',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save to history
        _saveToHistory(searchQuery.value);

        // Update results
        if (data['results'] != null) {
          projects.value = List<Map<String, dynamic>>.from(data['results']['projects'] ?? []);
          jobs.value = List<Map<String, dynamic>>.from(data['results']['jobs'] ?? []);
          talents.value = List<Map<String, dynamic>>.from(data['results']['talents'] ?? []);
        }

        // Auto-select tab based on results
        _autoSelectTab();
      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Search failed';
        clearResults();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      clearResults();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchByType(String type) async {
    if (searchQuery.value.length < 2) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/search/$type?q=${Uri.encodeComponent(searchQuery.value)}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        switch(type) {
          case 'projects':
            projects.value = List<Map<String, dynamic>>.from(data['results'] ?? []);
            break;
          case 'jobs':
            jobs.value = List<Map<String, dynamic>>.from(data['results'] ?? []);
            break;
          case 'talents':
            talents.value = List<Map<String, dynamic>>.from(data['results'] ?? []);
            break;
        }
      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Search failed';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void searchAll(String query) {
    searchQuery.value = query;
    performSearch();
  }

  void selectSuggestion(Map<String, dynamic> suggestion) {
    searchQuery.value = suggestion['text'];
    showSuggestions.value = false;
    performSearch();
  }

  void clearResults() {
    projects.clear();
    jobs.clear();
    talents.clear();
  }

  void clearSearch() {
    searchQuery.value = '';
    suggestions.clear();
    showSuggestions.value = false;
    clearResults();
    selectedTab.value = 'all';
  }

  // ==================== UTILITY METHODS ====================
  void _autoSelectTab() {
    if (projects.isNotEmpty && jobs.isEmpty && talents.isEmpty) {
      selectedTab.value = 'projects';
    } else if (jobs.isNotEmpty && projects.isEmpty && talents.isEmpty) {
      selectedTab.value = 'jobs';
    } else if (talents.isNotEmpty && projects.isEmpty && jobs.isEmpty) {
      selectedTab.value = 'talents';
    } else {
      selectedTab.value = 'all';
    }
  }

  String getResultIcon(String type) {
    switch(type) {
      case 'project':
        return '📁';
      case 'job':
        return '💼';
      case 'talent':
        return '👤';
      default:
        return '🔍';
    }
  }

  Color getResultColor(String type) {
    switch(type) {
      case 'project':
        return Colors.blue;
      case 'job':
        return Colors.green;
      case 'talent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // ==================== FILTER METHODS ====================
  List<Map<String, dynamic>> filterProjects({String? category, int? minBudget, int? maxBudget}) {
    return projects.where((p) {
      if (category != null && p['category'] != category) return false;
      if (minBudget != null) {
        final budget = p['minBudget'] ?? 0;
        if (budget < minBudget) return false;
      }
      if (maxBudget != null) {
        final budget = p['maxBudget'] ?? 0;
        if (budget > maxBudget) return false;
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> filterJobs({String? type, String? workplace, bool? urgent}) {
    return jobs.where((j) {
      if (type != null && j['type'] != type) return false;
      if (workplace != null && j['workplace'] != workplace) return false;
      if (urgent != null && j['urgency'] != urgent) return false;
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> filterTalents({String? skill, double? minRating, String? hourlyRate}) {
    return talents.where((t) {
      if (skill != null) {
        final skills = List<String>.from(t['skills'] ?? []);
        if (!skills.contains(skill)) return false;
      }
      if (minRating != null) {
        final rating = (t['rating'] ?? 0).toDouble();
        if (rating < minRating) return false;
      }
      return true;
    }).toList();
  }

  // ==================== STATISTICS ====================
  Map<String, int> getCategoryCounts() {
    final counts = <String, int>{};
    for (var project in projects) {
      final category = project['category'] ?? 'Other';
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getJobTypeCounts() {
    final counts = <String, int>{};
    for (var job in jobs) {
      final type = job['type'] ?? 'Other';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getSkillCounts() {
    final counts = <String, int>{};
    for (var talent in talents) {
      final skills = List<String>.from(talent['skills'] ?? []);
      for (var skill in skills) {
        counts[skill] = (counts[skill] ?? 0) + 1;
      }
    }
    return counts;
  }

  // ==================== SORTING ====================
  void sortProjects(String sortBy) {
    switch(sortBy) {
      case 'newest':
        projects.sort((a, b) {
          final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
          final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        break;
      case 'budget_high':
        projects.sort((a, b) {
          final aBudget = a['maxBudget'] ?? 0;
          final bBudget = b['maxBudget'] ?? 0;
          return bBudget.compareTo(aBudget);
        });
        break;
      case 'budget_low':
        projects.sort((a, b) {
          final aBudget = a['minBudget'] ?? 0;
          final bBudget = b['minBudget'] ?? 0;
          return aBudget.compareTo(bBudget);
        });
        break;
    }
  }

  void sortJobs(String sortBy) {
    switch(sortBy) {
      case 'newest':
        jobs.sort((a, b) {
          final aDate = DateTime.tryParse(a['postedDate'] ?? '') ?? DateTime(2000);
          final bDate = DateTime.tryParse(b['postedDate'] ?? '') ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        break;
      case 'urgent':
        jobs.sort((a, b) {
          if (a['urgency'] == true && b['urgency'] != true) return -1;
          if (a['urgency'] != true && b['urgency'] == true) return 1;
          return 0;
        });
        break;
    }
  }

  void sortTalents(String sortBy) {
    switch(sortBy) {
      case 'rating':
        talents.sort((a, b) {
          final aRating = (a['rating'] ?? 0).toDouble();
          final bRating = (b['rating'] ?? 0).toDouble();
          return bRating.compareTo(aRating);
        });
        break;
      case 'hourly_low':
        talents.sort((a, b) {
          final aRate = _extractHourlyRate(a['hourlyRate'] ?? '');
          final bRate = _extractHourlyRate(b['hourlyRate'] ?? '');
          return aRate.compareTo(bRate);
        });
        break;
      case 'hourly_high':
        talents.sort((a, b) {
          final aRate = _extractHourlyRate(a['hourlyRate'] ?? '');
          final bRate = _extractHourlyRate(b['hourlyRate'] ?? '');
          return bRate.compareTo(aRate);
        });
        break;
    }
  }

  double _extractHourlyRate(String rateString) {
    try {
      final cleaned = rateString.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0;
    } catch (e) {
      return 0;
    }
  }
}