// lib/Employer/screens/employer_interested_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:templink/Employeer/Controller/employer_interest_controller.dart';
import 'package:templink/Employeer/model/employer_interest_model.dart';
import 'package:templink/Global_Screens/Chat_Screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:templink/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployerInterestedScreen extends StatefulWidget {
  const EmployerInterestedScreen({Key? key}) : super(key: key);

  @override
  State<EmployerInterestedScreen> createState() => _EmployerInterestedScreenState();
}

class _EmployerInterestedScreenState extends State<EmployerInterestedScreen>
    with SingleTickerProviderStateMixin {
  final EmployerInterestController controller = Get.put(EmployerInterestController());
  late TabController _tabController;
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            _selectedStatusFilter = 'all';
            break;
          case 1:
            _selectedStatusFilter = 'pending';
            break;
          case 2:
            _selectedStatusFilter = 'interested';
            break;
          case 3:
            _selectedStatusFilter = 'hired';
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          _buildWebTopBar(),
          Expanded(
            child: _buildWebContent(),
          ),
        ],
      ),
    );
  }

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
          const Text(
            'Candidates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  '\$${controller.walletBalance.value.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWebContent() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: primary,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null) {
          return _buildErrorWidget();
        }

        // ✅ Always show sidebar, even when no data
        return Row(
          children: [
            // Left sidebar - Status filter (ALWAYS VISIBLE)
            Expanded(
              flex: 1,
              child: _buildWebFiltersSidebar(),
            ),
            // Right content - Candidates list or empty state
            Expanded(
              flex: 2,
              child: _buildWebRightContent(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildWebRightContent() {
    if (controller.allCandidates.isEmpty) {
      return _buildEmptyState();
    }

    final filteredCandidates = _getFilteredCandidates();

    if (filteredCandidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_alt_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No ${_getStatusDisplayName(_selectedStatusFilter)} candidates',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedStatusFilter = 'all';
                  _tabController.animateTo(0);
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear Filter',
                style: TextStyle(color: primary),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCandidates.length,
      itemBuilder: (context, index) {
        final candidate = filteredCandidates[index];
        return _buildCandidateCardWeb(candidate);
      },
    );
  }

  Widget _buildWebFiltersSidebar() {
    // Get counts for each status
    final counts = controller.allCandidates;
    final pendingCount = counts.where((c) => c.status == 'pending').length;
    final interestedCount = counts.where((c) => c.status == 'interested').length;
    final hiredCount = counts.where((c) => c.status == 'hired').length;
    final totalCount = counts.length;

    return Container(
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
          const Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusFilterChip('All ($totalCount)', 'all', Icons.apps),
          const SizedBox(height: 8),
          _buildStatusFilterChip('Pending ($pendingCount)', 'pending', Icons.pending_actions),
          const SizedBox(height: 8),
          _buildStatusFilterChip('Interested ($interestedCount)', 'interested', Icons.check_circle_outline),
          const SizedBox(height: 8),
          _buildStatusFilterChip('Hired ($hiredCount)', 'hired', Icons.work),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedStatusFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusFilter = value;
          // Update tab controller index to match
          switch (value) {
            case 'all':
              _tabController.animateTo(0);
              break;
            case 'pending':
              _tabController.animateTo(1);
              break;
            case 'interested':
              _tabController.animateTo(2);
              break;
            case 'hired':
              _tabController.animateTo(3);
              break;
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? primary : Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? primary : Colors.grey.shade700,
                ),
              ),
            ),
            if (isSelected) ...[
              Icon(Icons.check_circle, size: 14, color: primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWebCandidatesList(List<EmployerInterestModel> candidates) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        return _buildCandidateCardWeb(candidate);
      },
    );
  }

  List<EmployerInterestModel> _getFilteredCandidates() {
    if (_selectedStatusFilter == 'all') {
      return controller.allCandidates;
    }
    return controller.allCandidates
        .where((c) => c.status == _selectedStatusFilter)
        .toList();
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'interested': return 'Interested';
      case 'declined': return 'Declined';
      case 'hired': return 'Hired';
      default: return '';
    }
  }
// Web Candidate Card - Updated status display
Widget _buildCandidateCardWeb(EmployerInterestModel candidate) {
  final commissionAmount = candidate.salaryAmount * 0.2;
  final status = candidate.status;

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
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
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
              image: candidate.employeePhoto.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(candidate.employeePhoto),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: candidate.employeePhoto.isEmpty
                ? Center(
                    child: Text(
                      candidate.employeeName.isNotEmpty
                          ? candidate.employeeName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 20),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate.employeeName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            candidate.employeeTitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 16),

                // Job Details Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Position',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            candidate.jobTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        candidate.formattedSalary,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Message
                if (candidate.message.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.message_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            candidate.message,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Commission Info - only show for interested (not for pending, hired, declined)
                if (status == 'interested')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade800, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Platform Fee (20%)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Commission: \$${commissionAmount.toStringAsFixed(0)} will be deducted',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(candidate, commissionAmount, isWeb: true),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.pending;
        break;
      case 'interested':
        color = Colors.green;
        label = 'Interested';
        icon = Icons.check_circle;
        break;
      case 'declined':
        color = Colors.red;
        label = 'Declined';
        icon = Icons.cancel;
        break;
      case 'hired':
        color = Colors.purple;
        label = 'Hired';
        icon = Icons.work;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
Widget _buildActionButtons(EmployerInterestModel candidate, double commissionAmount, {required bool isWeb}) {
  final status = candidate.status;

  // ✅ Case 1: Declined - Show declined message only
  if (status == 'declined') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Candidate Declined',
          style: TextStyle(
            fontSize: isWeb ? 12 : 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ✅ Case 2: Hired - Show Chat + View Contract buttons
  if (status == 'hired') {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Chat',
            icon: Icons.chat_bubble_outline,
            color: Colors.blue,
            onTap: () => _openChat(candidate),
            isWeb: isWeb,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'View Contract',
            icon: Icons.description_outlined,
            color: Colors.purple,
            onTap: () => _viewContract(candidate),
            isWeb: isWeb,
          ),
        ),
      ],
    );
  }

  // ✅ Case 3: Pending - Employee hasn't responded yet, show waiting message only
  if (status == 'pending') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: isWeb ? 14 : 16, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Text(
              'Waiting for Employee Response',
              style: TextStyle(
                fontSize: isWeb ? 12 : 14,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Case 4: Interested - Employee has accepted, show Chat + Hire buttons
  if (status == 'interested') {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Chat',
            icon: Icons.chat_bubble_outline,
            color: Colors.blue,
            onTap: () => _openChat(candidate),
            isWeb: isWeb,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => _buildActionButton(
            label: 'Hire Now',
            icon: Icons.work_outline,
            color: Colors.green,
            isLoading: controller.isHiring.value,
            onTap: controller.isHiring.value ? null : () => _hireCandidate(candidate),
            isWeb: isWeb,
          )),
        ),
      ],
    );
  }

  // Default case
  return const SizedBox();
}
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
    required bool isWeb,
  }) {
    if (isWeb) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: isLoading
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
        ),
      );
    } else {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Candidates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: primary,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Interested'),
                Tab(text: 'Hired'),
              ],
            ),
          ),
        ),
        actions: [
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  '\$${controller.walletBalance.value.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: primary,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value != null) {
            return _buildErrorWidget();
          }

          if (controller.allCandidates.isEmpty) {
            return _buildEmptyState();
          }

          final filteredCandidates = _getFilteredCandidates();

          if (filteredCandidates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_alt_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_getStatusDisplayName(_selectedStatusFilter)} candidates',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatusFilter = 'all';
                        _tabController.animateTo(0);
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Clear Filter',
                      style: TextStyle(color: primary),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCandidates.length,
            itemBuilder: (context, index) {
              final candidate = filteredCandidates[index];
              return _buildCandidateCardMobile(candidate);
            },
          );
        }),
      ),
    );
  }

  // Mobile Candidate Card
  Widget _buildCandidateCardMobile(EmployerInterestModel candidate) {
    final commissionAmount = candidate.salaryAmount * 0.2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    image: candidate.employeePhoto.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(candidate.employeePhoto),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: candidate.employeePhoto.isEmpty
                      ? Center(
                          child: Text(
                            candidate.employeeName.isNotEmpty
                                ? candidate.employeeName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.employeeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate.employeeTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(candidate.status),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Position',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            candidate.jobTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        candidate.formattedSalary,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (candidate.message.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.message_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            candidate.message,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (candidate.status != 'hired' && candidate.status != 'declined')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Platform Fee (20%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Commission: \$${commissionAmount.toStringAsFixed(0)} will be deducted',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                _buildActionButtons(candidate, commissionAmount, isWeb: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============== HELPER FUNCTIONS ==============
  void _hireCandidate(EmployerInterestModel candidate) {
    final commissionAmount = candidate.salaryAmount * 0.2;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Confirm Hire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hire ${candidate.employeeName} as ${candidate.jobTitle}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Salary:'),
                      Text(candidate.formattedSalary,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Commission (20%):'),
                      Text(
                        '\$${commissionAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Wallet Balance:'),
                      Obx(() => Text(
                        '\$${controller.walletBalance.value.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.walletBalance.value >= commissionAmount
                              ? Colors.green
                              : Colors.red,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Obx(() {
            final canHire = controller.walletBalance.value >= commissionAmount;
            return ElevatedButton(
              onPressed: canHire ? () => _processHire(candidate) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canHire ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Hire'),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _processHire(EmployerInterestModel candidate) async {
    Navigator.pop(context);

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final commissionAmount = candidate.salaryAmount * 0.2;
    final success = await controller.hireCandidate(
      candidate.id,
      commissionAmount,
    );

    if (Get.isDialogOpen ?? false) Get.back();

    if (success) {
      Get.snackbar(
        '🎉 Success!',
        '${candidate.employeeName} has been hired successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to hire candidate. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openChat(EmployerInterestModel candidate) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final myUserId = prefs.getString('auth_user_id') ?? '';
      final myToken = prefs.getString('auth_token') ?? '';

      if (Get.isDialogOpen ?? false) Get.back();

      Get.to(() => ChatScreen(
        userName: candidate.employeeName,
        userOnline: false,
        toUserId: candidate.employeeId,
        baseUrl: ApiConfig.baseUrl,
        myToken: myToken,
        myUserId: myUserId,
      ));
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Failed to open chat',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _viewContract(EmployerInterestModel candidate) {
    Get.snackbar(
      'Coming Soon',
      'Contract view feature coming soon',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // ============== EMPTY & ERROR STATES ==============
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 64,
                color: primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Candidates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When employees accept your requests,\nthey will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}