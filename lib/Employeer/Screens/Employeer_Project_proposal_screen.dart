import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/Employee_home_controller.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/Screens/Employer_Contract_Screen.dart';
import 'package:templink/Employeer/Screens/Employer_Proposal_Detail_Screen.dart';
import 'package:templink/Employeer/Screens/talent_profile.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Employeer/model/talent_model.dart';
import 'package:templink/Utils/colors.dart';

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
  final EmployerProjectsController controller =
      Get.find<EmployerProjectsController>();
  final EmployeeHomeController homeController =
      Get.find<EmployeeHomeController>();

  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  List<String> get _filterOptions {
    final options = ['All'];
    final statuses = widget.project.proposals
        .where((p) => p.status != 'WITHDRAWN')  // ✅ withdrawn status chip bhi hide
        .map((p) => p.displayStatus)
        .toSet()
        .toList();
    options.addAll(statuses);
    return options;
  }
  List<ProjectProposal> get _filteredProposals {
    // ✅ Withdrawn exclude karo
    var filtered = List<ProjectProposal>.from(widget.project.proposals)
        .where((p) => p.status != 'WITHDRAWN')
        .toList();

    // ✅ Agar koi ACCEPTED hai to sirf wohi dikhao
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Proposals',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              widget.project.title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProjectSummary(),
          _buildStatsBar(),
          _buildSearchBar(),
          _buildFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredProposals.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProposals.length,
                    itemBuilder: (context, index) {
                      return _buildProposalCard(_filteredProposals[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                widget.project.title.isNotEmpty
                    ? widget.project.title[0].toUpperCase()
                    : 'P',
                style: TextStyle(
                  fontSize: 16,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money,
                        size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 2),
                    Text(
                      widget.project.displayBudget,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.category_outlined,
                        size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 2),
                    Text(
                      widget.project.category,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
Widget _buildStatsBar() {
    final activeProposals = widget.project.proposals
        .where((p) => p.status != 'WITHDRAWN')
        .toList();

    // ✅ Agar accepted hai to sirf accepted count dikhao
    final hasAccepted = activeProposals.any((p) => p.status == 'ACCEPTED');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: hasAccepted
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatChip('Accepted', 1, Colors.green),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip('Total', activeProposals.length, Colors.blue),
                _buildStatChip(
                    'Pending',
                    activeProposals.where((p) => p.status == 'PENDING').length,
                    Colors.orange),
                _buildStatChip(
                    'Accepted',
                    0,
                    Colors.green),
                _buildStatChip(
                    'Rejected',
                    activeProposals.where((p) => p.status == 'REJECTED').length,
                    Colors.red),
              ],
            ),
    );
  }  Widget _buildStatChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
    );
  }
Widget _buildFilterChips() {
    // ✅ Agar accepted hai to filter chips hide karo
    final hasAccepted = widget.project.proposals
        .where((p) => p.status != 'WITHDRAWN')
        .any((p) => p.status == 'ACCEPTED');

    if (hasAccepted) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
        },
      ),
    );
  }
  Widget _buildProposalCard(ProjectProposal proposal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: primary.withOpacity(0.1),
                    backgroundImage:
                        proposal.employee.employeeProfile.photoUrl.isNotEmpty
                            ? NetworkImage(
                                proposal.employee.employeeProfile.photoUrl)
                            : null,
                    child: proposal.employee.employeeProfile.photoUrl.isEmpty
                        ? Text(
                            proposal.employee.initials,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  final talent = TalentModel(
                                    id: proposal.employee.id,
                                    firstName: proposal.employee.firstName,
                                    lastName: proposal.employee.lastName,
                                    email: proposal.employee.email,
                                    country: proposal.employee.country,
                                    employeeProfile: {
                                      'title': proposal
                                          .employee.employeeProfile.title,
                                      'skills': proposal
                                          .employee.employeeProfile.skills,
                                      'hourlyRate': proposal
                                          .employee.employeeProfile.hourlyRate,
                                      'rating': proposal
                                          .employee.employeeProfile.rating,
                                      'photoUrl': proposal
                                          .employee.employeeProfile.photoUrl,
                                      'bio': proposal
                                          .employee.employeeProfile.bio,
                                      'experienceLevel': proposal.employee
                                          .employeeProfile.experienceLevel,
                                      'category': proposal
                                          .employee.employeeProfile.category,
                                      'portfolioProjects': proposal.employee
                                          .employeeProfile.portfolioProjects,
                                      'workExperiences': proposal.employee
                                          .employeeProfile.workExperiences,
                                      'educations': proposal
                                          .employee.employeeProfile.educations,
                                    },
                                  );
                                  Get.to(() => TalentProfileScreen(talent: talent));
                                },
                                child: Text(
                                  proposal.employee.displayName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    proposal.statusColor.withOpacity(0.1),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (proposal.employee.employeeProfile.title.isNotEmpty)
                          Text(
                            proposal.employee.employeeProfile.title,
                            style: TextStyle(
                              fontSize: 11,
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
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      Text(
                        'Bid Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${proposal.fixedPrice}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),

            // Cover Letter Preview
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Cover Letter',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      proposal.coverLetter.length > 100
                          ? '${proposal.coverLetter.substring(0, 100)}...'
                          : proposal.coverLetter,
                      style: const TextStyle(
                        fontSize: 12,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildMetaInfo(
                    Icons.access_time,
                    'Duration: ${proposal.projectDuration} months',
                  ),
                  const SizedBox(width: 16),
                  _buildMetaInfo(
                    Icons.calendar_today,
                    'Sent ${proposal.displayDate}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildActionButtons(proposal),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ProjectProposal proposal) {
    // ==================== PENDING ====================
    if (proposal.status == 'PENDING') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showRejectDialog(proposal),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showAcceptDialog(proposal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Accept'),
              ),
            ),
          ],
        ),
      );
    }

    // ==================== ACCEPTED ====================
    if (proposal.status == 'ACCEPTED') {
      final hasActiveContract = proposal.hasActiveContract;
      final contractPending = proposal.contractPending;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // View Profile Button
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final talent = TalentModel(
                    id: proposal.employee.id,
                    firstName: proposal.employee.firstName,
                    lastName: proposal.employee.lastName,
                    email: proposal.employee.email,
                    country: proposal.employee.country,
                    employeeProfile: {
                      'title': proposal.employee.employeeProfile.title,
                      'skills': proposal.employee.employeeProfile.skills,
                      'hourlyRate':
                          proposal.employee.employeeProfile.hourlyRate,
                      'rating': proposal.employee.employeeProfile.rating,
                      'photoUrl': proposal.employee.employeeProfile.photoUrl,
                      'bio': proposal.employee.employeeProfile.bio,
                      'experienceLevel':
                          proposal.employee.employeeProfile.experienceLevel,
                      'category': proposal.employee.employeeProfile.category,
                      'portfolioProjects':
                          proposal.employee.employeeProfile.portfolioProjects,
                      'workExperiences':
                          proposal.employee.employeeProfile.workExperiences,
                      'educations':
                          proposal.employee.employeeProfile.educations,
                    },
                  );
                  Get.to(() => TalentProfileScreen(talent: talent));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('View Profile'),
              ),
            ),
            const SizedBox(width: 12),

            // Contract Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (hasActiveContract) {
                    // ✅ Contract ACTIVE - view only
                    Get.to(() => EmployerContractScreen(
                          projectId: widget.project.id,
                          viewOnly: true,
                        ));
                  } else if (contractPending) {
                    // ✅ Contract pending
                    if (proposal.contractStatus == 'PENDING_EMPLOYER_SIGN') {
                      // Employer ne sign nahi kiya abhi
                      Get.to(() => EmployerContractScreen(
                            projectId: widget.project.id,
                            isProposalSigning: true,
                          ));
                    } else if (proposal.contractStatus ==
                        'PENDING_EMPLOYEE_SIGN') {
                      // Employer ne sign kar diya, employee ka wait
                      // View only dikhao
                      Get.to(() => EmployerContractScreen(
                            projectId: widget.project.id,
                            viewOnly: true,
                          ));
                    } else {
                      // DRAFT ya koi aur - signing flow
                      Get.to(() => EmployerContractScreen(
                            projectId: widget.project.id,
                            isProposalSigning: true,
                          ));
                    }
                  } else {
                    // ✅ Koi contract nahi - naya signing flow
                    Get.to(() => EmployerContractScreen(
                          projectId: widget.project.id,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _getContractButtonText(proposal),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ==================== REJECTED ====================
    if (proposal.status == 'REJECTED') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('View Feedback'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getContractButtonText(ProjectProposal proposal) {
    if (proposal.hasActiveContract) {
      return 'View Contract';
    } else if (proposal.contractStatus == 'PENDING_EMPLOYEE_SIGN') {
      return 'Waiting Employee';
    } else if (proposal.contractStatus == 'PENDING_EMPLOYER_SIGN') {
      return 'Sign Proposal';
    } else if (proposal.contractStatus == 'DRAFT') {
      return 'Sign Proposal';
    } else if (proposal.hasContract) {
      return 'Complete Signing';
    }
    return 'View Contract';
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty
                  ? Icons.search_off
                  : Icons.inbox,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No matching proposals'
                  : 'No proposals yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try different search keywords'
                  : 'When freelancers submit proposals, they will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
        title: const Text('Accept Proposal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to accept ${proposal.employee.firstName}\'s proposal?',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bid Amount:',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$${proposal.fixedPrice}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Duration:',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${proposal.projectDuration} months',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Accepting this proposal will:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Mark other proposals as rejected',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Generate contract automatically',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Start hiring process',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isAccepting.value
                  ? null
                  : () async {
                      await controller.acceptProposal(proposal.id);
                      Navigator.pop(context);

                      // ✅ Naya proposal accept kiya - signing flow
                      Get.to(() => EmployerContractScreen(
                            projectId: widget.project.id,
                            isProposalSigning: true,
                          ));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: controller.isAccepting.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Accept & Sign Proposal'),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(ProjectProposal proposal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Proposal'),
        content: Text(
          'Are you sure you want to reject ${proposal.employee.firstName}\'s proposal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}