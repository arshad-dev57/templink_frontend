// screens/employeer_projects_discovery_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/Employee_home_controller.dart';
import 'package:templink/Employee/models/project_model.dart';
import 'package:templink/Employeer/Screens/project_detail_screen.dart';
import 'package:templink/Utils/colors.dart';

class ProjectsDiscoveryScreen extends StatelessWidget {
  final bool showSidebar;
  
  const ProjectsDiscoveryScreen({super.key, this.showSidebar = false});

  @override
  Widget build(BuildContext context) {
    return const _ProjectsDiscoveryContent();
  }
}

class _ProjectsDiscoveryContent extends StatefulWidget {
  const _ProjectsDiscoveryContent();

  @override
  State<_ProjectsDiscoveryContent> createState() => _ProjectsDiscoveryContentState();
}

class _ProjectsDiscoveryContentState extends State<_ProjectsDiscoveryContent> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categorySearchController = TextEditingController();
  final EmployeeHomeController homeController = Get.find<EmployeeHomeController>();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All Projects';
  String _searchQuery = '';
  String _sortBy = 'Latest';
  String _tempCategory = '';
  bool _showCategoryDropdown = false;
  bool _isGridView = true;
  
  final List<String> _allCategories = [
    'All Projects',
    'Web Development',
    'Mobile App Development',
    'Software Development',
    'Desktop Application Development',
    'Game Development',
    'Data Science & Analytics',
    'Machine Learning & AI',
    'DevOps & Cloud Computing',
    'Cybersecurity',
    'Database Administration',
    'IT Support & Helpdesk',
    'Network Administration',
    'System Administration',
    'Blockchain & Crypto',
    'IoT Development',
    'AR/VR Development',
    'Embedded Systems',
    'Salesforce Development',
    'SAP Development',
    'WordPress Development',
    'Shopify Development',
    'E-commerce Development',
    'CMS Development',
    'UI/UX Design',
    'Graphic Design',
    'Logo Design',
    'Brand Identity Design',
    'Motion Graphics',
    'Animation',
    'Video Editing',
    '3D Modeling & Rendering',
    'Architectural Design',
    'Interior Design',
    'Fashion Design',
    'Product Design',
    'Illustration',
    'Photo Editing',
    'Print Design',
    'Nursing',
    'Doctor / Physician',
    'Dentistry',
    'Pharmacy',
    'Medical Lab Technology',
    'Radiology',
    'Physical Therapy',
    'Occupational Therapy',
    'Veterinary',
    'Caregiving',
    'Medical Billing & Coding',
    'Healthcare Administration',
    'Public Health',
    'Nutrition & Dietetics',
    'Psychology',
    'Mental Health Counseling',
    'Digital Marketing',
    'Social Media Marketing',
    'SEO/SEM',
    'Content Marketing',
    'Email Marketing',
    'Affiliate Marketing',
    'Influencer Marketing',
    'Brand Management',
    'Public Relations',
    'Sales Representative',
    'Business Development',
    'Account Management',
    'Teaching (School)',
    'University Professor',
    'Online Tutoring',
    'Corporate Training',
    'Language Instruction',
    'Special Education',
    'Early Childhood Education',
    'Curriculum Development',
    'Instructional Design',
    'Accounting',
    'Bookkeeping',
    'Financial Analysis',
    'Investment Banking',
    'Tax Preparation',
    'Auditing',
    'Payroll Management',
    'Legal Advising',
    'Paralegal',
    'Compliance Officer',
    'Construction Management',
    'Civil Engineering',
    'Architecture',
    'Electrical Work',
    'Plumbing',
    'Carpentry',
    'Welding',
    'Painting',
    'HVAC Technician',
    'General Labor',
    'Truck Driving',
    'Delivery Driver',
    'Logistics Coordinator',
    'Warehouse Management',
    'Supply Chain Management',
    'Chef / Cook',
    'Restaurant Management',
    'Food Service Worker',
    'Bartending',
    'Hotel Management',
    'Housekeeping',
    'Event Planning',
    'Customer Support',
    'Call Center Representative',
    'Receptionist',
    'Virtual Assistant',
    'Chat Support',
    'Administrative Assistant',
    'Data Entry',
    'Office Management',
    'Executive Assistant',
    'Document Controller',
    'Photography',
    'Videography',
    'Content Creation',
    'Voice Acting',
    'Music Production',
    'Journalism',
    'Copy Editing',
    'Translation',
    'Transcription',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Chemical Engineering',
    'Industrial Engineering',
    'Biomedical Engineering',
    'Real Estate Agent',
    'Property Manager',
    'Real Estate Investor',
    'HR Generalist',
    'Recruiter',
    'Talent Acquisition',
    'Training & Development',
    'Content Writing',
    'Copywriting',
    'Technical Writing',
    'Creative Writing',
    'Blog Writing',
    'Script Writing',
    'Fitness Training',
    'Personal Coaching',
    'Beauty & Makeup',
    'Cleaning Services',
    'Security Guard',
    'Pet Care',
    'Child Care',
    'Handyman Services',
    'Appliance Repair',
    'Automotive Repair',
  ];
  
  List<String> get _filteredCategories {
    if (_tempCategory.isEmpty) return _allCategories;
    return _allCategories
        .where((category) => category.toLowerCase().contains(_tempCategory.toLowerCase()))
        .toList();
  }

  final List<String> _sortOptions = ['Latest', 'Budget: Low to High', 'Budget: High to Low', 'Most Popular'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeController.projects.isEmpty) {
        homeController.fetchProjects(page: 1, resetList: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categorySearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<ProjectFeedModel> get _filteredProjects {
    List<ProjectFeedModel> filtered = homeController.projects.where((project) {
      bool matchesCategory = _selectedCategory == 'All Projects' ||
          project.category == _selectedCategory;

      bool matchesSearch = _searchQuery.isEmpty ||
          project.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.skills.any((skill) => skill.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();

    switch (_sortBy) {
      case 'Budget: Low to High':
        filtered.sort((a, b) => a.maxBudget.compareTo(b.maxBudget));
        break;
      case 'Budget: High to Low':
        filtered.sort((a, b) => b.maxBudget.compareTo(a.maxBudget));
        break;
      case 'Most Popular':
        filtered.sort((a, b) => b.proposalsCount.compareTo(a.proposalsCount));
        break;
      default:
        filtered.sort((a, b) {
          final aDate = a.createdAt;
          final bDate = b.createdAt;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: Obx(() {
            if (homeController.isLoadingProjects.value && homeController.projects.isEmpty) {
              return _buildLoadingState();
            }

            final filteredProjects = _filteredProjects;
            
            if (filteredProjects.isEmpty) {
              return _buildEmptyState();
            }
            
            return RefreshIndicator(
              onRefresh: () => homeController.fetchProjects(page: 1, resetList: true),
              color: primary,
              child: _isGridView 
                  ? _buildGridView(filteredProjects)
                  : _buildTableView(filteredProjects),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          
          if (isSmallScreen) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSearchField()),
                    const SizedBox(width: 10),
                    _buildCategoryButton(),
                    const SizedBox(width: 10),
                    _buildSortDropdown(),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatsCounter(),
                    const Spacer(),
                    Text(
                      '${_filteredProjects.length} projects found',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(flex: 3, child: _buildSearchField()),
                const SizedBox(width: 12),
                _buildCategoryButton(),
                const SizedBox(width: 12),
                _buildSortDropdown(),
                const SizedBox(width: 12),
                _buildStatsCounter(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500], size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildCategoryButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCategoryDropdown = true;
          _tempCategory = _selectedCategory == 'All Projects' ? '' : _selectedCategory;
          _categorySearchController.text = _selectedCategory == 'All Projects' ? '' : _selectedCategory;
        });
        _showCategoryDialog();
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category, size: 16, color: primary),
            const SizedBox(width: 6),
            Text(
              _selectedCategory.length > 15 
                  ? '${_selectedCategory.substring(0, 12)}...' 
                  : _selectedCategory,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          icon: Icon(Icons.arrow_drop_down, color: primary, size: 18),
          style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
          onChanged: (value) => setState(() => _sortBy = value!),
          items: _sortOptions.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsCounter() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '${_filteredProjects.length}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary),
        ),
      ),
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _categorySearchController,
                      autofocus: true,
                      onChanged: (value) {
                        setStateDialog(() => _tempCategory = value);
                        setState(() => _tempCategory = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search category...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                        suffixIcon: _tempCategory.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[500], size: 20),
                                onPressed: () {
                                  _categorySearchController.clear();
                                  setStateDialog(() => _tempCategory = '');
                                  setState(() => _tempCategory = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredCategories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.category, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('No categories found', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredCategories.length,
                            itemBuilder: (context, index) {
                              final category = _filteredCategories[index];
                              final isSelected = _selectedCategory == category;
                              return ListTile(
                                leading: Icon(Icons.category, color: isSelected ? primary : Colors.grey[400], size: 20),
                                title: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? primary : Colors.black87,
                                  ),
                                ),
                                trailing: isSelected ? Icon(Icons.check_circle, color: primary, size: 20) : null,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                    _showCategoryDropdown = false;
                                    _tempCategory = '';
                                    _categorySearchController.clear();
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All Projects';
                        _tempCategory = '';
                        _categorySearchController.clear();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Show All Projects'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<ProjectFeedModel> projects) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 800;
        final crossAxisCount = isSmallScreen ? 1 : 3;
        
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isSmallScreen ? 0.85 : 0.9,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) => _buildProjectCard(projects[index]),
        );
      },
    );
  }

  Widget _buildTableView(List<ProjectFeedModel> projects) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 12,
          headingRowColor: MaterialStateProperty.all(primary.withOpacity(0.1)),
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          columns: const [
            DataColumn(label: Text('PROJECT')),
            DataColumn(label: Text('CATEGORY')),
            DataColumn(label: Text('BUDGET')),
            DataColumn(label: Text('PROPOSALS')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('ACTION')),
          ],
          rows: projects.map((project) {
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          project.description.length > 50 ? '${project.description.substring(0, 50)}...' : project.description,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(project.category, style: TextStyle(fontSize: 12, color: primary)),
                  ),
                ),
                DataCell(Text(project.displayBudget, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green))),
                DataCell(Row(children: [Icon(Icons.people_outline, size: 14, color: Colors.grey[500]), const SizedBox(width: 4), Text('${project.proposalsCount}')])),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: project.featured ? Colors.amber.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.featured ? 'Featured' : 'Active',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: project.featured ? Colors.amber[800] : Colors.grey[700]),
                    ),
                  ),
                ),
                DataCell(
                  ElevatedButton(
                    onPressed: () => Get.to(() => ProjectDetailScreen(project: project)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(80, 32),
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primary),
          SizedBox(height: 16),
          Text('Loading projects...', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.work_off_outlined, size: 50, color: primary),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ? 'No matching projects found' : 'No projects available',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ? 'Try adjusting your search or filters' : 'Check back later for new opportunities',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear Search'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                side: BorderSide(color: primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectFeedModel project) {
    final bool hasFeatured = project.featured;
    final displaySkills = project.skills.length > 4 ? project.skills.sublist(0, 4) : project.skills;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => ProjectDetailScreen(project: project)),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    project.imageUrl != null && project.imageUrl!.isNotEmpty
                        ? Image.network(
                            project.imageUrl!,
                            width: double.infinity,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 140,
                              color: primary.withOpacity(0.05),
                              child: Center(child: Icon(Icons.work_outline, size: 50, color: primary.withOpacity(0.3))),
                            ),
                          )
                        : Container(
                            height: 140,
                            color: primary.withOpacity(0.05),
                            child: Center(child: Icon(Icons.work_outline, size: 50, color: primary.withOpacity(0.3))),
                          ),
                    if (hasFeatured)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF0097A7)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 10, color: Colors.white),
                              SizedBox(width: 4),
                              Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]),
                          child: Icon(Icons.bookmark_border, color: Colors.grey[700], size: 16),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: BorderRadius.circular(16)),
                        child: Text(project.displayBudget, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (project.isVerified) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.verified, color: Colors.blue, size: 14),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(project.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: primary)),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.description_outlined, size: 10, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text('${project.proposalsCount} proposals', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                        const SizedBox(width: 6),
                        Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text(project.duration, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      project.description.length > 80 ? '${project.description.substring(0, 80)}...' : project.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: displaySkills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: primary.withOpacity(0.15)),
                          ),
                          child: Text(skill, style: TextStyle(fontSize: 10, color: primary, fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                    ),
                    if (project.skills.length > 4)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('+${project.skills.length - 4} more skills', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => ProjectDetailScreen(project: project)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text("View Details", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}