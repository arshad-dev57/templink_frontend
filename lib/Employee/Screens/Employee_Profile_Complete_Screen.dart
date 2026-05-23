import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:templink/Controllers/register_controller.dart';
import 'package:templink/Employee/Screens/Employee_HomeScreen.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:image_picker/image_picker.dart';

class EmployeeProfileCompleteScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String country;
  final bool sendEmails;
  final bool termsAccepted;

  const EmployeeProfileCompleteScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.country,
    required this.sendEmails,
    required this.termsAccepted,
  }) : super(key: key);

  @override
  State<EmployeeProfileCompleteScreen> createState() => _EmployeeProfileCompleteScreenState();
}

class _EmployeeProfileCompleteScreenState extends State<EmployeeProfileCompleteScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  late final RegisterController registerC;

  final TextEditingController _skillController = TextEditingController();
  
  Map<String, dynamic> userData = {
    'experienceLevel': '',
    'goal': '',
    'category': '',
    'subcategory': '',
    'skills': <String>[],
    'title': '',
    'workExperiences': [],
    'educations': [],
    'bio': '',
    'hourlyRate': '',
    'photoUrl': '',
    'dateOfBirth': '',
    'streetAddress': '',
    'city': '',
    'province': '',
    'phoneNumber': '',
    'country': '',
  };
  
  final List<Map<String, dynamic>> categories = [
    {'name': 'IT & Networking', 'subcategories': ['Database Management', 'ERP/CRM', 'Network Security', 'Cloud Computing', 'System Admin', 'DevOps', 'AI/ML Engineering']},
    {'name': 'Design & Creative', 'subcategories': ['UI/UX Design', 'Graphic Design', 'Web Design', 'Logo Design', 'Animation', 'Product Design', 'Industrial Design']},
    {'name': 'Writing & Translation', 'subcategories': ['Content Writing', 'Technical Writing', 'Copywriting', 'Translation', 'Proofreading', 'Grant Writing', 'Editing']},
    {'name': 'Digital Marketing', 'subcategories': ['SEO', 'Social Media', 'Email Marketing', 'PPC Ads', 'Content Marketing', 'Affiliate Marketing', 'Marketing Analytics']},
    {'name': 'Business & Finance', 'subcategories': ['Accounting', 'Financial Analysis', 'Business Planning', 'Market Research', 'Consulting', 'Investment Banking', 'Auditing', 'Risk Management']},
    {'name': 'Engineering & Architecture', 'subcategories': ['Civil Engineering', 'Mechanical Eng', 'Electrical Eng', 'Architecture', 'CAD Design', 'Structural Engineering', 'Project Management']},
    {'name': 'Healthcare & Medical', 'subcategories': ['Nursing', 'Physician', 'Pharmacy', 'Medical Lab Technology', 'Public Health', 'Medical Research', 'Physiotherapy']},
    {'name': 'Education & Training', 'subcategories': ['Teaching', 'Corporate Training', 'Curriculum Development', 'E-learning', 'Tutoring', 'Instructional Design']},
    {'name': 'Legal & Compliance', 'subcategories': ['Corporate Law', 'Legal Research', 'Contract Management', 'Intellectual Property', 'Compliance Officer', 'Paralegal']},
    {'name': 'Human Resources', 'subcategories': ['Recruitment', 'Employee Relations', 'HR Analytics', 'Payroll Management', 'Training & Development']},
    {'name': 'Project Management', 'subcategories': ['Agile Project Management', 'Scrum Master', 'PMO Management', 'Risk Management', 'Operations Management']},
    {'name': 'Sales & Business Development', 'subcategories': ['B2B Sales', 'Account Management', 'Lead Generation', 'CRM Management', 'Retail Sales', 'Strategic Partnerships']},
    {'name': 'Science & Research', 'subcategories': ['Data Analysis', 'Laboratory Research', 'Scientific Writing', 'Biotech', 'Chemistry', 'Physics Research']},
    {'name': 'Finance & Investment', 'subcategories': ['Portfolio Management', 'Financial Planning', 'Equity Research', 'Accounting', 'Investment Analysis', 'Tax Consulting']},
  ];
  
  String? _selectedCategory;
  String? _selectedSubcategory;
  
  final TextEditingController _expTitleController = TextEditingController();
  final TextEditingController _expCompanyController = TextEditingController();
  final TextEditingController _expLocationController = TextEditingController();
  final TextEditingController _expCountryController = TextEditingController();
  final TextEditingController _expDescriptionController = TextEditingController();
  String? _expStartYear;
  String? _expEndYear;
  bool _expCurrentlyWorking = false;
  
  final TextEditingController _eduSchoolController = TextEditingController();
  final TextEditingController _eduDegreeController = TextEditingController();
  final TextEditingController _eduFieldController = TextEditingController();
  final TextEditingController _eduDescriptionController = TextEditingController();
  String? _eduStartYear;
  String? _eduEndYear;
  bool _eduCurrentlyAttending = false;

  // ✅ Web and Mobile compatible photo storage
  File? _selectedPhoto;      // For Mobile (Android/iOS)
  Uint8List? _webPhotoBytes; // For Web
  String? _photoError;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    registerC = Get.isRegistered<RegisterController>()
        ? Get.find<RegisterController>()
        : Get.put(RegisterController(), permanent: true);
    userData['country'] = widget.country;
    _setBasicInfoInController();
  }

  void _setBasicInfoInController() {
    registerC.setBasicInfo(
      role: 'employee',
      firstName: widget.firstName,
      lastName: widget.lastName,
      email: widget.email,
      password: widget.password,
      country: widget.country,
      sendEmails: widget.sendEmails,
      termsAccepted: widget.termsAccepted,
    );
  }

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('Choose Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.photo_library, color: const Color(0xFF14A800), size: 28)),
                title: const Text('Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                subtitle: const Text('Choose from your gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  await _handlePickedImage(picked);
                },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.camera_alt, color: const Color(0xFF14A800), size: 28)),
                title: const Text('Camera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                subtitle: const Text('Take a new photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  await _handlePickedImage(picked);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ✅ Web and Mobile compatible image handler
  Future<void> _handlePickedImage(XFile? picked) async {
    if (picked != null) {
      if (kIsWeb) {
        // ✅ For Web: Read as bytes
        final bytes = await picked.readAsBytes();
        setState(() {
          _webPhotoBytes = bytes;
          _selectedPhoto = null;
          _photoError = null;
          userData['photoUrl'] = picked.path;
        });
        print("✅ Web: Photo loaded, bytes length: ${bytes.length}");
      } else {
        // ✅ For Mobile: Store as File
        setState(() {
          _selectedPhoto = File(picked.path);
          _webPhotoBytes = null;
          _photoError = null;
          userData['photoUrl'] = picked.path;
        });
        print("✅ Mobile: Photo loaded, path: ${_selectedPhoto!.path}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    
    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }
  
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(flex: 1, child: _buildFormContent(isDesktop: true)),
          Expanded(flex: 1, child: _buildImageSection()),
        ],
      ),
    );
  }
  
  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(flex: 6, child: _buildFormContent(isDesktop: false)),
          Expanded(flex: 4, child: _buildImageSection()),
        ],
      ),
    );
  }
  
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentStep == 0 ? null : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
              _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }
          },
        ),
        title: Text('Step ${_currentStep + 1} of 12', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1(), _buildStep2(), _buildStep3(), _buildStep4(),
          _buildStep5(), _buildStep6(), _buildStep7(), _buildStep8(),
          _buildStep9(), _buildStep10(), _buildStep11(), _buildStep12(),
        ],
      ),
    );
  }
  
  Widget _buildFormContent({required bool isDesktop}) {
    return SafeArea(
      child: Column(
        children: [
          if (isDesktop) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: _currentStep > 0 ? () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    } : null,
                  ),
                  const Spacer(),
                  Text('Step ${_currentStep + 1} of 12', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ],
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(), _buildStep2(), _buildStep3(), _buildStep4(),
                _buildStep5(), _buildStep6(), _buildStep7(), _buildStep8(),
                _buildStep9(), _buildStep10(), _buildStep11(), _buildStep12(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=800&h=1200&fit=crop',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF4CAF50),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_outline, size: 80, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text('Templink', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)]),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.work_outline, size: 60, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text('Complete Your Profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  Text('Tell us about yourself to get started with finding amazing opportunities.', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9), height: 1.4)),
                  const SizedBox(height: 32),
                  _buildFeatureItem(Icons.verified_outlined, 'Stand out to employers'),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.work_outline, 'Get relevant job matches'),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.trending_up, 'Grow your career'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.95))),
      ],
    );
  }

  // Step 1
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('A Few quick questions first', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Have you freelanced before?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 16),
          Text('This let us know how much help to give you along the way.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5)),
          const SizedBox(height: 40),
          _buildOptionButton('I am brand new to this', isSelected: userData['experienceLevel'] == 'new', onTap: () => setState(() => userData['experienceLevel'] = 'new')),
          const SizedBox(height: 16),
          _buildOptionButton('I have some experience', isSelected: userData['experienceLevel'] == 'some', onTap: () => setState(() => userData['experienceLevel'] = 'some')),
          const SizedBox(height: 16),
          _buildOptionButton('I am an expert', isSelected: userData['experienceLevel'] == 'expert', onTap: () => setState(() => userData['experienceLevel'] = 'expert')),
          const SizedBox(height: 40),
          _buildNextButton(isEnabled: userData['experienceLevel'].isNotEmpty, onPressed: _goToNextStep),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 2
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Got it!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          const Text('What is your biggest goal?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 40),
          _buildOptionButton('To make money on the side', isSelected: userData['goal'] == 'money', onTap: () => setState(() => userData['goal'] = 'money')),
          const SizedBox(height: 16),
          _buildOptionButton('To get experience for a full time job', isSelected: userData['goal'] == 'experience', onTap: () => setState(() => userData['goal'] = 'experience')),
          const SizedBox(height: 16),
          _buildOptionButton("I don't have a goal in mind yet", isSelected: userData['goal'] == 'no_goal', onTap: () => setState(() => userData['goal'] = 'no_goal')),
          const SizedBox(height: 40),
          _buildNextButton(isEnabled: userData['goal'].isNotEmpty, onPressed: _goToNextStep),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 3
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('How would you like to tell us about yourself?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('What kind of work are you here to do?\nDon\'t worry, you can change these choices later on.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5)),
          const SizedBox(height: 32),
          Text('Select Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: categories.map((category) {
            return ChoiceChip(
              label: Text(category['name']),
              selected: _selectedCategory == category['name'],
              onSelected: (selected) => setState(() { _selectedCategory = selected ? category['name'] : null; _selectedSubcategory = null; }),
              selectedColor: const Color(0xFF14A800),
              labelStyle: TextStyle(color: _selectedCategory == category['name'] ? Colors.white : Colors.black87),
            );
          }).toList()),
          if (_selectedCategory != null) ...[
            const SizedBox(height: 32),
            Text('Select Subcategory', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: categories.firstWhere((cat) => cat['name'] == _selectedCategory)['subcategories'].map<Widget>((subcat) {
              return ChoiceChip(
                label: Text(subcat),
                selected: _selectedSubcategory == subcat,
                onSelected: (selected) => setState(() => _selectedSubcategory = selected ? subcat : null),
                selectedColor: const Color(0xFF14A800),
                labelStyle: TextStyle(color: _selectedSubcategory == subcat ? Colors.white : Colors.black87),
              );
            }).toList()),
          ],
          const SizedBox(height: 40),
          _buildNextButton(isEnabled: _selectedCategory != null && _selectedSubcategory != null, onPressed: () {
            userData['category'] = _selectedCategory;
            userData['subcategory'] = _selectedSubcategory;
            _goToNextStep();
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 4
  Widget _buildStep4() {
    if (userData['skills'] == null) userData['skills'] = [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Nearly there!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('What work are you here to do?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Text('Your skills show clients what you can offer.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 1.5), borderRadius: BorderRadius.circular(8)), child: Row(children: [
            Expanded(child: TextField(controller: _skillController, decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: InputBorder.none, hintText: 'Enter skills here'), onSubmitted: (value) { if (value.trim().isNotEmpty) { setState(() { (userData['skills'] as List<String>).add(value.trim()); _skillController.clear(); }); } })),
            IconButton(icon: const Icon(Icons.add, color: Color(0xFF14A800)), onPressed: () { if (_skillController.text.trim().isNotEmpty) { setState(() { (userData['skills'] as List<String>).add(_skillController.text.trim()); _skillController.clear(); }); } }),
          ])),
          const SizedBox(height: 8),
          Text('At least one skill is required', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          if ((userData['skills'] as List<String>).isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: (userData['skills'] as List<String>).map((skill) => Chip(label: Text(skill), deleteIcon: const Icon(Icons.close, size: 16), onDeleted: () => setState(() { (userData['skills'] as List<String>).remove(skill); }))).toList()),
          const SizedBox(height: 40),
          _buildNextButton(isEnabled: (userData['skills'] as List<String>).isNotEmpty, onPressed: _goToNextStep),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 5
  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Got it. Now, add a title', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tell the world what you do', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Text("It's the first thing clients see, so make it count.", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 1.5), borderRadius: BorderRadius.circular(8)), child: TextFormField(initialValue: userData['title'], decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: InputBorder.none, hintText: 'Your professional role'), maxLines: 2, onChanged: (value) => setState(() => userData['title'] = value))),
          const SizedBox(height: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Examples:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)), const SizedBox(height: 8), Text('• Senior Flutter Developer'), Text('• UI/UX Designer'), Text('• Full Stack Developer')]),
          const SizedBox(height: 40),
          _buildNextButton(isEnabled: userData['title'].trim().isNotEmpty, onPressed: _goToNextStep),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 6
  Widget _buildStep6() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Work Experience', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add your professional experience', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          if (userData['workExperiences'].isEmpty) 
            Center(child: Column(children: [Icon(Icons.work_outline, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), Text('No work experience added yet', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))])),
          ...(userData['workExperiences'] as List).map((exp) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(leading: const Icon(Icons.work, color: Color(0xFF14A800)), title: Text(exp['title'] ?? ''), subtitle: Text('${exp['company']} • ${exp['startYear']} - ${exp['currentlyWorking'] ? 'Present' : exp['endYear']}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editWorkExperience(userData['workExperiences'].indexOf(exp))), IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => setState(() => userData['workExperiences'].remove(exp)))]) ))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _addWorkExperience, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF14A800), side: const BorderSide(color: Color(0xFF14A800)), padding: const EdgeInsets.symmetric(vertical: 16)), icon: const Icon(Icons.add), label: const Text('Add Work Experience'))),
          const SizedBox(height: 16),
          _buildNextButton(isEnabled: true, onPressed: _goToNextStep),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 7
  Widget _buildStep7() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Education', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add your educational background', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          if (userData['educations'].isEmpty)
            Center(child: Column(children: [Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), Text('No education added yet', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))])),
          ...(userData['educations'] as List).map((edu) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(leading: const Icon(Icons.school, color: Color(0xFF14A800)), title: Text(edu['degree'] ?? ''), subtitle: Text('${edu['school']} • ${edu['startYear']} - ${edu['currentlyAttending'] ? 'Present' : edu['endYear']}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editEducation(userData['educations'].indexOf(edu))), IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => setState(() => userData['educations'].remove(edu)))]) ))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _addEducation, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF14A800), side: const BorderSide(color: Color(0xFF14A800)), padding: const EdgeInsets.symmetric(vertical: 16)), icon: const Icon(Icons.add), label: const Text('Add Education'))),
          const SizedBox(height: 16),
          _buildNextButton(isEnabled: true, onPressed: _goToNextStep),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 8
  Widget _buildStep8() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Great! Now write a bio', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tell the world about yourself', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Text("Share your professional story and skills.", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 1.5), borderRadius: BorderRadius.circular(8)), child: TextFormField(initialValue: userData['bio'], decoration: InputDecoration(contentPadding: const EdgeInsets.all(16), border: InputBorder.none, hintText: 'Write your bio here...'), maxLines: 8, maxLength: 500, onChanged: (value) => setState(() => userData['bio'] = value))),
          const SizedBox(height: 16),
          Text('${userData['bio'].length}/500 characters', style: TextStyle(fontSize: 12, color: Colors.grey.shade500), textAlign: TextAlign.right),
          const SizedBox(height: 40),
          _buildNextButton(isEnabled: (userData['bio'] ?? '').trim().isNotEmpty, onPressed: _goToNextStep),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 9
  Widget _buildStep9() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Set your hourly rate', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('How much do you want to charge per hour?', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 1.5), borderRadius: BorderRadius.circular(8)), child: Row(children: [
            const Padding(padding: EdgeInsets.only(left: 16), child: Text('\$', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            Expanded(child: TextFormField(initialValue: userData['hourlyRate'], keyboardType: TextInputType.number, decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16), border: InputBorder.none, hintText: 'Enter hourly rate'), onChanged: (value) => setState(() => userData['hourlyRate'] = value))),
            const Padding(padding: EdgeInsets.only(right: 16), child: Text('/hr', style: TextStyle(fontSize: 16, color: Colors.grey))),
          ])),
          const SizedBox(height: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Suggested rates for ${userData['category'] ?? 'your field'}:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 8, children: ['30', '50', '75', '100'].map((rate) => _buildRateSuggestion(rate)).toList()),
          ]),
          const SizedBox(height: 40),
          _buildNextButton(isEnabled: userData['hourlyRate'].isNotEmpty, onPressed: _goToNextStep),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 10 - ✅ Web and Mobile compatible photo display
  Widget _buildStep10() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('A few more details', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Complete your profile with personal information', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          Center(child: Column(children: [
            Stack(children: [
              // ✅ Web and Mobile compatible image display
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  image: _getPhotoDecorationImage(),
                ),
                child: (_selectedPhoto == null && _webPhotoBytes == null)
                    ? const Icon(Icons.person, size: 48, color: Colors.grey)
                    : null,
              ),
              Positioned(bottom: 0, right: 0, child: InkWell(onTap: _pickPhoto, child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF14A800), shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 20)))),
            ]),
            const SizedBox(height: 16),
            TextButton(onPressed: _pickPhoto, child: const Text('Upload Photo *', style: TextStyle(color: Color(0xFF14A800), fontWeight: FontWeight.w600))),
            if (_photoError != null) ...[const SizedBox(height: 6), Text(_photoError!, style: const TextStyle(color: Colors.red, fontSize: 12))],
          ])),
          const SizedBox(height: 32),
          _buildPersonalDetailField('Date of Birth *', userData['dateOfBirth'], (value) => userData['dateOfBirth'] = value, isDate: true),
          const SizedBox(height: 16),
          _buildPersonalDetailField('Street Address *', userData['streetAddress'], (value) => userData['streetAddress'] = value),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildPersonalDetailField('City *', userData['city'], (value) => userData['city'] = value)),
            const SizedBox(width: 16),
            Expanded(child: _buildPersonalDetailField('Province/State *', userData['province'], (value) => userData['province'] = value)),
          ]),
          const SizedBox(height: 16),
          _buildPersonalDetailField('Phone Number *', userData['phoneNumber'], (value) => userData['phoneNumber'] = value, keyboardType: TextInputType.phone),
          const SizedBox(height: 40),
          _buildNextButton(isEnabled: true, onPressed: _validateAndProceed),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ Helper method for photo decoration (works on both web and mobile)
  DecorationImage? _getPhotoDecorationImage() {
    if (kIsWeb) {
      if (_webPhotoBytes != null) {
        return DecorationImage(image: MemoryImage(_webPhotoBytes!), fit: BoxFit.cover);
      }
    } else {
      if (_selectedPhoto != null) {
        return DecorationImage(image: FileImage(_selectedPhoto!), fit: BoxFit.cover);
      }
    }
    return null;
  }

  // Step 11
  Widget _buildStep11() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF14A800).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.checklist, color: Color(0xFF14A800), size: 24)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Review Your Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)), Text('Please verify all information before submitting', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))])),
          ]),
          const SizedBox(height: 32),
          _buildReviewCard(icon: Icons.person_outline, title: 'Personal Information', items: [
            _buildReviewItemTile(label: 'Name', value: '${widget.firstName} ${widget.lastName}'),
            _buildReviewItemTile(label: 'Email', value: widget.email),
            _buildReviewItemTile(label: 'Country', value: widget.country),
            _buildReviewItemTile(label: 'Experience Level', value: userData['experienceLevel']),
            _buildReviewItemTile(label: 'Professional Title', value: userData['title']),
            _buildReviewItemTile(label: 'Hourly Rate', value: userData['hourlyRate'].isNotEmpty ? '\$${userData['hourlyRate']}/hr' : ''),
          ]),
          const SizedBox(height: 16),
          _buildReviewCard(icon: Icons.work_outline, title: 'Skills & Expertise', items: [
            _buildReviewItemTile(label: 'Category', value: '${userData['category']} - ${userData['subcategory']}'),
            _buildReviewItemTile(label: 'Skills', value: (userData['skills'] as List<String>).join(', ')),
          ]),
          const SizedBox(height: 16),
          if (userData['workExperiences'].isNotEmpty || userData['educations'].isNotEmpty)
            _buildReviewCard(icon: Icons.school_outlined, title: 'Experience & Education', items: [
              if (userData['workExperiences'].isNotEmpty) _buildReviewItemTile(label: 'Work Experience', value: '${userData['workExperiences'].length} position(s)'),
              if (userData['educations'].isNotEmpty) _buildReviewItemTile(label: 'Education', value: '${userData['educations'].length} institution(s)'),
            ]),
          const SizedBox(height: 16),
          if (userData['bio'].isNotEmpty)
            _buildReviewCard(icon: Icons.description_outlined, title: 'About Me', items: [
              _buildReviewItemTile(label: 'Bio', value: userData['bio']),
            ]),
          const SizedBox(height: 40),
          Obx(() {
            final loading = registerC.isLoading.value;
            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : _submitProfile,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Text('Submit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 12
  Widget _buildStep12() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Container(width: 120, height: 120, decoration: BoxDecoration(color: const Color(0xFF14A800).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check, size: 60, color: Color(0xFF14A800))),
          const SizedBox(height: 32),
          const Text('Profile Complete!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text('Your profile has been successfully created. You can now start finding amazing opportunities.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: () => Get.offAll(() => const EmployeeHomeScreen()), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Go to Home Screen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF14A800).withOpacity(0.1) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF14A800) : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF14A800) : Colors.black87), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildNextButton({required bool isEnabled, required VoidCallback onPressed, String text = 'Next'}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildRateSuggestion(String rate) {
    return GestureDetector(
      onTap: () => setState(() => userData['hourlyRate'] = rate),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: userData['hourlyRate'] == rate ? const Color(0xFF14A800).withOpacity(0.1) : Colors.grey.shade100,
          border: Border.all(color: userData['hourlyRate'] == rate ? const Color(0xFF14A800) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('\$$rate/hr', style: TextStyle(color: userData['hourlyRate'] == rate ? const Color(0xFF14A800) : Colors.grey.shade700, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildPersonalDetailField(String label, String value, Function(String) onChanged, {bool isDate = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 1.5), borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            initialValue: value,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              suffixIcon: isDate ? const Icon(Icons.calendar_today, size: 20) : null,
            ),
            onChanged: onChanged,
            readOnly: isDate,
            onTap: isDate ? () => _selectDate(context) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({required IconData icon, required String title, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF14A800).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF14A800), size: 18)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            ]),
          ),
          Padding(padding: const EdgeInsets.all(16), child: Column(children: items)),
        ],
      ),
    );
  }

  Widget _buildReviewItemTile({required String label, required dynamic value}) {
    final text = (value ?? '').toString();
    final hasValue = text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700))),
        Expanded(flex: 3, child: Text(hasValue ? text : 'Not provided', style: TextStyle(fontSize: 13, color: hasValue ? Colors.black87 : Colors.grey.shade500, fontStyle: hasValue ? FontStyle.normal : FontStyle.italic, fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal))),
      ]),
    );
  }

  void _goToNextStep() {
    if (_currentStep < 11) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _validateAndProceed() {
    List<String> emptyFields = [];
    
    // ✅ Check photo based on platform
    if (kIsWeb) {
      if (_webPhotoBytes == null) emptyFields.add("Profile Photo");
    } else {
      if (_selectedPhoto == null) emptyFields.add("Profile Photo");
    }
    
    if (userData['dateOfBirth'] == null || userData['dateOfBirth'].isEmpty) emptyFields.add("Date of Birth");
    if (userData['streetAddress'] == null || userData['streetAddress'].isEmpty) emptyFields.add("Street Address");
    if (userData['city'] == null || userData['city'].isEmpty) emptyFields.add("City");
    if (userData['province'] == null || userData['province'].isEmpty) emptyFields.add("Province/State");
    if (userData['phoneNumber'] == null || userData['phoneNumber'].isEmpty) emptyFields.add("Phone Number");
    
    if (emptyFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('⚠️ Please fill in: ${emptyFields.join(", ")}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ));
      return;
    }
    _goToNextStep();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (picked != null) setState(() => userData['dateOfBirth'] = DateFormat('dd MMM, yyyy').format(picked));
  }

  void _addWorkExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Add Work Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildBottomSheetField(label: 'Job Title', controller: _expTitleController, hint: 'e.g., Senior Developer', icon: Icons.work_outline),
                  const SizedBox(height: 16),
                  _buildBottomSheetField(label: 'Company', controller: _expCompanyController, hint: 'Company name', icon: Icons.business),
                  const SizedBox(height: 16),
                  Row(children: [Expanded(child: _buildBottomSheetField(label: 'Location', controller: _expLocationController, hint: 'City', icon: Icons.location_city)), const SizedBox(width: 16), Expanded(child: _buildBottomSheetField(label: 'Country', controller: _expCountryController, hint: 'Country', icon: Icons.public))]),
                  const SizedBox(height: 24),
                  const Text('Employment Period', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildYearDropdown(label: 'Start Year', value: _expStartYear, onChanged: (value) => setStateBottomSheet(() => _expStartYear = value))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildYearDropdown(label: 'End Year', value: _expEndYear, onChanged: (value) => setStateBottomSheet(() { _expEndYear = value; _expCurrentlyWorking = value == 'Present'; }), includePresent: true)),
                  ]),
                  const SizedBox(height: 12),
                  CheckboxListTile(title: const Text('I currently work here'), value: _expCurrentlyWorking, onChanged: (value) => setStateBottomSheet(() { _expCurrentlyWorking = value!; if (value) _expEndYear = 'Present'; }), dense: true),
                  const SizedBox(height: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: TextField(controller: _expDescriptionController, maxLines: 4, decoration: InputDecoration(contentPadding: const EdgeInsets.all(12), border: InputBorder.none, hintText: 'Describe your role...')))]),
                  const SizedBox(height: 32),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {
                    if (_expTitleController.text.isNotEmpty && _expCompanyController.text.isNotEmpty && _expStartYear != null) {
                      setState(() {
                        userData['workExperiences'].add({
                          'title': _expTitleController.text,
                          'company': _expCompanyController.text,
                          'location': _expLocationController.text,
                          'country': _expCountryController.text,
                          'startYear': _expStartYear,
                          'endYear': _expEndYear,
                          'currentlyWorking': _expCurrentlyWorking,
                          'description': _expDescriptionController.text,
                        });
                        _expTitleController.clear();
                        _expCompanyController.clear();
                        _expLocationController.clear();
                        _expCountryController.clear();
                        _expDescriptionController.clear();
                        _expStartYear = null;
                        _expEndYear = null;
                        _expCurrentlyWorking = false;
                      });
                      Navigator.pop(context);
                    }
                  }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Save Experience', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _editWorkExperience(int index) {
    final exp = userData['workExperiences'][index];
    _expTitleController.text = exp['title'] ?? '';
    _expCompanyController.text = exp['company'] ?? '';
    _expLocationController.text = exp['location'] ?? '';
    _expCountryController.text = exp['country'] ?? '';
    _expStartYear = exp['startYear'];
    _expEndYear = exp['endYear'];
    _expCurrentlyWorking = exp['currentlyWorking'] ?? false;
    _expDescriptionController.text = exp['description'] ?? '';
    setState(() => userData['workExperiences'].removeAt(index));
    _addWorkExperience();
  }

  void _addEducation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Add Education', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildBottomSheetField(label: 'School/University', controller: _eduSchoolController, hint: 'e.g., University of Technology', icon: Icons.school),
                  const SizedBox(height: 16),
                  Row(children: [Expanded(child: _buildBottomSheetField(label: 'Degree', controller: _eduDegreeController, hint: 'Bachelor\'s', icon: Icons.school_outlined)), const SizedBox(width: 16), Expanded(child: _buildBottomSheetField(label: 'Field of Study', controller: _eduFieldController, hint: 'Computer Science', icon: Icons.menu_book))]),
                  const SizedBox(height: 24),
                  const Text('Education Period', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildYearDropdown(label: 'Start Year', value: _eduStartYear, onChanged: (value) => setStateBottomSheet(() => _eduStartYear = value))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildYearDropdown(label: 'End Year', value: _eduEndYear, onChanged: (value) => setStateBottomSheet(() { _eduEndYear = value; _eduCurrentlyAttending = value == 'Present'; }), includePresent: true)),
                  ]),
                  const SizedBox(height: 12),
                  CheckboxListTile(title: const Text('I currently attend here'), value: _eduCurrentlyAttending, onChanged: (value) => setStateBottomSheet(() { _eduCurrentlyAttending = value!; if (value) _eduEndYear = 'Present'; }), dense: true),
                  const SizedBox(height: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Description (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: TextField(controller: _eduDescriptionController, maxLines: 4, decoration: InputDecoration(contentPadding: const EdgeInsets.all(12), border: InputBorder.none, hintText: 'Add achievements...')))]),
                  const SizedBox(height: 32),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {
                    if (_eduSchoolController.text.isNotEmpty && _eduDegreeController.text.isNotEmpty && _eduStartYear != null) {
                      setState(() {
                        userData['educations'].add({
                          'school': _eduSchoolController.text,
                          'degree': _eduDegreeController.text,
                          'field': _eduFieldController.text,
                          'startYear': _eduStartYear,
                          'endYear': _eduEndYear,
                          'currentlyAttending': _eduCurrentlyAttending,
                          'description': _eduDescriptionController.text,
                        });
                        _eduSchoolController.clear();
                        _eduDegreeController.clear();
                        _eduFieldController.clear();
                        _eduDescriptionController.clear();
                        _eduStartYear = null;
                        _eduEndYear = null;
                        _eduCurrentlyAttending = false;
                      });
                      Navigator.pop(context);
                    }
                  }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Save Education', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _editEducation(int index) {
    final edu = userData['educations'][index];
    _eduSchoolController.text = edu['school'] ?? '';
    _eduDegreeController.text = edu['degree'] ?? '';
    _eduFieldController.text = edu['field'] ?? '';
    _eduStartYear = edu['startYear'];
    _eduEndYear = edu['endYear'];
    _eduCurrentlyAttending = edu['currentlyAttending'] ?? false;
    _eduDescriptionController.text = edu['description'] ?? '';
    setState(() => userData['educations'].removeAt(index));
    _addEducation();
  }

  Widget _buildBottomSheetField({required String label, required TextEditingController controller, required String hint, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Padding(padding: const EdgeInsets.only(left: 12), child: Icon(icon, size: 20, color: Colors.grey.shade600)),
            Expanded(child: TextField(controller: controller, decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), border: InputBorder.none, hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14)))),
          ]),
        ),
      ],
    );
  }

  Widget _buildYearDropdown({required String label, required String? value, required Function(String?) onChanged, bool includePresent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: _generateYears(includePresent: includePresent).map((year) => DropdownMenuItem(value: year, child: Text(year, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: onChanged,
              isExpanded: true,
              hint: Text('Select year', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _generateYears({bool includePresent = false}) {
    final currentYear = DateTime.now().year;
    final List<String> years = [];
    for (int year = currentYear; year >= 1970; year--) years.add(year.toString());
    if (includePresent) years.insert(0, 'Present');
    return years;
  }

  // ✅ Web and Mobile compatible submit
  void _submitProfile() {
    if (kIsWeb) {
      if (_webPhotoBytes == null) {
        setState(() => _photoError = "Profile photo is required");
        _navigateToStep(9);
        return;
      }
      print("✅ Web: Submitting with photo bytes, length: ${_webPhotoBytes!.length}");
      registerC.registerEmployeeWithPhoto(userData, _webPhotoBytes!).then((ok) {
        if (ok) _goToNextStep();
      });
    } else {
      if (_selectedPhoto == null) {
        setState(() => _photoError = "Profile photo is required");
        _navigateToStep(9);
        return;
      }
      print("✅ Mobile: Submitting with file, path: ${_selectedPhoto!.path}");
      registerC.registerEmployeeWithPhoto(userData, _selectedPhoto!).then((ok) {
        if (ok) _goToNextStep();
      });
    }
  }

  void _navigateToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.jumpToPage(step);
  }

  @override
  void dispose() {
    _skillController.dispose();
    _expTitleController.dispose();
    _expCompanyController.dispose();
    _expLocationController.dispose();
    _expCountryController.dispose();
    _expDescriptionController.dispose();
    _eduSchoolController.dispose();
    _eduDegreeController.dispose();
    _eduFieldController.dispose();
    _eduDescriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}