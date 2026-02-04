import 'package:flutter/material.dart';

import 'package:templink/Utils/colors.dart';

class TalentDiscoveryScreen extends StatefulWidget {
  const TalentDiscoveryScreen({super.key});

  @override
  State<TalentDiscoveryScreen> createState() => _TalentDiscoveryScreenState();
}

class _TalentDiscoveryScreenState extends State<TalentDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Developers',
    'Designers',
    'Marketing',
    'Writers',
    'Video',
  ];

  // Sample data - replace with your actual data source
  final List<Map<String, dynamic>> _allTalents = [
    {
      "name": "Alex Rivera",
      "role": "FULL STACK DEVELOPER",
      "category": "Developers",
      "tags": ["React", "Node.js", "UI Architecture"],
      "rate": "\$85/hr",
      "rating": "5.0",
      "image": "https://randomuser.me/api/portraits/men/32.jpg",
      "bgColor": const Color(0xFFFFD6A5),
      "badge": "AVAILABLE NOW",
      "projectimage":
          "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
    },
    {
      "name": "Elena Chen",
      "role": "SENIOR PRODUCT DESIGNER",
      "category": "Designers",
      "tags": ["Figma", "Design Systems", "Prototyping"],
      "rate": "\$110/hr",
      "rating": "5.0",
      "image": "https://randomuser.me/api/portraits/women/44.jpg",
      "bgColor": const Color(0xFFE5B299),
      "badge": null,
      "projectimage":
          "https://images.unsplash.com/photo-1498050108023-c5249f4df085?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
    },
    {
      "name": "Marcus Johnson",
      "role": "MOBILE APP DEVELOPER",
      "category": "Developers",
      "tags": ["Flutter", "iOS", "Android"],
      "rate": "\$95/hr",
      "rating": "4.9",
      "image": "https://randomuser.me/api/portraits/men/52.jpg",
      "bgColor": const Color(0xFFB5D5FF),
      "badge": "AVAILABLE NOW",
      "projectimage":
          "https://images.unsplash.com/photo-1551650975-87deedd944c3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
    },
    {
      "name": "Sarah Martinez",
      "role": "UI/UX DESIGNER",
      "category": "Designers",
      "tags": ["Adobe XD", "User Research", "Wireframing"],
      "rate": "\$90/hr",
      "rating": "5.0",
      "image": "https://randomuser.me/api/portraits/women/65.jpg",
      "bgColor": const Color(0xFFFFC4E1),
      "badge": null,
      "projectimage":
          "https://images.unsplash.com/photo-1561070791-2526d30994b5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
    },
    {
      "name": "David Kim",
      "role": "CONTENT WRITER",
      "category": "Writers",
      "tags": ["SEO", "Copywriting", "Technical Writing"],
      "rate": "\$60/hr",
      "rating": "4.8",
      "image": "https://randomuser.me/api/portraits/men/75.jpg",
      "bgColor": const Color(0xFFD4E7C5),
      "badge": "AVAILABLE NOW",
      "projectimage":
          "https://images.unsplash.com/photo-1455390582262-044cdead277a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
    },
    {
      "name": "Jessica Wong",
      "role": "DIGITAL MARKETING SPECIALIST",
      "category": "Marketing",
      "tags": ["Social Media", "Google Ads", "Analytics"],
      "rate": "\$75/hr",
      "rating": "4.9",
      "image": "https://randomuser.me/api/portraits/women/28.jpg",
      "bgColor": const Color(0xFFFFE4B5),
      "badge": null,
      "projectimage":
          "https://images.unsplash.com/photo-1460925895917-afdab827c52f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
    },
    {
      "name": "Michael Brown",
      "role": "VIDEO EDITOR",
      "category": "Video",
      "tags": ["Adobe Premiere", "After Effects", "Color Grading"],
      "rate": "\$70/hr",
      "rating": "5.0",
      "image": "https://randomuser.me/api/portraits/men/15.jpg",
      "bgColor": const Color(0xFFCCB7AE),
      "badge": "AVAILABLE NOW",
      "projectimage":
          "https://images.unsplash.com/photo-1492619375914-88005aa9e8fb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
    },
    {
      "name": "Lisa Anderson",
      "role": "BACKEND DEVELOPER",
      "category": "Developers",
      "tags": ["Python", "Django", "PostgreSQL"],
      "rate": "\$100/hr",
      "rating": "4.9",
      "image": "https://randomuser.me/api/portraits/women/90.jpg",
      "bgColor": const Color(0xFFE6E6FA),
      "badge": null,
      "projectimage":
          "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTalents {
    return _allTalents.where((talent) {
      // Filter by category
      bool matchesCategory = _selectedCategory == 'All' ||
          talent['category'] == _selectedCategory;

      // Filter by search query
      bool matchesSearch = _searchQuery.isEmpty ||
          talent['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          talent['role']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (talent['tags'] as List)
              .any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

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
          'Find Talent',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                hintText: 'Search by name, role, or skills...',
                hintStyle: TextStyle(color: Colors.grey[400]),
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

          // Results Count
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredTalents.length} ${_filteredTalents.length == 1 ? 'Talent' : 'Talents'} Found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.tune, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Talents List
          Expanded(
            child: _filteredTalents.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTalents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final talent = _filteredTalents[index];
                      return _talentCard(talent);
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
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No talents found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _talentCard(Map<String, dynamic> talent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: talent["bgColor"],
                  child: Stack(
                    children: [
                      Image.network(
                        talent["projectimage"],
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: talent["bgColor"],
                            child: const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(talent["image"]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (talent["badge"] != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      talent["badge"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        talent["rating"],
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            talent["role"],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            talent["name"],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (talent["tags"] as List<String>)
                .map((tag) => Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "HOURLY RATE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    talent["rate"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                 
                  print('View profile: ${talent["name"]}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "View Profile",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}