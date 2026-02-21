import 'package:flutter/material.dart';
// If you already have this, use it:
import 'package:templink/Utils/colors.dart';


class CategoryItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isNew;

  CategoryItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isNew = false,
  });
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _selectedChip = 0;

  final List<String> _chips = const [
    'All',
    'Design',
    'Development',
    'Writing',
    'Marketing',
    'Video',
  ];

  final List<CategoryItem> _allCategories = [
    CategoryItem(
      title: 'Logo Design',
      subtitle: '1,240 services',
      imageUrl:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=400',
      isNew: true,
    ),
    CategoryItem(
      title: 'WordPress',
      subtitle: '980 services',
      imageUrl:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=400',
    ),
    CategoryItem(
      title: 'Articles & Blog Posts',
      subtitle: '1,560 services',
      imageUrl:
          'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400',
    ),
    CategoryItem(
      title: 'Video Editing',
      subtitle: '720 services',
      imageUrl:
          'https://images.unsplash.com/photo-1551817958-d9d86fb29431?w=400',
      isNew: true,
    ),
    CategoryItem(
      title: 'Illustration',
      subtitle: '640 services',
      imageUrl:
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?w=400',
    ),
    CategoryItem(
      title: 'SEO',
      subtitle: '1,020 services',
      imageUrl:
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
    ),
  ];

  List<CategoryItem> get _filteredCategories {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _allCategories;

    return _allCategories.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.subtitle.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() => _query = v);
  }

  void _onTapCategory(CategoryItem item) {
    // TODO: Navigate to category details / services list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open: ${item.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _filteredCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.person_outline, color: Colors.grey.shade700),
          ),
        ),
        title: const Text(
          'Catalog',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade800),
            onSelected: (v) {},
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0, child: Text('Sort')),
              PopupMenuItem(value: 1, child: Text('Filters')),
              PopupMenuItem(value: 2, child: Text('Saved')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSearchTap: () => FocusScope.of(context).unfocus(),
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final selected = i == _selectedChip;
                  return ChoiceChip(
                    label: Text(_chips[i]),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedChip = i),
                    selectedColor: primary.withOpacity(0.12),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? primary : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected ? primary.withOpacity(0.35) : Colors.grey.shade300,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular categories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${categories.length} found',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return _CategoryCard(
                    item: item,
                    onTap: () => _onTapCategory(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearchTap;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search services',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onSearchTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback onTap;

  const _CategoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
