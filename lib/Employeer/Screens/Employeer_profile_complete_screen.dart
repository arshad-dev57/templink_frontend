import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/register_controller.dart';
import 'package:templink/Employeer/Screens/Employeer_homescreen.dart';

class EmployerProfileCompleteScreen extends StatefulWidget {
  final String country;

  const EmployerProfileCompleteScreen({
    Key? key,
    required this.country,
  }) : super(key: key);

  @override
  State<EmployerProfileCompleteScreen> createState() =>
      _EmployerProfileCompleteScreenState();
}

class _EmployerProfileCompleteScreenState
    extends State<EmployerProfileCompleteScreen> {
  static const Color kGreen = Color(0xFF14A800);

  int _currentStep = 0;
  final PageController _pageController = PageController();
  final RegisterController registerC = Get.find<RegisterController>();

  // Employer profile data
  final Map<String, dynamic> companyData = {
    'companyName': '',
    'logoUrl': '',
    'industry': '',
    'city': '',
    'country': '',
    'companySize': '',
    'workModel': '',
    'phone': '',
    'companyEmail': '',
    'website': '',
    'linkedin': '',
    'about': '',
    'mission': '',
    'cultureTags': <String>[],
    'teamMembers': <Map<String, dynamic>>[],
  };

  final List<String> _companySizes = const [
    '1-10',
    '11-50',
    '51-200',
    '201-500',
    '501-1000',
    '1000+',
  ];

  final List<String> _workModels = const [
    'Remote',
    'Onsite',
    'Hybrid',
  ];

  // Controllers
  final TextEditingController _companyNameC = TextEditingController();
  final TextEditingController _industryC = TextEditingController();
  final TextEditingController _cityC = TextEditingController();
  final TextEditingController _phoneC = TextEditingController();
  final TextEditingController _companyEmailC = TextEditingController();
  final TextEditingController _websiteC = TextEditingController();
  final TextEditingController _linkedinC = TextEditingController();
  final TextEditingController _aboutC = TextEditingController();
  final TextEditingController _missionC = TextEditingController();
  final TextEditingController _cultureTagC = TextEditingController();

  // Team member controllers
  final TextEditingController _tmNameC = TextEditingController();
  final TextEditingController _tmRoleC = TextEditingController();
  final TextEditingController _tmEmailC = TextEditingController();

  String? _selectedCompanySize;
  String? _selectedWorkModel;

  @override
  void initState() {
    super.initState();
    companyData['country'] = widget.country;
    
    print("🟡 EmployerProfileCompleteScreen initialized");
    print("Country from RegisterScreen: ${widget.country}");
    print("RegisterController data:");
    print("  firstName: ${registerC.firstName}");
    print("  lastName: ${registerC.lastName}");
    print("  email: ${registerC.email}");
  }

  @override
  void dispose() {
    _pageController.dispose();
    _companyNameC.dispose();
    _industryC.dispose();
    _cityC.dispose();
    _phoneC.dispose();
    _companyEmailC.dispose();
    _websiteC.dispose();
    _linkedinC.dispose();
    _aboutC.dispose();
    _missionC.dispose();
    _cultureTagC.dispose();
    _tmNameC.dispose();
    _tmRoleC.dispose();
    _tmEmailC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentStep == 0
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              title: Text(
                'Step ${_currentStep + 1} of 7',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              centerTitle: true,
            ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1CompanyBasics(),
          _buildStep2ContactLinks(),
          _buildStep3AboutCompany(),
          _buildStep4Culture(),
          _buildStep5TeamMembers(),
          _buildStep6Review(),
          _buildStep7Success(),
        ],
      ),
    );
  }

  Widget _buildStep1CompanyBasics() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Complete your Employer profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Let’s start with company basics.',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),

                    // Logo placeholder
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.business,
                                    size: 44, color: Colors.grey),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: kGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              // TODO: upload logic
                            },
                            child: const Text(
                              'Upload Company Logo (Optional)',
                              style: TextStyle(
                                color: kGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildLabeledField(
                      label: 'Company Name *',
                      controller: _companyNameC,
                      hint: 'e.g., Creative Tech Agency',
                      onChanged: (v) {
                        setState(() {
                          companyData['companyName'] = v;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabeledField(
                      label: 'Industry *',
                      controller: _industryC,
                      hint: 'e.g., Enterprise Software',
                      onChanged: (v) {
                        setState(() {
                          companyData['industry'] = v;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabeledField(
                      label: 'City *',
                      controller: _cityC,
                      hint: 'e.g., Lahore',
                      onChanged: (v) {
                        setState(() {
                          companyData['city'] = v;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Company Size *',
                            value: _selectedCompanySize,
                            items: _companySizes,
                            hint: 'Select size',
                            onChanged: (v) {
                              setState(() {
                                _selectedCompanySize = v;
                                companyData['companySize'] = v ?? '';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Work Model *',
                            value: _selectedWorkModel,
                            items: _workModels,
                            hint: 'Remote/Onsite/Hybrid',
                            onChanged: (v) {
                              setState(() {
                                _selectedWorkModel = v;
                                companyData['workModel'] = v ?? '';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _buildNextButton(
              isEnabled:
                  companyData['companyName']!.toString().trim().isNotEmpty &&
                  companyData['industry']!.toString().trim().isNotEmpty &&
                  companyData['city']!.toString().trim().isNotEmpty &&
                  companyData['companySize']!.toString().trim().isNotEmpty &&
                  companyData['workModel']!.toString().trim().isNotEmpty,
              onPressed: _goToNextStep,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2ContactLinks() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Contact & Links',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add contact details and public links (optional but recommended).',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),

                    _buildLabeledField(
                      label: 'Phone Number *',
                      controller: _phoneC,
                      hint: 'e.g., +92 300 1234567',
                      keyboardType: TextInputType.phone,
                      onChanged: (v) {
                        setState(() {
                          companyData['phone'] = v;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabeledField(
                      label: 'Company Email (Optional)',
                      controller: _companyEmailC,
                      hint: 'e.g., hr@company.com',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) {
                        setState(() {
                          companyData['companyEmail'] = v;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabeledField(
                      label: 'Website (Optional)',
                      controller: _websiteC,
                      hint: 'e.g., https://yourcompany.com',
                      keyboardType: TextInputType.url,
                      onChanged: (v) {
                        setState(() {
                          companyData['website'] = v;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabeledField(
                      label: 'LinkedIn (Optional)',
                      controller: _linkedinC,
                      hint: 'e.g., https://linkedin.com/company/xyz',
                      keyboardType: TextInputType.url,
                      onChanged: (v) {
                        setState(() {
                          companyData['linkedin'] = v;
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _buildNextButton(
              isEnabled: companyData['phone']!.toString().trim().isNotEmpty,
              onPressed: _goToNextStep,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3AboutCompany() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'About Company',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Write a short company description (this is visible to talent).',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),

                    _buildMultilineField(
                      label: 'Company Bio *',
                      controller: _aboutC,
                      hint:
                          'Describe what your company does, products/services, and what you hire for...',
                      maxLines: 7,
                      maxLength: 700,
                      onChanged: (v) {
                        setState(() {
                          companyData['about'] = v;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildMultilineField(
                      label: 'Mission / Vision (Optional)',
                      controller: _missionC,
                      hint: 'Optional: mission, values, what you stand for...',
                      maxLines: 4,
                      maxLength: 300,
                      onChanged: (v) {
                        setState(() {
                          companyData['mission'] = v;
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _buildNextButton(
              isEnabled: companyData['about']!.toString().trim().isNotEmpty,
              onPressed: _goToNextStep,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Culture() {
    final List<String> defaultTags = const [
      'Remote-First',
      'Flexible Hours',
      'Health Benefits',
      'Learning Budget',
      'Team Events',
      'Growth Culture',
      'Paid Leaves',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Company Culture',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select perks/culture tags (optional but boosts trust).',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Suggested Tags',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: defaultTags.map((t) {
                        final selected =
                            (companyData['cultureTags'] as List<String>)
                                .contains(t);
                        return ChoiceChip(
                          label: Text(t),
                          selected: selected,
                          selectedColor: kGreen,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          onSelected: (val) {
                            setState(() {
                              final list =
                                  companyData['cultureTags'] as List<String>;
                              if (val) {
                                if (!list.contains(t)) list.add(t);
                              } else {
                                list.remove(t);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.shade300, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cultureTagC,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: InputBorder.none,
                                hintText: 'Add custom culture tag',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                              ),
                              onSubmitted: (_) => _addCultureTag(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: kGreen),
                            onPressed: _addCultureTag,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if ((companyData['cultureTags'] as List<String>).isNotEmpty)
                      ...[
                        Text(
                          'Selected Tags',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              (companyData['cultureTags'] as List<String>)
                                  .map((t) {
                            return Chip(
                              label: Text(t),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  (companyData['cultureTags'] as List<String>)
                                      .remove(t);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _buildNextButton(
              isEnabled: true,
              onPressed: _goToNextStep,
            ),
          ],
        ),
      ),
    );
  }

  void _addCultureTag() {
    final text = _cultureTagC.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final tags = companyData['cultureTags'] as List<String>;
      if (!tags.contains(text)) tags.add(text);
      _cultureTagC.clear();
    });
  }

  Widget _buildStep5TeamMembers() {
    final team = companyData['teamMembers'] as List<Map<String, dynamic>>;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Team Members',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add key contacts (optional, but looks professional).',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),

                    if (team.isEmpty) ...[
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.groups_outlined,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No team members added yet',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    ] else ...[
                      ...List.generate(team.length, (i) {
                        final member = team[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: kGreen.withOpacity(0.12),
                                child: Text(
                                  (member['name'] ?? 'T').isNotEmpty
                                      ? (member['name']![0]).toUpperCase()
                                      : 'T',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['name'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member['role'] ?? '',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600),
                                    ),
                                    if ((member['email'] ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        member['email']!,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeTeamMember(i),
                                icon: Icon(Icons.close,
                                    size: 20, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showAddTeamMemberSheet,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Team Member'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kGreen,
                          side: const BorderSide(color: kGreen),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _buildNextButton(
              isEnabled: true,
              onPressed: _goToNextStep,
            ),
          ],
        ),
      ),
    );
  }

  void _removeTeamMember(int index) {
    setState(() {
      (companyData['teamMembers'] as List).removeAt(index);
    });
  }

  void _showAddTeamMemberSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Team Member',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  _buildLabeledField(
                    label: 'Name *',
                    controller: _tmNameC,
                    hint: 'e.g., Alex Rivera',
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 14),

                  _buildLabeledField(
                    label: 'Role/Designation *',
                    controller: _tmRoleC,
                    hint: 'e.g., CTO / HR Manager',
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 14),

                  _buildLabeledField(
                    label: 'Email (Optional)',
                    controller: _tmEmailC,
                    hint: 'e.g., alex@company.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = _tmNameC.text.trim();
                        final role = _tmRoleC.text.trim();
                        final email = _tmEmailC.text.trim();

                        if (name.isEmpty || role.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Name & Role are required',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        setState(() {
                          (companyData['teamMembers'] as List).add({
                            'name': name,
                            'role': role,
                            'email': email,
                          });
                        });

                        _tmNameC.clear();
                        _tmRoleC.clear();
                        _tmEmailC.clear();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Member',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep6Review() {
    final team = companyData['teamMembers'] as List<Map<String, dynamic>>;
    final tags = companyData['cultureTags'] as List<String>;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.checklist, color: kGreen),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Review Employer Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Submit to finish profile. You can edit later.',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildReviewCard(
                      icon: Icons.business_outlined,
                      title: 'Company Basics',
                      items: [
                        _reviewRow('Company', companyData['companyName']),
                        _reviewRow('Industry', companyData['industry']),
                        _reviewRow(
                          'Location',
                          '${companyData['city']}, ${companyData['country']}',
                        ),
                        _reviewRow('Size', companyData['companySize']),
                        _reviewRow('Work Model', companyData['workModel']),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildReviewCard(
                      icon: Icons.link_outlined,
                      title: 'Contact & Links',
                      items: [
                        _reviewRow('Phone', companyData['phone']),
                        _reviewRow('Email', companyData['companyEmail']),
                        _reviewRow('Website', companyData['website']),
                        _reviewRow('LinkedIn', companyData['linkedin']),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildReviewCard(
                      icon: Icons.description_outlined,
                      title: 'About',
                      items: [
                        _reviewRow('Bio', companyData['about'], maxLines: 3),
                        _reviewRow('Mission', companyData['mission'], maxLines: 2),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildReviewCard(
                      icon: Icons.celebration_outlined,
                      title: 'Culture',
                      items: [
                        _reviewRow('Tags',
                            tags.isEmpty ? '' : tags.join(', '),
                            maxLines: 3),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildReviewCard(
                      icon: Icons.groups_outlined,
                      title: 'Team Members',
                      items: [
                        _reviewRow('Total', '${team.length} member(s)'),
                        if (team.isNotEmpty)
                          _reviewRow(
                            'Latest',
                            '${team.last['name']} (${team.last['role']})',
                            maxLines: 2,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Obx(() {
                final loading = registerC.isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewRow(String label, dynamic value, {int maxLines = 1}) {
    final String textValue = value?.toString() ?? '';
    final hasValue = textValue.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: hasValue
                ? Text(
                    textValue,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    'Not provided',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep7Success() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: kGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 60, color: kGreen),
          ),
          const SizedBox(height: 28),
          const Text(
            'Employer Profile Complete!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You can now post jobs/projects and hire talent.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Get.offAll(() => const EmployeerHomeScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Go to Home Screen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextStep() {
    if (_currentStep < 6) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitProfile() async {
    print("\n🟡 ===== SUBMITTING EMPLOYER PROFILE =====");
    print("Company Data: $companyData");
    
    print("📦 RegisterController data:");
    print("  firstName: ${registerC.firstName}");
    print("  lastName: ${registerC.lastName}");
    print("  email: ${registerC.email}");
    print("  country: ${registerC.country}");
    
    final success = await registerC.registerEmployer(companyData);
    
    if (success) {
      print("✅ Employer registration successful!");
      _goToNextStep();
    } else {
      print("❌ Employer registration failed!");
    }
  }

  Widget _buildNextButton({
    required bool isEnabled,
    required VoidCallback onPressed,
    String text = 'Next',
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMultilineField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    int? maxLength,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              hint: Text(
                hint ?? 'Select',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              items: items
                  .map(
                    (x) => DropdownMenuItem(
                      value: x,
                      child: Text(x, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required IconData icon,
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: kGreen, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }
} 