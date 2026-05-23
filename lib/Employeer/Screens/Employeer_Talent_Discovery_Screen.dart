// lib/Employer/Screens/talent_discovery_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/Employee_home_controller.dart';
import 'package:templink/Employeer/Screens/Employeer_homescreen.dart';
import 'package:templink/Employeer/Screens/talent_profile.dart';
import 'package:templink/Employeer/model/talent_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TalentDiscoveryScreen extends StatefulWidget {
  final bool showSidebar;

  const TalentDiscoveryScreen({super.key, this.showSidebar = false});

  @override
  State<TalentDiscoveryScreen> createState() => _TalentDiscoveryScreenState();
}

class _TalentDiscoveryScreenState extends State<TalentDiscoveryScreen> {
  final EmployeeHomeController homeController =
      Get.find<EmployeeHomeController>();
  final navController = Get.find<EmployerNavigationController>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categorySearchController = TextEditingController();
  final TextEditingController _countrySearchController = TextEditingController();

  String _selectedCategory = 'All Categories';
  String _selectedCountry = 'All Countries';
  String _searchQuery = '';
  String _sortBy = 'Recommended';
  bool _isGridView = true;
  bool _showCategoryDropdown = false;
  bool _showCountryDropdown = false;
  String _tempCategory = '';
  String _tempCountry = '';

  // Categories list (exactly as you specified)
  final List<String> _allCategories = [
    'All Categories',
    'IT & Networking',
    'Design & Creative',
    'Writing & Translation',
    'Digital Marketing',
    'Business & Finance',
    'Engineering & Architecture',
    'Healthcare & Medical',
    'Education & Training',
    'Legal & Compliance',
    'Human Resources',
    'Project Management',
    'Sales & Business Development',
    'Science & Research',
    'Finance & Investment',
  ];

  // Countries list (fetched from API)
  List<CountryModel> _countries = [];
  List<CountryModel> _filteredCountries = [];
  bool _isLoadingCountries = false;

  List<String> get _filteredCategories {
    if (_tempCategory.isEmpty) return _allCategories;
    return _allCategories
        .where((category) => category.toLowerCase().contains(_tempCategory.toLowerCase()))
        .toList();
  }

  List<CountryModel> get _filteredCountriesList {
    if (_tempCountry.isEmpty) return _countries;
    return _countries
        .where((country) => country.name.toLowerCase().contains(_tempCountry.toLowerCase()))
        .toList();
  }

  final List<String> _sortOptions = [
    'Recommended',
    'Rating: High to Low',
    'Hourly Rate: Low to High',
    'Hourly Rate: High to Low'
  ];

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTalents();
    _fetchCountries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categorySearchController.dispose();
    _countrySearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name,cca2'),
        headers: {'User-Agent': 'Mozilla/5.0'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<CountryModel> countries = [];
        
        for (var item in data) {
          String name = item['name']['common'] ?? 'Unknown';
          String code = item['cca2']?.toString().toLowerCase() ?? '';
          String flagUrl = code.isNotEmpty 
              ? 'https://flagcdn.com/w40/$code.png' 
              : '';
          
          countries.add(CountryModel(
            name: name,
            code: code,
            flagUrl: flagUrl,
          ));
        }
        
        countries.sort((a, b) => a.name.compareTo(b.name));
        
        // Add "All Countries" at the beginning
        countries.insert(0, CountryModel(name: 'All Countries', code: '', flagUrl: ''));
        
        setState(() {
          _countries = countries;
          _filteredCountries = countries;
          _isLoadingCountries = false;
        });
      } else {
        _useFallbackCountries();
      }
    } catch (e) {
      print('Error fetching countries: $e');
      _useFallbackCountries();
    }
  }

  void _useFallbackCountries() {
    setState(() {
      _countries = [
        CountryModel(name: 'All Countries', code: '', flagUrl: ''),
        CountryModel(name: 'United States', code: 'us', flagUrl: 'https://flagcdn.com/w40/us.png'),
        CountryModel(name: 'United Kingdom', code: 'gb', flagUrl: 'https://flagcdn.com/w40/gb.png'),
        CountryModel(name: 'Canada', code: 'ca', flagUrl: 'https://flagcdn.com/w40/ca.png'),
        CountryModel(name: 'Australia', code: 'au', flagUrl: 'https://flagcdn.com/w40/au.png'),
        CountryModel(name: 'India', code: 'in', flagUrl: 'https://flagcdn.com/w40/in.png'),
        CountryModel(name: 'Pakistan', code: 'pk', flagUrl: 'https://flagcdn.com/w40/pk.png'),
        CountryModel(name: 'Bangladesh', code: 'bd', flagUrl: 'https://flagcdn.com/w40/bd.png'),
        CountryModel(name: 'Germany', code: 'de', flagUrl: 'https://flagcdn.com/w40/de.png'),
        CountryModel(name: 'France', code: 'fr', flagUrl: 'https://flagcdn.com/w40/fr.png'),
      ];
      _filteredCountries = _countries;
      _isLoadingCountries = false;
    });
  }

  void _onScroll() {
    if (!_isLoadingMore &&
        _currentPage < _totalPages &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTalents();
    }
  }

  Future<void> _loadTalents({int page = 1, bool reset = true}) async {
    try {
      if (reset) {
        if (mounted) {
          setState(() {
            _currentPage = 1;
            _isLoadingMore = false;
          });
        }
      }

      await homeController.fetchTalentsPaginated(
          page: page, limit: 6, resetList: reset);

      if (mounted) {
        setState(() {
          _currentPage = homeController.talentsCurrentPage.value;
          _totalPages = homeController.talentsTotalPages.value;
          _totalItems = homeController.talentsTotalCount.value;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print("Error loading talents: $e");
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _loadMoreTalents() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    if (mounted) {
      setState(() => _isLoadingMore = true);
    }
    await _loadTalents(page: _currentPage + 1, reset: false);
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      _loadTalents(page: page, reset: true);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  List<TalentModel> get _filteredTalents {
    if (homeController.talents.isEmpty) return [];

    List<TalentModel> filtered = List.from(homeController.talents);

    // Filter by category
    if (_selectedCategory != 'All Categories') {
      filtered = filtered.where((talent) {
        return talent.category == _selectedCategory;
      }).toList();
    }

    // Filter by country
    if (_selectedCountry != 'All Countries') {
      filtered = filtered.where((talent) {
        return talent.country == _selectedCountry;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((talent) {
        return talent.fullName.toLowerCase().contains(query) ||
            talent.title.toLowerCase().contains(query) ||
            talent.skills.any((skill) => skill.toLowerCase().contains(query));
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Rating: High to Low':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Hourly Rate: Low to High':
        filtered.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
        break;
      case 'Hourly Rate: High to Low':
        filtered.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
        break;
      default:
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isWeb =
        Responsive.isDesktop(context) || Responsive.isTablet(context);

    if (isWeb) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  // ==================== WEB LAYOUT ====================
  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildWebTopBar(),
          Expanded(
            child: Obx(() {
              if (homeController.isLoadingTalents.value &&
                  homeController.talents.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (homeController.talentsError.value != null) {
                return _buildErrorWidget();
              }

              final talents = _filteredTalents;

              if (talents.isEmpty && !homeController.isLoadingTalents.value) {
                return _buildEmptyState();
              }

              return Column(
                children: [
                  _buildStatsBar(talents),
                  const Divider(height: 1),
                  Expanded(
                    child: _isGridView
                        ? _buildTalentGrid(talents)
                        : _buildTalentTable(talents),
                  ),
                  if (_totalPages > 1) _buildPagination(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==================== WEB TOP BAR (WITH SEARCHABLE DROPDOWNS) ====================
  Widget _buildWebTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Talent',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search bar
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
                child: SizedBox(
                  height: 42,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search by name, role, or skills...',
                        hintStyle: TextStyle(
                            fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search,
                            size: 18, color: Colors.grey.shade500),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close,
                                    size: 16, color: Colors.grey.shade500),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ),
              ),

              // Searchable Category Dropdown Button
              _buildSearchableCategoryButton(),

              // Searchable Country Dropdown Button
              _buildSearchableCountryButton(),

              // Sort dropdown
              _buildDropdown<String>(
                value: _sortBy,
                items: _sortOptions,
                onChanged: (value) => setState(() => _sortBy = value!),
                itemBuilder: (opt) => DropdownMenuItem(
                  value: opt,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(opt, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),

              // View toggle buttons
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggleButton(Icons.grid_view, true),
                    _buildViewToggleButton(Icons.table_rows, false),
                  ],
                ),
              ),
            ],
          ),
          // Selected filters row
          if (_selectedCategory != 'All Categories' || _selectedCountry != 'All Countries')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedCategory != 'All Categories')
                    _buildFilterChip(_selectedCategory, () {
                      setState(() => _selectedCategory = 'All Categories');
                    }),
                  if (_selectedCountry != 'All Countries')
                    _buildFilterChip(_selectedCountry, () {
                      setState(() => _selectedCountry = 'All Countries');
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: primary)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 14, color: primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchableCategoryButton() {
    return GestureDetector(
      onTap: () => _showCategoryDialog(),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category, size: 16, color: primary),
            const SizedBox(width: 8),
            Text(
              _selectedCategory.length > 20
                  ? '${_selectedCategory.substring(0, 18)}...'
                  : _selectedCategory,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableCountryButton() {
    return GestureDetector(
      onTap: () => _showCountryDialog(),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedCountry != 'All Countries')
              _buildCountryFlag(_selectedCountry, size: 18)
            else
              Icon(Icons.public, size: 16, color: primary),
            const SizedBox(width: 8),
            Text(
              _selectedCountry.length > 20
                  ? '${_selectedCountry.substring(0, 18)}...'
                  : _selectedCountry,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: primary, size: 20),
          ],
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
                      const Text(
                        'Select Category',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _categorySearchController,
                      autofocus: true,
                      onChanged: (value) {
                        setStateDialog(() {
                          _tempCategory = value;
                        });
                        setState(() {
                          _tempCategory = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search category...',
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
                                    _tempCategory = '';
                                    _categorySearchController.clear();
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
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

  void _showCountryDialog() {
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
                      const Text(
                        'Select Country',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _countrySearchController,
                      autofocus: true,
                      onChanged: (value) {
                        setStateDialog(() {
                          _tempCountry = value;
                        });
                        setState(() {
                          _tempCountry = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search country...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                        suffixIcon: _tempCountry.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[500], size: 20),
                                onPressed: () {
                                  _countrySearchController.clear();
                                  setStateDialog(() => _tempCountry = '');
                                  setState(() => _tempCountry = '');
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
                    child: _isLoadingCountries
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredCountriesList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.public_off, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text('No countries found', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredCountriesList.length,
                                itemBuilder: (context, index) {
                                  final country = _filteredCountriesList[index];
                                  final isSelected = _selectedCountry == country.name;
                                  return ListTile(
                                    leading: country.code.isNotEmpty
                                        ? Image.network(country.flagUrl, width: 30, height: 20, errorBuilder: (c, e, s) => Icon(Icons.flag, size: 20))
                                        : Icon(Icons.public, size: 20, color: Colors.grey[400]),
                                    title: Text(
                                      country.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: isSelected ? primary : Colors.black87,
                                      ),
                                    ),
                                    trailing: isSelected ? Icon(Icons.check_circle, color: primary, size: 20) : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedCountry = country.name;
                                        _tempCountry = '';
                                        _countrySearchController.clear();
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                },
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

  Widget _buildCountryFlag(String countryName, {double size = 24}) {
    final country = _countries.firstWhere(
      (c) => c.name == countryName,
      orElse: () => CountryModel(name: '', code: '', flagUrl: ''),
    );
    
    if (country.flagUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            countryName.isNotEmpty ? countryName[0].toUpperCase() : '?',
            style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    
    return Image.network(
      country.flagUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            countryName.isNotEmpty ? countryName[0].toUpperCase() : '?',
            style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required DropdownMenuItem<T> Function(T) itemBuilder,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: Icon(Icons.arrow_drop_down, color: primary, size: 20),
          style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500),
          onChanged: onChanged,
          items: items.map(itemBuilder).toList(),
        ),
      ),
    );
  }

  Widget _buildViewToggleButton(IconData icon, bool isGrid) {
    final isSelected = _isGridView == isGrid;
    return GestureDetector(
      onTap: () => setState(() => _isGridView = isGrid),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 18,
            color: isSelected ? Colors.white : Colors.grey.shade600),
      ),
    );
  }

  Widget _buildStatsBar(List<TalentModel> talents) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_totalItems ${_totalItems == 1 ? 'Talent' : 'Talents'} total',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 14, color: primary),
                const SizedBox(width: 6),
                Text(
                  '${talents.length} shown',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PAGINATION ====================
  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap:
                _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color:
                    _currentPage > 1 ? primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chevron_left,
                  size: 20,
                  color: _currentPage > 1
                      ? Colors.white
                      : Colors.grey.shade500),
            ),
          ),
          ..._buildPageNumbersSafe(),
          GestureDetector(
            onTap: _currentPage < _totalPages
                ? () => _goToPage(_currentPage + 1)
                : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: _currentPage < _totalPages
                    ? primary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chevron_right,
                  size: 20,
                  color: _currentPage < _totalPages
                      ? Colors.white
                      : Colors.grey.shade500),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Page $_currentPage of $_totalPages',
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbersSafe() {
    List<Widget> buttons = [];

    if (_totalPages <= 7) {
      for (int i = 1; i <= _totalPages; i++) {
        buttons.add(_buildPageButton(i));
      }
      return buttons;
    }

    int startPage = _currentPage - 2;
    if (startPage < 1) startPage = 1;

    int endPage = startPage + 4;
    if (endPage > _totalPages) {
      endPage = _totalPages;
      startPage = endPage - 4;
      if (startPage < 1) startPage = 1;
    }

    if (startPage > 1) {
      buttons.add(_buildPageButton(1));
      if (startPage > 2) {
        buttons.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('...')));
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      buttons.add(_buildPageButton(i));
    }

    if (endPage < _totalPages) {
      if (endPage < _totalPages - 1) {
        buttons.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('...')));
      }
      buttons.add(_buildPageButton(_totalPages));
    }

    return buttons;
  }

  Widget _buildPageButton(int page) {
    final isSelected = page == _currentPage;
    return GestureDetector(
      onTap: () => _goToPage(page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ==================== TALENT GRID ====================
  Widget _buildTalentGrid(List<TalentModel> talents) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double minCardWidth = 280.0;
        const double cardSpacing = 20.0;
        const double padding = 24.0;

        final availableWidth = constraints.maxWidth - (padding * 2);
        int columns =
            (availableWidth / (minCardWidth + cardSpacing)).floor();
        if (columns < 1) columns = 1;
        if (columns > 4) columns = 4;

        final cardWidth =
            (availableWidth - (cardSpacing * (columns - 1))) / columns;

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(padding),
          child: Wrap(
            spacing: cardSpacing,
            runSpacing: cardSpacing,
            children: talents
                .map((talent) =>
                    _buildModernTalentCard(talent, width: cardWidth))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildModernTalentCard(TalentModel talent,
      {double width = 340}) {
    final displaySkills = talent.displaySkills.take(4).toList();

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          talent.bgColor,
                          talent.bgColor.withOpacity(0.7)
                        ],
                      ),
                    ),
                    child: talent.firstProjectImage.isNotEmpty
                        ? Image.network(
                            talent.firstProjectImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                    child: Icon(Icons.work_outline,
                                        size: 40,
                                        color:
                                            Colors.white.withOpacity(0.3))),
                          )
                        : Center(
                            child: Icon(Icons.work_outline,
                                size: 40,
                                color: Colors.white.withOpacity(0.3))),
                  ),
                ),
                Positioned(
                  bottom: -28,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8)
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: talent.bgColor,
                      backgroundImage: talent.photoUrl.isNotEmpty
                          ? NetworkImage(talent.photoUrl)
                          : null,
                      child: talent.photoUrl.isEmpty
                          ? Text(
                              talent.fullName.isNotEmpty
                                  ? talent.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                ),
                if (talent.availabilityBadge.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: talent.availabilityBadgeColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4)
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fiber_manual_record,
                              size: 7, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(talent.availabilityBadge,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(talent.fullName,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 3),
                  Text(talent.title,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 13, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                                talent.ratingDisplay.isEmpty
                                    ? '5.0'
                                    : talent.ratingDisplay,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                            '${talent.completedProjects} Projects',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hourly Rate',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                        Text(
                          talent.hourlyRateDisplay.isEmpty
                              ? 'Rate not set'
                              : talent.hourlyRateDisplay,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: displaySkills
                        .map((skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(8)),
                              child: Text(skill,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700)),
                            ))
                        .toList(),
                  ),
                  if (talent.skills.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                          '+${talent.skills.length - 4} more skills',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                    ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          navController.goToTalentProfile(talent),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('View Profile',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TALENT TABLE ====================
  Widget _buildTalentTable(List<TalentModel> talents) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10)
            ],
          ),
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF8FAFC)),
            dataRowMaxHeight: 70,
            columns: const [
              DataColumn(
                  label: Text('Talent',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(
                  label: Text('Role',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(
                  label: Text('Rating',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(
                  label: Text('Hourly Rate',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(
                  label: Text('Projects',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(
                  label: Text('Availability',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(
                  label: Text('Skills',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(
                  label: Text('',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13))),
            ],
            rows: talents
                .map((talent) => _buildTalentTableRow(talent))
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildTalentTableRow(TalentModel talent) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: talent.bgColor,
                backgroundImage: talent.photoUrl.isNotEmpty
                    ? NetworkImage(talent.photoUrl)
                    : null,
                child: talent.photoUrl.isEmpty
                    ? Text(
                        talent.fullName.isNotEmpty
                            ? talent.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))
                    : null,
              ),
              const SizedBox(width: 10),
              Text(talent.fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        DataCell(Text(talent.title,
            style: const TextStyle(fontSize: 12))),
        DataCell(
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                  talent.ratingDisplay.isEmpty
                      ? '5.0'
                      : talent.ratingDisplay,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        DataCell(
          Text(
            talent.hourlyRateDisplay.isEmpty
                ? 'Not set'
                : talent.hourlyRateDisplay,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primary),
          ),
        ),
        DataCell(Text('${talent.completedProjects}',
            style: const TextStyle(fontSize: 12))),
        DataCell(
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: talent.availabilityBadgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text(
              talent.availabilityBadge.isEmpty
                  ? 'Available'
                  : talent.availabilityBadge,
              style: TextStyle(
                  fontSize: 11,
                  color: talent.availabilityBadgeColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 180,
            child: Wrap(
              spacing: 5,
              runSpacing: 4,
              children: talent.displaySkills
                  .take(3)
                  .map((skill) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(skill,
                            style: const TextStyle(fontSize: 10)),
                      ))
                  .toList(),
            ),
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: () =>
                navController.goToTalentProfile(talent),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('View',
                style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Find Talent',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        leading: widget.showSidebar
            ? IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => navController.goBack())
            : null,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey[200], height: 1)),
      ),
      body: Obx(() {
        if (homeController.isLoadingTalents.value &&
            homeController.talents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (homeController.talentsError.value != null) {
          return _buildErrorWidget();
        }
        final talents = _filteredTalents;
        if (talents.isEmpty &&
            !homeController.isLoadingTalents.value) {
          return _buildEmptyState();
        }
        return Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Search talents...',
                            prefixIcon: Icon(Icons.search,
                                color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _showCategoryDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.category, size: 18, color: primary),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCategory == 'All Categories' ? 'Category' : _selectedCategory.substring(0, 8),
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                              Icon(Icons.arrow_drop_down, color: primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showCountryDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.public, size: 18, color: primary),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCountry == 'All Countries' ? 'Country' : _selectedCountry.substring(0, 8),
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                              Icon(Icons.arrow_drop_down, color: primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            icon:
                                Icon(Icons.arrow_drop_down, color: primary),
                            onChanged: (value) =>
                                setState(() => _sortBy = value!),
                            items: _sortOptions
                                .map((opt) => DropdownMenuItem(
                                    value: opt, child: Text(opt)))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Text('${talents.length} talents found',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: talents.length,
                itemBuilder: (context, index) =>
                    _buildMobileTalentCard(talents[index]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMobileTalentCard(TalentModel talent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  color: talent.bgColor,
                  child: talent.firstProjectImage.isNotEmpty
                      ? Image.network(talent.firstProjectImage,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container())
                      : Center(
                          child: Icon(Icons.work_outline,
                              size: 36,
                              color: Colors.white.withOpacity(0.5))),
                ),
              ),
              Positioned(
                bottom: -24,
                left: 14,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: talent.photoUrl.isNotEmpty
                        ? NetworkImage(talent.photoUrl)
                        : null,
                    child: talent.photoUrl.isEmpty
                        ? Text(talent.fullName[0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
              ),
              if (talent.availabilityBadge.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: talent.availabilityBadgeColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(talent.availabilityBadge,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(talent.fullName,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(talent.title,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(talent.ratingDisplay.isEmpty
                        ? '5.0'
                        : talent.ratingDisplay),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('${talent.completedProjects} Projects',
                          style: TextStyle(
                              fontSize: 11, color: primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hourly Rate',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                      Text(
                          talent.hourlyRateDisplay.isEmpty
                              ? 'Not set'
                              : talent.hourlyRateDisplay,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: talent.displaySkills
                      .take(3)
                      .map((skill) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius:
                                    BorderRadius.circular(6)),
                            child: Text(skill,
                                style:
                                    const TextStyle(fontSize: 11)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        navController.goToTalentProfile(talent),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('View Profile'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ERROR & EMPTY STATES ====================
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
              homeController.talentsError.value ??
                  'Something went wrong',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadTalents(page: 1, reset: true),
            child: const Text('Retry'),
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
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No talents found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Try adjusting your search or filters',
              style:
                  TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// Country Model
class CountryModel {
  final String name;
  final String code;
  final String flagUrl;
  
  CountryModel({
    required this.name,
    required this.code,
    required this.flagUrl,
  });
}