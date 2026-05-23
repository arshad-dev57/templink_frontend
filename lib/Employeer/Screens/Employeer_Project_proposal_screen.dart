import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Controllers/Employee_home_controller.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/Controller/employer_proposals_projects_controller.dart';
import 'package:templink/Employeer/Screens/Employer_Contract_Screen.dart';
import 'package:templink/Employeer/Screens/Employer_Proposal_Detail_Screen.dart';
import 'package:templink/Employeer/Screens/talent_profile.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Employeer/model/talent_model.dart' as talent;
import 'package:templink/Global_Screens/Chat_Screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:templink/config/api_config.dart';

class ProjectProposalsScreen extends StatefulWidget {
  final EmployerProject project;

  const ProjectProposalsScreen({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<ProjectProposalsScreen> createState() => _ProjectProposalsScreenState();
}

class _ProjectProposalsScreenState extends State<ProjectProposalsScreen> {
  final EmployerProposalsProjectsController controller =
      Get.find<EmployerProposalsProjectsController>();
  final EmployeeHomeController homeController =
      Get.find<EmployeeHomeController>();

  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  List<String> get _filterOptions {
    final options = ['All'];
    final statuses = widget.project.proposals
        .where((p) => p.status != 'WITHDRAWN')
        .map((p) => p.displayStatus)
        .toSet()
        .toList();
    options.addAll(statuses);
    return options;
  }

  List<ProjectProposal> get _filteredProposals {
    var filtered = List<ProjectProposal>.from(widget.project.proposals)
        .where((p) => p.status != 'WITHDRAWN')
        .toList();

    final hasAccepted = filtered.any((p) => p.status == 'ACCEPTED');
    if (hasAccepted) {
      filtered = filtered.where((p) => p.status == 'ACCEPTED').toList();
    }

    if (_selectedFilter != 'All') {
      filtered =
          filtered.where((p) => p.displayStatus == _selectedFilter).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((p) {
        return p.employee.displayName.toLowerCase().contains(query) ||
            p.employee.email.toLowerCase().contains(query) ||
            p.coverLetter.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isWeb = isDesktop || isTablet;

    if (isWeb) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  // ==================== WEB LAYOUT ====================
  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildWebAppBar(),
          Expanded(
            child: _buildWebContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebAppBar() {
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Proposals',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.project.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          // IconButton(
          //   icon: const Icon(Icons.refresh, color: Colors.black87),
          //   onPressed: () {
          //     // controller.fetchProjectDetails(widget.project.id);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildWebContent() {
    final hasAccepted = widget.project.proposals
        .where((p) => p.status != 'WITHDRAWN')
        .any((p) => p.status == 'ACCEPTED');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Sidebar - Summary
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWebProjectSummary(),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildWebStatsBar(hasAccepted),
              ],
            ),
          ),
        ),
        // Right Content - Proposals List
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildWebSearchAndFilter(),
              Expanded(
                child: _filteredProposals.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredProposals.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildProposalCardWeb(_filteredProposals[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebProjectSummary() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              widget.project.title.isNotEmpty
                  ? widget.project.title[0].toUpperCase()
                  : 'P',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _buildWebMetaInfo(Icons.attach_money, widget.project.displayBudget),
                  _buildWebMetaInfo(Icons.category_outlined, widget.project.category),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildWebStatsBar(bool hasAccepted) {
    final activeProposals = widget.project.proposals
        .where((p) => p.status != 'WITHDRAWN')
        .toList();

    if (hasAccepted) {
      return Column(
        children: [
          const Text(
            'Proposal Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Accepted',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildWebStatItem('Total', activeProposals.length, Colors.blue),
        const SizedBox(height: 8),
        _buildWebStatItem(
          'Pending',
          activeProposals.where((p) => p.status == 'PENDING').length,
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildWebStatItem('Accepted', 0, Colors.green),
        const SizedBox(height: 8),
        _buildWebStatItem(
          'Rejected',
          activeProposals.where((p) => p.status == 'REJECTED').length,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildWebStatItem(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebSearchAndFilter() {
    final hasAccepted = widget.project.proposals
        .where((p) => p.status != 'WITHDRAWN')
        .any((p) => p.status == 'ACCEPTED');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 2,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
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
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by name, email, or proposal...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Filter Chips (if no accepted proposal)
          if (!hasAccepted)
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    final count = filter == 'All'
                        ? widget.project.proposals
                            .where((p) => p.status != 'WITHDRAWN')
                            .length
                        : widget.project.proposals
                            .where((p) => p.displayStatus == filter && p.status != 'WITHDRAWN')
                            .length;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? primary : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? primary : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Web Proposal Card
  Widget _buildProposalCardWeb(ProjectProposal proposal) {
    return InkWell(
      onTap: () {
        Get.to(() => ProposalDetailScreen(
                proposal: proposal,
                project: widget.project,
              ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: primary.withOpacity(0.1),
                    backgroundImage:
                        proposal.employee.employeeProfile.photoUrl.isNotEmpty
                            ? NetworkImage(proposal.employee.employeeProfile.photoUrl)
                            : null,
                    child: proposal.employee.employeeProfile.photoUrl.isEmpty
                        ? Text(
                            proposal.employee.initials,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                
                                // onTap: () => _navigateToTalentProfile(proposal),
                                child: Text(
                                  proposal.employee.displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: proposal.statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                proposal.displayStatus,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: proposal.statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proposal.employee.email,
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                        ),
                        if (proposal.employee.employeeProfile.title.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            proposal.employee.employeeProfile.title,
                            style: const TextStyle(fontSize: 11, color: Colors.black),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Bid Amount
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.attach_money, color: primary, size: 18),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Bid Amount',
                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${proposal.fixedPrice}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Cover Letter Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  proposal.coverLetter.length > 150
                      ? '${proposal.coverLetter.substring(0, 150)}...'
                      : proposal.coverLetter,
                  style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Meta Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildWebMetaInfo(Icons.access_time, 'Duration: ${proposal.projectDuration} months'),
                  _buildWebMetaInfo(Icons.calendar_today, 'Sent ${proposal.displayDate}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            _buildActionButtonsWeb(proposal),
          ],
        ),
      ),
    );
  }

Widget _buildActionButtonsWeb(ProjectProposal proposal) {
  // PENDING
  if (proposal.status == 'PENDING') {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openChat(proposal),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Message'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showRejectDialog(proposal),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showAcceptDialog(proposal),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Accept'),
            ),
          ),
        ],
      ),
    );
  }

  // ACCEPTED
  if (proposal.status == 'ACCEPTED') {
    final hasActiveContract = proposal.hasActiveContract;
    final contractPending = proposal.contractPending;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _navigateToTalentProfile(proposal),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Profile'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openChat(proposal),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Message'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (hasActiveContract) {
                  // View Contract - viewOnly true, isProposalSigning false
                  Get.to(() => EmployerContractScreen(
                        projectId: widget.project.id,
                        contractId: proposal.contractId,
                        viewOnly: true,
                        isProposalSigning: false,
                      ));
                } else if (contractPending) {
                  if (proposal.contractStatus == 'PENDING_EMPLOYER_SIGN') {
                    Get.to(() => EmployerContractScreen(
                          projectId: widget.project.id,
                          contractId: proposal.contractId,
                          viewOnly: false,
                          isProposalSigning: true,
                        ));
                  } else if (proposal.contractStatus == 'PENDING_EMPLOYEE_SIGN') {
                    Get.to(() => EmployerContractScreen(
                          projectId: widget.project.id,
                          contractId: proposal.contractId,
                          viewOnly: true,
                          isProposalSigning: false,
                        ));
                  } else {
                    Get.to(() => EmployerContractScreen(
                          projectId: widget.project.id,
                          contractId: proposal.contractId,
                          viewOnly: false,
                          isProposalSigning: true,
                        ));
                  }
                } else {
                  Get.to(() => EmployerContractScreen(
                        projectId: widget.project.id,
                        contractId: proposal.contractId,
                        viewOnly: false,
                        isProposalSigning: true,
                      ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasActiveContract
                    ? Colors.blue
                    : contractPending
                        ? Colors.orange
                        : primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_getContractButtonText(proposal)),
            ),
          ),
        ],
      ),
    );
  }

  // REJECTED
  if (proposal.status == 'REJECTED') {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openChat(proposal),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Message'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Feedback'),
            ),
          ),
        ],
      ),
    );
  }

  return const SizedBox.shrink();
}  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    final hasAccepted = widget.project.proposals
        .where((p) => p.status != 'WITHDRAWN')
        .any((p) => p.status == 'ACCEPTED');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 22.sp, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proposals',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
            Text(
              widget.project.title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProjectSummaryMobile(),
          _buildStatsBarMobile(hasAccepted),
          _buildSearchBarMobile(),
          if (!hasAccepted) _buildFilterChipsMobile(),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredProposals.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _filteredProposals.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildProposalCardMobile(_filteredProposals[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSummaryMobile() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                widget.project.title.isNotEmpty
                    ? widget.project.title[0].toUpperCase()
                    : 'P',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 12.w,
                  runSpacing: 4.h,
                  children: [
                    _buildMobileMetaInfo(Icons.attach_money, widget.project.displayBudget),
                    _buildMobileMetaInfo(Icons.category_outlined, widget.project.category),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: Colors.grey.shade600),
        SizedBox(width: 2.w),
        Text(
          text,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatsBarMobile(bool hasAccepted) {
    final activeProposals = widget.project.proposals
        .where((p) => p.status != 'WITHDRAWN')
        .toList();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: hasAccepted
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMobileStatChip('Accepted', 1, Colors.green),
              ],
            )
          : Wrap(
              spacing: 16.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.spaceAround,
              children: [
                _buildMobileStatChip('Total', activeProposals.length, Colors.blue),
                _buildMobileStatChip(
                  'Pending',
                  activeProposals.where((p) => p.status == 'PENDING').length,
                  Colors.orange,
                ),
                _buildMobileStatChip('Accepted', 0, Colors.green),
                _buildMobileStatChip(
                  'Rejected',
                  activeProposals.where((p) => p.status == 'REJECTED').length,
                  Colors.red,
                ),
              ],
            ),
    );
  }

  Widget _buildMobileStatChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarMobile() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Icon(Icons.search, color: Colors.grey, size: 20.sp),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by name, email, or proposal...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipsMobile() {
    return Container(
      color: Colors.white,
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;
          final count = filter == 'All'
              ? widget.project.proposals
                  .where((p) => p.status != 'WITHDRAWN')
                  .length
              : widget.project.proposals
                  .where((p) => p.displayStatus == filter && p.status != 'WITHDRAWN')
                  .length;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? primary : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
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

  Widget _buildProposalCardMobile(ProjectProposal proposal) {
    // Same as original _buildProposalCard but with responsive spacing
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => ProposalDetailScreen(
                proposal: proposal,
                project: widget.project,
              ));
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25.r,
                    backgroundColor: primary.withOpacity(0.1),
                    backgroundImage:
                        proposal.employee.employeeProfile.photoUrl.isNotEmpty
                            ? NetworkImage(proposal.employee.employeeProfile.photoUrl)
                            : null,
                    child: proposal.employee.employeeProfile.photoUrl.isEmpty
                        ? Text(
                            proposal.employee.initials,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _navigateToTalentProfile(proposal),
                                child: Text(
                                  proposal.employee.displayName,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: proposal.statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                proposal.displayStatus,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: proposal.statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          proposal.employee.email,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        if (proposal.employee.employeeProfile.title.isNotEmpty)
                          Text(
                            proposal.employee.employeeProfile.title,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bid Amount
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: primary, size: 18.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Bid Amount',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${proposal.fixedPrice}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
            // Cover Letter Preview
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description_outlined, size: 14.sp, color: Colors.grey.shade600),
                      SizedBox(width: 4.w),
                      Text(
                        'Cover Letter',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      proposal.coverLetter.length > 100
                          ? '${proposal.coverLetter.substring(0, 100)}...'
                          : proposal.coverLetter,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Meta Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 16.w,
                runSpacing: 8.h,
                children: [
                  _buildMobileMetaInfo(Icons.access_time, 'Duration: ${proposal.projectDuration} months'),
                  _buildMobileMetaInfo(Icons.calendar_today, 'Sent ${proposal.displayDate}'),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _buildActionButtonsMobile(proposal),
          ],
        ),
      ),
    );
  }
Widget _buildActionButtonsMobile(ProjectProposal proposal) {
  if (proposal.status == 'PENDING') {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openChat(proposal),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('Message', style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(proposal),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Reject', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAcceptDialog(proposal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Accept', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  if (proposal.status == 'ACCEPTED') {
    final hasActiveContract = proposal.hasActiveContract;
    final contractPending = proposal.contractPending;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _navigateToTalentProfile(proposal),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text('View Profile', style: TextStyle(fontSize: 14.sp)),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openChat(proposal),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('Message', style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (hasActiveContract) {
                  // View Contract - viewOnly true, isProposalSigning false
                  Get.to(() => EmployerContractScreen(
                        projectId: widget.project.id,
                        contractId: proposal.contractId,
                        viewOnly: true,
                        isProposalSigning: false,
                      ));
                } else if (contractPending) {
                  if (proposal.contractStatus == 'PENDING_EMPLOYER_SIGN') {
                    Get.to(() => EmployerContractScreen(
                          projectId: widget.project.id,
                          contractId: proposal.contractId,
                          viewOnly: false,
                          isProposalSigning: true,
                        ));
                  } else if (proposal.contractStatus == 'PENDING_EMPLOYEE_SIGN') {
                    Get.to(() => EmployerContractScreen(
                          projectId: widget.project.id,
                          contractId: proposal.contractId,
                          viewOnly: true,
                          isProposalSigning: false,
                        ));
                  } else {
                    Get.to(() => EmployerContractScreen(
                          projectId: widget.project.id,
                          contractId: proposal.contractId,
                          viewOnly: false,
                          isProposalSigning: true,
                        ));
                  }
                } else {
                  Get.to(() => EmployerContractScreen(
                        projectId: widget.project.id,
                        contractId: proposal.contractId,
                        viewOnly: false,
                        isProposalSigning: true,
                      ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasActiveContract
                    ? Colors.blue
                    : contractPending
                        ? Colors.orange
                        : primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                _getContractButtonText(proposal),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  if (proposal.status == 'REJECTED') {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openChat(proposal),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('Message', style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text('View Feedback', style: TextStyle(fontSize: 14.sp)),
            ),
          ),
        ],
      ),
    );
  }

  return const SizedBox.shrink();
}
  // ==================== HELPER METHODS ====================
  void _navigateToTalentProfile(ProjectProposal proposal) {
    final talentModel = talent.TalentModel(
      id: proposal.employee.id,
      firstName: proposal.employee.firstName,
      lastName: proposal.employee.lastName,
      email: proposal.employee.email,
      country: proposal.employee.country,
      createdAt: null,
      title: proposal.employee.employeeProfile.title,
      bio: proposal.employee.employeeProfile.bio,
      skills: proposal.employee.employeeProfile.skills,
      experienceLevel: proposal.employee.employeeProfile.experienceLevel,
      category: proposal.employee.employeeProfile.category,
      hourlyRate: proposal.employee.employeeProfile.hourlyRate,
      photoUrl: proposal.employee.employeeProfile.photoUrl,
      rating: proposal.employee.employeeProfile.rating,
      totalReviews: proposal.employee.employeeProfile.totalReviews,
      availability: proposal.employee.employeeProfile.availability,
      workExperiences: proposal.employee.employeeProfile.workExperiences,
      educations: proposal.employee.employeeProfile.educations,
      portfolioProjects: proposal.employee.employeeProfile.portfolioProjects.map((project) => talent.PortfolioProject.fromJson({
        'title': project.title,
        'description': project.description,
        'imageUrl': project.imageUrl,
        'category': '',
        'completionDate': project.completionDate,
        'clientName': '',
        'projectUrl': '',
      })).toList(),
    );
    Get.to(() => TalentProfileScreen(talent: talentModel));
  }

  void _openChat(ProjectProposal proposal) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final myUserId = prefs.getString('auth_user_id') ?? '';
      final myToken = prefs.getString('auth_token') ?? '';
      final userJson = prefs.getString('auth_user');

      String myName = 'You';
      if (userJson != null) {
        try {
          final userData = jsonDecode(userJson);
          myName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
          if (myName.isEmpty) myName = 'You';
        } catch (e) {
          myName = 'You';
        }
      }

      if (Get.isDialogOpen ?? false) Get.back();

      if (myUserId.isEmpty) {
        Get.snackbar('Error', 'You are not logged in. Please login first.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (myToken.isEmpty) {
        Get.snackbar('Error', 'Authentication failed. Please login again.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (proposal.employee.id.isEmpty) {
        Get.snackbar('Error', 'Talent information is incomplete.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      Get.to(() => ChatScreen(
            userName: proposal.employee.displayName,
            userOnline: false,
            toUserId: proposal.employee.id,
            baseUrl: ApiConfig.baseUrl,
            myToken: myToken,
            myUserId: myUserId,
          ));
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Failed to open chat: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  String _getContractButtonText(ProjectProposal proposal) {
      print('DEBUG: contractId=${proposal.contractId}, contractStatus=${proposal.contractStatus}, hasContract=${proposal.hasContract}');

  if (proposal.hasActiveContract) {
    return 'View Contract';
  } else if (proposal.contractStatus == 'PENDING_EMPLOYEE_SIGN') {
    return 'Waiting Employee';
  } else if (proposal.contractStatus == 'PENDING_EMPLOYER_SIGN') {
    return 'Sign Proposal';
  } else if (proposal.contractStatus == 'DRAFT') {
    return 'Sign Proposal';
  } else if (proposal.contractStatus == 'COMPLETED') {
    return 'View Contract';
  } else if (proposal.hasContract) {
    // Has contractId but unknown status — treat as needing to sign
    return 'Sign Proposal'; // or 'View Contract' depending on your preference
  }
  // No contract at all — start the process
  return 'Create Contract';
}
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty ? Icons.search_off : Icons.inbox,
              size: 80.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 20.h),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No matching proposals'
                  : 'No proposals yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try different search keywords'
                  : 'When freelancers submit proposals, they will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDialog(ProjectProposal proposal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accept Proposal', style: TextStyle(fontSize: 18.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to accept ${proposal.employee.firstName}\'s proposal?',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bid Amount:', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
                      Text('\$${proposal.fixedPrice}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: primary)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Duration:', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
                      Text('${proposal.projectDuration} months', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text('Accepting this proposal will:', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            _buildInfoRow(Icons.check_circle, 'Mark other proposals as rejected', Colors.green.shade600),
            _buildInfoRow(Icons.check_circle, 'Generate contract automatically', Colors.green.shade600),
            _buildInfoRow(Icons.check_circle, 'Start hiring process', Colors.green.shade600),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(fontSize: 14.sp))),
          Obx(() => ElevatedButton(
            onPressed: controller.isAccepting.value
                ? null
                : () async {
                    await controller.acceptProposal(proposal.id);
                    Navigator.pop(context);
                    Get.to(() => EmployerContractScreen(
                          projectId: widget.project.id,
                          isProposalSigning: true,
                        ));
                  },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: controller.isAccepting.value
                ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Accept & Sign Proposal', style: TextStyle(fontSize: 14.sp)),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.sp))),
        ],
      ),
    );
  }

  void _showRejectDialog(ProjectProposal proposal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Proposal', style: TextStyle(fontSize: 18.sp)),
        content: Text(
          'Are you sure you want to reject ${proposal.employee.firstName}\'s proposal?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(fontSize: 14.sp))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('Reject', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}