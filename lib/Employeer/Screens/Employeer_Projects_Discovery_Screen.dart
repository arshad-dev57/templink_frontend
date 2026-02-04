import 'package:flutter/material.dart';
import 'package:templink/Utils/colors.dart';


// For demo purposes, defining primary color here

class ProjectsDiscoveryScreen extends StatefulWidget {
  const ProjectsDiscoveryScreen({super.key});

  @override
  State<ProjectsDiscoveryScreen> createState() =>
      _ProjectsDiscoveryScreenState();
}

class _ProjectsDiscoveryScreenState extends State<ProjectsDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All Projects';
  String _searchQuery = '';

  final List<String> _categories = [
    'All Projects',
    'Web Development',
    'Mobile Apps',
    'UI/UX Design',
    'AI/ML',
    'Marketing',
    'Writing',
  ];

  // Sample data - replace with your actual data source
  final List<Map<String, dynamic>> _allProjects = [
    {
      "title": "FinTech App Redesign",
      "subtitle": "UI Design • UI Engineering Project",
      "category": "UI/UX Design",
      "tags": ["Figma", "React Native", "UI/UX"],
      "budget": "\$8,000 - \$12,000",
      "budgetTime": "1-3 months • Intermediate",
      "badges": ["FEATURED", "URGENT"],
      "badgeColors": [Colors.red, Colors.orange],
      "image":
          "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=400",
      "verified": true,
      "bookmark": true,
    },
    {
      "title": "AI Content Dashboard",
      "subtitle": "Wix • Dashboard/Admin Panel",
      "category": "AI/ML",
      "tags": ["React.js", "TensorFlow", "OpenAI API"],
      "budget": "\$45 - \$75/hr",
      "budgetTime": "Less than 30 hrs/week",
      "badges": ["FEATURED"],
      "badgeColors": [const Color(0xFF00BCD4)],
      "image":
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400",
      "verified": false,
      "bookmark": true,
    },
    {
      "title": "E-Commerce Platform",
      "subtitle": "Full Stack Development • Web Application",
      "category": "Web Development",
      "tags": ["React", "Node.js", "MongoDB", "Stripe"],
      "budget": "\$15,000 - \$25,000",
      "budgetTime": "3-6 months • Expert",
      "badges": ["FEATURED"],
      "badgeColors": [Colors.purple],
      "image":
          "https://images.unsplash.com/photo-1557821552-17105176677c?w=400",
      "verified": true,
      "bookmark": false,
    },
    {
      "title": "iOS Fitness Tracking App",
      "subtitle": "Mobile Development • Health & Fitness",
      "category": "Mobile Apps",
      "tags": ["Swift", "HealthKit", "Firebase"],
      "budget": "\$60 - \$90/hr",
      "budgetTime": "2-4 months • Intermediate",
      "badges": ["NEW"],
      "badgeColors": [Colors.green],
      "image":
          "https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400",
      "verified": true,
      "bookmark": true,
    },
    {
      "title": "Brand Identity Design",
      "subtitle": "Graphic Design • Branding Project",
      "category": "UI/UX Design",
      "tags": ["Adobe Illustrator", "Branding", "Logo Design"],
      "budget": "\$3,000 - \$5,000",
      "budgetTime": "1 month • Entry Level",
      "badges": ["URGENT"],
      "badgeColors": [Colors.orange],
      "image":
          "https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400",
      "verified": false,
      "bookmark": false,
    },
    {
      "title": "Social Media Campaign",
      "subtitle": "Digital Marketing • Instagram & TikTok",
      "category": "Marketing",
      "tags": ["Social Media", "Content Strategy", "Analytics"],
      "budget": "\$2,000 - \$4,000",
      "budgetTime": "1-2 months • Intermediate",
      "badges": ["FEATURED", "NEW"],
      "badgeColors": [const Color(0xFF00BCD4), Colors.green],
      "image":
          "https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=400",
      "verified": true,
      "bookmark": true,
    },
    {
      "title": "Technical Blog Writing",
      "subtitle": "Content Writing • Technology Blog",
      "category": "Writing",
      "tags": ["Technical Writing", "SEO", "Research"],
      "budget": "\$30 - \$50/hr",
      "budgetTime": "Ongoing • Expert",
      "badges": [],
      "badgeColors": [],
      "image":
          "https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400",
      "verified": false,
      "bookmark": false,
    },
    {
      "title": "Flutter Mobile Game",
      "subtitle": "Game Development • Cross-platform",
      "category": "Mobile Apps",
      "tags": ["Flutter", "Dart", "Game Design", "Flame"],
      "budget": "\$10,000 - \$18,000",
      "budgetTime": "3-5 months • Intermediate",
      "badges": ["FEATURED"],
      "badgeColors": [Colors.red],
      "image":
          "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=400",
      "verified": true,
      "bookmark": true,
    },
    {
      "title": "Machine Learning Model",
      "subtitle": "AI/ML • Predictive Analytics",
      "category": "AI/ML",
      "tags": ["Python", "TensorFlow", "Data Science"],
      "budget": "\$80 - \$120/hr",
      "budgetTime": "2-3 months • Expert",
      "badges": ["URGENT"],
      "badgeColors": [Colors.orange],
      "image":
          "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=400",
      "verified": true,
      "bookmark": false,
    },
    {
      "title": "WordPress Website Redesign",
      "subtitle": "Web Development • CMS",
      "category": "Web Development",
      "tags": ["WordPress", "PHP", "CSS", "Responsive"],
      "budget": "\$2,500 - \$4,500",
      "budgetTime": "1-2 months • Entry Level",
      "badges": ["NEW"],
      "badgeColors": [Colors.green],
      "image":
          "https://images.unsplash.com/photo-1547658719-da2b51169166?w=400",
      "verified": false,
      "bookmark": false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProjects {
    return _allProjects.where((project) {
      // Filter by category
      bool matchesCategory = _selectedCategory == 'All Projects' ||
          project['category'] == _selectedCategory;

      // Filter by search query
      bool matchesSearch = _searchQuery.isEmpty ||
          project['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          project['subtitle']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (project['tags'] as List).any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Find Projects',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search projects by title, tags, or description...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Category Filter Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      elevation: 0,
                      pressElevation: 0,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? primary : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Divider
          Container(
            color: Colors.grey[200],
            height: 1,
          ),

          // Results Count & Sort
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProjects.length} ${_filteredProjects.length == 1 ? 'Project' : 'Projects'} Available',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.sort, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down,
                        size: 20, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(
            color: Colors.grey[200],
            height: 1,
          ),

          // Projects List
          Expanded(
            child: _filteredProjects.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProjects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final project = _filteredProjects[index];
                      return _projectCard(project);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No projects found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or category filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _projectCard(Map<String, dynamic> project) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  project["image"],
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 140,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              if ((project["badges"] as List).isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: [
                      for (int i = 0;
                          i < (project["badges"] as List).length;
                          i++)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (project["badgeColors"] as List)[i],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (project["badges"] as List)[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      project["bookmark"] = !(project["bookmark"] as bool);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      project["bookmark"] == true
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: project["bookmark"] == true
                          ? primary
                          : Colors.black87,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project["title"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project["subtitle"],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (project["verified"] == true) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 14,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project["budget"],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project["budgetTime"],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (project["tags"] as List<String>)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to project details
                      // Get.to(() => ProjectDetailsScreen(project: project));
                      print('View details: ${project["title"]}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}