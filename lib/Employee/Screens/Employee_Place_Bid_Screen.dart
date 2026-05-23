import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/proposal_controller.dart';
import 'package:templink/Employee/Controllers/Employee_home_controller.dart';
import 'package:templink/Employee/models/project_model.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Models/proposals_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SubmitProposalScreen extends StatefulWidget {
  final ProjectFeedModel project;
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const SubmitProposalScreen({
    Key? key, 
    required this.project,
    this.onBackPressed,
    this.showSidebar = true,
  }) : super(key: key);

  @override
  State<SubmitProposalScreen> createState() => _SubmitProposalScreenState();
}

class _SubmitProposalScreenState extends State<SubmitProposalScreen> {
  final ProposalController proposalController = Get.put(ProposalController());
  final EmployeeHomeController homeController = Get.find<EmployeeHomeController>();
  
  int _projectDuration = 2;
  double _fixedPrice = 0.0;
  final TextEditingController _coverLetterController = TextEditingController();
  List<AttachedFile> _attachedFiles = [];
  List<PortfolioProject> _selectedPortfolioProjects = [];
  List<PortfolioProject> _availablePortfolioProjects = [];
  
  bool _isLoading = false;
  bool _isLoadingPortfolio = true;
  bool _sidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadPortfolioProjects();
  }

  Future<void> _loadPortfolioProjects() async {
    setState(() => _isLoadingPortfolio = true);
    final projects = await proposalController.getPortfolioProjects();
    setState(() {
      _availablePortfolioProjects = projects;
      _isLoadingPortfolio = false;
    });
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  double get _serviceFee => _fixedPrice * 0.20;
  double get _youWillReceive => _fixedPrice - _serviceFee;
@override
Widget build(BuildContext context) {
  Responsive.init(context);
  final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);

  if (isWeb && widget.showSidebar) {
    final isDesktop = Responsive.isDesktop(context);
    final sidebarW = _sidebarExpanded ? (isDesktop ? 260.0 : 220.0) : 72.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: sidebarW,
            child: _buildWebSidebar(sidebarW),
          ),
          Expanded(
            child: Column(
              children: [
                _buildWebTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  return Scaffold(
    backgroundColor: isWeb ? const Color(0xFFF5F7FA) : Colors.grey.shade50,
    appBar: isWeb ? null : AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          if (widget.onBackPressed != null) {
            widget.onBackPressed!();
          } else {
            Get.back();
          }
        },
      ),
      title: const Text(
        "Submit a Proposal",
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    body: isWeb 
        ? Column(
            children: [
              _buildWebTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildBody(),
                ),
              ),
            ],
          )
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildBody(),
            ),
          ),
  );
}  // ==================== WEB TOP BAR ====================
  Widget _buildWebTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.onBackPressed != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: widget.onBackPressed,
            ),
          const Expanded(
            child: Text(
              "Submit a Proposal",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () {
              if (widget.onBackPressed != null) {
                widget.onBackPressed!();
              } else {
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }

  // ==================== WEB SIDEBAR ====================
  Widget _buildWebSidebar(double width) {
    final expanded = _sidebarExpanded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.work_outline,
                      color: Colors.white, size: 18),
                ),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  const Text(
                    'Templink',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
                    child: Icon(Icons.menu,
                        size: 20, color: Colors.grey.shade600),
                  ),
                ] else ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
                    child: Icon(Icons.menu,
                        size: 20, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),

          if (expanded)
            Obx(() => Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          homeController.imageUrl.value.isNotEmpty
                              ? homeController.imageUrl.value
                              : 'https://i.pravatar.cc/300?img=11',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 36,
                            height: 36,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              homeController.fullName.value,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Free Account',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),

          if (!expanded) const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                _webNavItem(Icons.home_outlined, Icons.home, 'Home', expanded, () {
                  if (widget.onBackPressed != null) widget.onBackPressed!();
                }),
                _webNavItem(Icons.message_outlined, Icons.message, 'Messages', expanded, () {}),
                _webNavItem(Icons.description_outlined, Icons.description, 'My Proposals', expanded, () {}),
                _webNavItem(Icons.search_outlined, Icons.search, 'Search', expanded, () {}),
                _webNavItem(Icons.person_outline, Icons.person, 'Profile', expanded, () {}),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(height: 1),
                ),
                _webNavItem(Icons.dashboard, Icons.dashboard, 'Active Projects', expanded, () {}),
                _webNavItem(Icons.bar_chart_outlined, Icons.bar_chart, 'My Stats', expanded, () {}),
                _webNavItem(Icons.description_outlined, Icons.description, 'Resume Builder', expanded, () {}),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey.shade100, width: 1)),
            ),
            child: _webLogoutTile(expanded),
          ),
        ],
      ),
    );
  }

  Widget _webNavItem(IconData icon, IconData activeIcon, String label, bool expanded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? 12 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            if (expanded) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _webLogoutTile(bool expanded) {
    return GestureDetector(
      onTap: () {
        Get.offAll(() => const LoginScreen());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? 12 : 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade400, size: 20),
            if (expanded) ...[
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== BODY (Shared) ====================
  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Points info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This proposal requires 13 points",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                  children: [
                    const TextSpan(text: "When you submit this proposal, you will have "),
                    TextSpan(
                      text: "21 points remaining",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const TextSpan(text: "."),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Project Details
        const Text(
          "Project Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.project.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.project.description ?? 'Project description will appear here...',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Fixed Price Section
        const Text(
          "Fixed Price Proposal",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildFixedPriceSection(),
        
        const SizedBox(height: 24),
        
        // Duration
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "How long will this project take?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _durationChip('1 month', 1),
                  _durationChip('2 months', 2),
                  _durationChip('3 months', 3),
                  _durationChip('4 months', 4),
                  _durationChip('5 months', 5),
                  _durationChip('6+ months', 6),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Cover Letter
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cover Letter",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Introduce yourself and explain why you're the best fit for this project",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _coverLetterController,
                  maxLines: null,
                  expands: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Write your cover letter here...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Attach Files
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Attach Files (Optional)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Add relevant documents like portfolio, resume, or previous work samples",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              
              if (_attachedFiles.isNotEmpty)
                Column(
                  children: [
                    ..._attachedFiles.map((file) => _attachedFileItem(file)).toList(),
                    const SizedBox(height: 12),
                  ],
                ),
              
              OutlinedButton.icon(
                onPressed: _attachFile,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.attach_file, size: 20),
                label: const Text(
                  "Add File",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Portfolio Projects
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Portfolio Projects",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Select projects from your portfolio to showcase relevant work",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              
              if (_isLoadingPortfolio)
                const Center(child: CircularProgressIndicator())
              else
                _buildPortfolioSelection(),
              
              if (_selectedPortfolioProjects.isNotEmpty)
                _buildSelectedProjectsList(),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              const Text(
                "Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              _summaryRow("Proposal Type", "Fixed Price"),
              const SizedBox(height: 8),
              _summaryRow("Project Duration", "$_projectDuration months"),
              const SizedBox(height: 8),
              if (_selectedPortfolioProjects.isNotEmpty)
                Column(
                  children: [
                    _summaryRow("Portfolio Projects", "${_selectedPortfolioProjects.length} selected"),
                    const SizedBox(height: 8),
                  ],
                ),
              _summaryRow("Total Amount", "\$${_fixedPrice.toStringAsFixed(2)}"),
              const SizedBox(height: 8),
              _summaryRow("Service Fee (20%)", "\$${_serviceFee.toStringAsFixed(2)}"),
              const SizedBox(height: 8),
              _summaryRow("You'll Receive", "\$${_youWillReceive.toStringAsFixed(2)}"),
              const Divider(height: 24, thickness: 1),
              _summaryRow(
                "Required Points",
                "13 points",
                isTotal: true,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Submit Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (widget.onBackPressed != null) {
                    widget.onBackPressed!();
                  } else {
                    Get.back();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => ElevatedButton(
                onPressed: (proposalController.isLoading.value || _fixedPrice <= 0 || _coverLetterController.text.isEmpty)
                    ? null
                    : _submitProposal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: proposalController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Send for 13 points",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFixedPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Project Price",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Total fixed price for the complete project",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Text(
                      "\$",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _fixedPrice = double.tryParse(value) ?? 0.0;
                          });
                        },
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "${widget.project.minBudget} - ${widget.project.maxBudget}",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildPaymentSummary(),
      ],
    );
  }

  Widget _buildPortfolioSelection() {
    return Column(
      children: _availablePortfolioProjects.map((project) {
        final isSelected = _selectedPortfolioProjects.any((p) => p.portfolioId == project.portfolioId);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedPortfolioProjects.add(project);
                } else {
                  _selectedPortfolioProjects.removeWhere(
                    (p) => p.portfolioId == project.portfolioId
                  );
                }
              });
            },
            title: Text(
              project.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            secondary: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: project.imageUrl.isNotEmpty
                  ? Image.network(
                      project.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, color: Colors.grey);
                      },
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedProjectsList() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selected Projects:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ..._selectedPortfolioProjects.map((project) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() {
                      _selectedPortfolioProjects.remove(project);
                    });
                  },
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Service fee (20%)",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "\$${_serviceFee.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "You'll receive",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "\$${_youWillReceive.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _durationChip(String label, int months) {
    final isSelected = _projectDuration == months;
    
    return GestureDetector(
      onTap: () => setState(() => _projectDuration = months),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _attachedFileItem(AttachedFile file) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            color: primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Uploaded",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() {
                _attachedFiles.remove(file);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _attachFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        String? fileUrl = await proposalController.uploadFile(
          file.path!,
          file.name,
        );

        Get.back();

        if (fileUrl != null) {
          setState(() {
            _attachedFiles.add(AttachedFile(
              fileName: file.name,
              fileUrl: fileUrl,
            ));
          });

          Get.snackbar(
            'Success',
            'File uploaded successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _submitProposal() async {
    if (_coverLetterController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please write a cover letter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (_fixedPrice <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid fixed price',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final proposal = ProposalRequest(
      projectId: widget.project.id,
      coverLetter: _coverLetterController.text,
      paymentMethod: 'fixed',
      fixedPrice: _fixedPrice,
      projectDuration: _projectDuration,
      attachedFiles: _attachedFiles,
      selectedPortfolioProjects: _selectedPortfolioProjects,
    );

    bool success = await proposalController.submitProposal(proposal);

    if (success) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Proposal Submitted!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              "Your proposal has been successfully submitted.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.project.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Total: \$${_fixedPrice.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_selectedPortfolioProjects.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "${_selectedPortfolioProjects.length} portfolio project(s) included",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              "13 points deducted",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              if (widget.onBackPressed != null) {
                widget.onBackPressed!();
              } else {
                Get.back(); // Go back to previous screen
              }
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}