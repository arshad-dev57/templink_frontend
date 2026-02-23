import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/search_controller.dart';
import 'package:templink/Employee/models/project_model.dart' as project_model; // ✅ Alias for project model
import 'package:templink/Employee/models/Employee_jobs_model.dart' as job_model; // ✅ Alias for job model
import 'package:templink/Employeer/Screens/project_detail_screen.dart';
import 'package:templink/Employee/Screens/Employee_Job_Detail_Screen.dart';
import 'package:templink/Employeer/Screens/talent_profile.dart';
import 'package:templink/Employeer/model/talent_model.dart';
import 'package:templink/Utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchingController searchController = Get.put(SearchingController());
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchTextController.addListener(_onSearchChanged);
    _focusNode.requestFocus();
  }

  void _onSearchChanged() {
    searchController.onSearchChanged(_searchTextController.text);
  }

  @override
  void dispose() {
    _searchTextController.removeListener(_onSearchChanged);
    _searchTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (searchController.searchQuery.value.isEmpty) {
                return _buildEmptyState();
              }
              
              if (searchController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (searchController.errorMessage.value.isNotEmpty) {
                return _buildErrorState();
              }

              return Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: _buildResultsList(),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.search, color: Colors.grey, size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchTextController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search projects, jobs, talents...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_searchTextController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchTextController.clear();
                        searchController.clearSearch();
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: searchController.tabs.length,
        itemBuilder: (context, index) {
          final tab = searchController.tabs[index];
          final isSelected = searchController.selectedTab.value == tab['id'];
          
          return GestureDetector(
            onTap: () {
              searchController.selectedTab.value = tab["id"] as String;
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primary : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    tab['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tab['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsList() {
    final results = searchController.currentResults;
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return _buildResultCard(item);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    final type = item['type'] ?? 'unknown';
    final icon = searchController.getResultIcon(type);
    final color = searchController.getResultColor(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? item['name'] ?? 'Untitled',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    if (type == 'project') ...[
                      Text(
                        '${item['companyName'] ?? 'Company'} • ${item['budget'] ?? 'Budget N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (item['skills'] != null && (item['skills'] as List).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 4,
                            children: (item['skills'] as List).take(3).map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  skill.toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ] else if (type == 'job') ...[
                      Text(
                        '${item['company'] ?? 'Company'} • ${item['workplace'] ?? 'Workplace'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (item['urgency'] == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ),
                    ] else if (type == 'talent') ...[
                      Text(
                        item['title'] ?? 'Professional',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            (item['rating'] ?? 0).toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['hourlyRate'] ?? '',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                    
                    if (item['description'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item['description'].toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Search Projects, Jobs & Talents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find the perfect project, job, or talent',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: [
              _buildSuggestionChip('Flutter Developer'),
              _buildSuggestionChip('UI Designer'),
              _buildSuggestionChip('React'),
              _buildSuggestionChip('Remote'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchController.errorMessage.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              searchController.searchAll(_searchTextController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _searchTextController.text = text;
        searchController.searchAll(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  // ✅ FIXED: Using import aliases to avoid EmployerSnapshot conflict
  void _navigateToDetail(Map<String, dynamic> item) {
    final type = item['type'];
    final id = item['id']?.toString() ?? '';
    
    switch(type) {
      case 'project':
        // ✅ Using project_model alias
        final project = project_model.ProjectFeedModel(
          id: id,
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          category: item['category'] ?? 'Other',
          duration: item['duration'] ?? '3-6 months',
          experienceLevel: item['experienceLevel'] ?? 'Intermediate',
          budgetType: item['budgetType'] ?? 'FIXED',
          minBudget: (item['minBudget'] ?? 0).toInt(),
          maxBudget: (item['maxBudget'] ?? 0).toInt(),
          skills: List<String>.from(item['skills'] ?? []),
          deliverables: List<String>.from(item['deliverables'] ?? []),
          media: [],
          milestones: [],
          featured: item['featured'] ?? false,
          createdAt: item['createdAt'] != null ? DateTime.tryParse(item['createdAt'].toString()) : null,
          updatedAt: item['updatedAt'] != null ? DateTime.tryParse(item['updatedAt'].toString()) : null,
          topLevelProposalsCount: item['proposalsCount'],
          employerSnapshot: project_model.EmployerSnapshot( // ✅ Using project's EmployerSnapshot
            userId: item['employerId'] ?? '',
            firstName: item['employerFirstName'] ?? '',
            lastName: item['employerLastName'] ?? '',
            email: item['employerEmail'] ?? '',
            country: item['employerCountry'] ?? '',
            companyName: item['companyName'] ?? '',
            logoUrl: item['logoUrl'] ?? '',
            industry: item['industry'] ?? '',
            city: item['city'] ?? '',
            employerCountry: item['employerCountry'] ?? '',
            companySize: item['companySize'] ?? '',
            workModel: item['workModel'] ?? '',
            proposalsCount: item['proposalsCount'] ?? 0,
            interviewingCount: item['interviewingCount'] ?? 0,
            invitesCount: item['invitesCount'] ?? 0,
            status: item['projectStatus'] ?? 'OPEN',
            phone: item['phone'] ?? '',
            companyEmail: item['companyEmail'] ?? '',
            website: item['website'] ?? '',
            linkedin: item['linkedin'] ?? '',
            about: item['about'] ?? '',
            mission: item['mission'] ?? '',
            cultureTags: List<String>.from(item['cultureTags'] ?? []),
            teamMembers: item['teamMembers'] as List? ?? [],
            isVerifiedEmployer: item['isVerifiedEmployer'] ?? false,
            rating: (item['rating'] ?? 0).toDouble(),
            sizeLabel: item['sizeLabel'] ?? '',
          ),
        );
        print('✅ Navigating to ProjectDetailScreen with project: ${project.title}');
        Get.to(() => ProjectDetailScreen(project: project));
        break;
        
      case 'job':
        // ✅ Using job_model alias
        final job = job_model.JobPostModel(
          id: id,
          title: item['title'] ?? '',
          company: item['company'] ?? '',
          workplace: item['workplace'] ?? 'Remote',
          location: item['location'] ?? '',
          type: item['type'] ?? 'Full Time',
          about: item['description'] ?? '',
          requirements: item['requirements'] ?? '',
          qualifications: item['qualifications'] ?? '',
          images: List<String>.from(item['images'] ?? []),
          postedDate: item['postedDate'] != null 
              ? DateTime.tryParse(item['postedDate'].toString()) 
              : DateTime.now(),
          urgency: item['urgency'] ?? false,
          employerSnapshot: job_model.EmployerSnapshot( // ✅ Using job's EmployerSnapshot
            userId: item['employerId'] ?? '',
            firstName: item['employerFirstName'] ?? '',
            lastName: item['employerLastName'] ?? '',
            email: item['employerEmail'] ?? '',
            country: item['employerCountry'] ?? '',
            companyName: item['companyName'] ?? item['company'] ?? '',
            logoUrl: item['logoUrl'] ?? '',
            industry: item['industry'] ?? '',
            city: item['city'] ?? '',
            employerCountry: item['employerCountry'] ?? '',
            companySize: item['companySize'] ?? '',
            workModel: item['workModel'] ?? '',
           
            phone: item['phone'] ?? '',
            companyEmail: item['companyEmail'] ?? '',
            website: item['website'] ?? '',
            linkedin: item['linkedin'] ?? '',
            about: item['about'] ?? '',
            mission: item['mission'] ?? '',
            cultureTags: List<String>.from(item['cultureTags'] ?? []),
            teamMembers: item['teamMembers'] as List? ?? [],
            isVerifiedEmployer: item['isVerifiedEmployer'] ?? false,
            rating: (item['rating'] ?? 0).toDouble(),
            sizeLabel: item['sizeLabel'] ?? '',
          ),
        );
        print('✅ Navigating to JobDetailScreen with job: ${job.title}');
        Get.to(() => JobDetailScreen(job: job));
        break;
        
      case 'talent':
        // ✅ COMPLETE TALENT MODEL
        final nameParts = (item['name'] ?? '').toString().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        final talent = TalentModel(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: item['email'] ?? '',
          country: item['country'] ?? '',
          employeeProfile: {
            'title': item['title'] ?? 'Professional',
            'skills': item['skills'] ?? [],
            'hourlyRate': (item['hourlyRate'] ?? '').toString().replaceAll('\$', '').replaceAll('/hr', ''),
            'rating': item['rating'] ?? 0.0,
            'photoUrl': item['photoUrl'] ?? '',
            'bio': item['bio'] ?? '',
            'experienceLevel': item['experienceLevel'] ?? '',
            'category': item['category'] ?? '',
            'availability': item['availability'] ?? '',
            'completedProjects': item['completedProjects'] ?? 0,
            'portfolioProjects': item['portfolioProjects'] ?? [],
            'workExperiences': item['workExperiences'] ?? [],
            'educations': item['educations'] ?? [],
          },
        );
        print('✅ Navigating to TalentProfileScreen with talent: ${talent.fullName}');
        Get.to(() => TalentProfileScreen(talent: talent));
        break;
    }
  }
}