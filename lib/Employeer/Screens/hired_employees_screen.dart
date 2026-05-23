// screens/hired_employees_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/hired_employee_controller.dart';
import 'package:templink/Employeer/model/hired_employee_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _bg = Color(0xFFF7F8FA);
const _surface = Colors.white;
const _border = Color(0xFFE5E7EB);
const _text1 = Color(0xFF111827);
const _text2 = Color(0xFF6B7280);
const _text3 = Color(0xFF9CA3AF);
const _success = Color(0xFF16A34A);
const _warning = Color(0xFFF59E0B);
const _error = Color(0xFFDC2626);
const _info = Color(0xFF3B82F6);
const _radius = 12.0;

class HiredEmployeesScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const HiredEmployeesScreen({
    Key? key,
    this.onBackPressed,
    this.showSidebar = true,
  }) : super(key: key);

  @override
  State<HiredEmployeesScreen> createState() => _HiredEmployeesScreenState();
}

class _HiredEmployeesScreenState extends State<HiredEmployeesScreen> {
  final controller = Get.put(HiredEmployeeController());

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    if (isWeb && !widget.showSidebar) {
      return Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildWebTopBar(),
            Expanded(child: _buildBody(isWeb, isDesktop)),
          ],
        ),
      );
    }

    if (isWeb) {
      return _buildFullWebLayout(isDesktop);
    }

    return _buildMobileLayout();
  }

  // ==================== WEB FULL LAYOUT ====================
  Widget _buildFullWebLayout(bool isDesktop) {
    final sidebarW = isDesktop ? 280.0 : 240.0;

    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          Container(
            width: sidebarW,
            decoration: BoxDecoration(
              color: _surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(2, 0)),
              ],
            ),
            child: _buildWebSidebar(),
          ),
          Expanded(
            child: Column(
              children: [
                _buildWebTopBar(),
                Expanded(child: _buildBody(true, isDesktop)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSidebar() {
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.people_outline, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Templink', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primary, primary.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Column(
              children: [
                const Icon(Icons.people_alt, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                const Text('My Team', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Manage your hired employees', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: _border))),
          child: Column(
            children: [
              _webNavItem(Icons.home_outlined, 'Dashboard', () {}),
              const SizedBox(height: 8),
              _webNavItem(Icons.arrow_back, 'Back', () {
                if (widget.onBackPressed != null) {
                  widget.onBackPressed!();
                } else {
                  Get.back();
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _webNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _text2),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, color: _text2)),
          ],
        ),
      ),
    );
  }

  Widget _buildWebTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: _surface, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
      ]),
      child: Row(
        children: [
          const Text('My Team', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () => controller.refreshList(),
            tooltip: 'Refresh',
          ),
          if (!widget.showSidebar) ...[
            const SizedBox(width: 8),
            CircleAvatar(radius: 18, backgroundColor: primary.withOpacity(0.1), child: Icon(Icons.person, size: 18, color: primary)),
          ],
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _text1),
          onPressed: widget.onBackPressed ?? () => Get.back(),
        ),
        title: const Text('My Team', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => controller.refreshList(),
          ),
        ],
      ),
      body: _buildBody(false, false),
    );
  }

  // ==================== MAIN BODY ====================
  Widget _buildBody(bool isWeb, bool isDesktop) {
    return Column(
      children: [
        _buildSummaryCards(isWeb),
        const SizedBox(height: 16),
        _buildStatusFilter(isWeb),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.hiredEmployees.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: primary));
            }

            if (controller.hiredEmployees.isEmpty) {
              return _buildEmptyState();
            }

            return _buildEmployeesList(isWeb, isDesktop);
          }),
        ),
      ],
    );
  }

  // ==================== SUMMARY CARDS ====================
  Widget _buildSummaryCards(bool isWeb) {
    final summary = controller.summary.value;
    if (summary == null) return const SizedBox();

    if (isWeb) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildSummaryCardWeb('Total', summary.total, _info, Icons.people),
            const SizedBox(width: 16),
            _buildSummaryCardWeb('Active', summary.active, _success, Icons.work),
            const SizedBox(width: 16),
            _buildSummaryCardWeb('Left', summary.left, _warning, Icons.exit_to_app),
            const SizedBox(width: 16),
            _buildSummaryCardWeb('Terminated', summary.terminated, _error, Icons.cancel),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildSummaryCardMobile('Total', summary.total, _info, Icons.people),
          const SizedBox(width: 8),
          _buildSummaryCardMobile('Active', summary.active, _success, Icons.work),
          const SizedBox(width: 8),
          _buildSummaryCardMobile('Left', summary.left, _warning, Icons.exit_to_app),
          const SizedBox(width: 8),
          _buildSummaryCardMobile('Terminated', summary.terminated, _error, Icons.cancel),
        ],
      ),
    );
  }

  Widget _buildSummaryCardWeb(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
                Text(label, style: TextStyle(fontSize: 13, color: _text2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardMobile(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  // ==================== STATUS FILTER ====================
  Widget _buildStatusFilter(bool isWeb) {
    final statuses = [
      {'value': 'all', 'label': 'All', 'color': _info},
      {'value': 'active', 'label': 'Active', 'color': _success},
      {'value': 'left', 'label': 'Left', 'color': _warning},
      {'value': 'terminated', 'label': 'Terminated', 'color': _error},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 16),
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return Obx(() {
            final isSelected = controller.selectedStatus.value == status['value'];
            return GestureDetector(
              onTap: () => controller.changeStatus(status['value'] as String),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? (status['color'] as Color) : _surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? (status['color'] as Color) : _border,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: (status['color'] as Color).withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    status['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _text2,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // ==================== EMPLOYEES LIST ====================
  Widget _buildEmployeesList(bool isWeb, bool isDesktop) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
          controller.loadNextPage();
        }
        return true;
      },
      child: isWeb
          ? GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 2 : 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.1,
              ),
              itemCount: controller.hiredEmployees.length + (controller.isLoadMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.hiredEmployees.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                }
                return _buildEmployeeCardWeb(controller.hiredEmployees[index]);
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.hiredEmployees.length + (controller.isLoadMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.hiredEmployees.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEmployeeCardMobile(controller.hiredEmployees[index]),
                );
              },
            ),
    );
  }

  // ==================== WEB EMPLOYEE CARD ====================
  Widget _buildEmployeeCardWeb(HiredEmployee employee) {
    final statusColor = controller.getStatusColor(employee.status);
    final statusText = controller.getStatusText(employee.status);

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to employee details screen
          Get.toNamed('/employee-details', arguments: employee);
        },
        borderRadius: BorderRadius.circular(_radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_radius),
                  topRight: Radius.circular(_radius),
                ),
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: employee.employeeDetails.employeeProfile.photoUrl.isNotEmpty
                          ? DecorationImage(image: NetworkImage(employee.employeeDetails.employeeProfile.photoUrl), fit: BoxFit.cover)
                          : null,
                      color: Colors.grey[300],
                    ),
                    child: employee.employeeDetails.employeeProfile.photoUrl.isEmpty
                        ? Icon(Icons.person, size: 24, color: _text3)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.employeeDetails.fullName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _text1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          employee.employeeDetails.employeeProfile.title,
                          style: TextStyle(fontSize: 12, color: _text2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                  ),
                ],
              ),
            ),
            
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow(Icons.work_outline, 'Job Title', employee.jobTitle)),
                      Expanded(child: _buildInfoRow(Icons.attach_money, 'Hourly Rate', '\$${employee.employeeDetails.employeeProfile.hourlyRate}/hr')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow(Icons.category, 'Category', employee.employeeDetails.employeeProfile.category)),
                      Expanded(child: _buildInfoRow(Icons.star, 'Experience', employee.employeeDetails.employeeProfile.experienceLevel)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Skills
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: employee.employeeDetails.employeeProfile.skills.take(3).map((skill) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                      child: Text(skill, style: TextStyle(fontSize: 10, color: primary, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: _text3),
                          const SizedBox(width: 4),
                          Text('Hired: ${_formatDate(employee.hiredAt)}', style: TextStyle(fontSize: 11, color: _text2)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${employee.employeeDetails.employeeProfile.rating.toStringAsFixed(1)} (${employee.employeeDetails.employeeProfile.totalReviews})',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _text1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (employee.status == 'left' && employee.leftReason != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: _warning.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: _warning.withOpacity(0.2))),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: _warning),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Left on: ${_formatDate(employee.leftAt!)}', style: TextStyle(fontSize: 11, color: _warning)),
                                Text('Reason: ${employee.leftReason}', style: TextStyle(fontSize: 11, color: _warning), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MOBILE EMPLOYEE CARD ====================
  Widget _buildEmployeeCardMobile(HiredEmployee employee) {
    final statusColor = controller.getStatusColor(employee.status);
    final statusText = controller.getStatusText(employee.status);

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/employee-details', arguments: employee);
        },
        borderRadius: BorderRadius.circular(_radius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: employee.employeeDetails.employeeProfile.photoUrl.isNotEmpty
                          ? DecorationImage(image: NetworkImage(employee.employeeDetails.employeeProfile.photoUrl), fit: BoxFit.cover)
                          : null,
                      color: Colors.grey[300],
                    ),
                    child: employee.employeeDetails.employeeProfile.photoUrl.isEmpty
                        ? Icon(Icons.person, size: 22, color: _text3)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.employeeDetails.fullName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _text1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          employee.employeeDetails.employeeProfile.title,
                          style: TextStyle(fontSize: 12, color: _text2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3))),
                    child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Job Details
              Row(
                children: [
                  Expanded(child: _buildInfoRow(Icons.work_outline, 'Job Title', employee.jobTitle)),
                  Expanded(child: _buildInfoRow(Icons.attach_money, 'Hourly Rate', '\$${employee.employeeDetails.employeeProfile.hourlyRate}/hr')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildInfoRow(Icons.category, 'Category', employee.employeeDetails.employeeProfile.category)),
                  Expanded(child: _buildInfoRow(Icons.star, 'Experience', employee.employeeDetails.employeeProfile.experienceLevel)),
                ],
              ),
              const SizedBox(height: 8),
              
              // Skills
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: employee.employeeDetails.employeeProfile.skills.take(3).map((skill) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                  child: Text(skill, style: TextStyle(fontSize: 10, color: primary, fontWeight: FontWeight.w500)),
                )).toList(),
              ),
              const SizedBox(height: 12),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: _text3),
                      const SizedBox(width: 4),
                      Text('Hired: ${_formatDate(employee.hiredAt)}', style: TextStyle(fontSize: 11, color: _text2)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${employee.employeeDetails.employeeProfile.rating.toStringAsFixed(1)} (${employee.employeeDetails.employeeProfile.totalReviews})',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _text1),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (employee.status == 'left' && employee.leftReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _warning.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: _warning.withOpacity(0.2))),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: _warning),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Left on: ${_formatDate(employee.leftAt!)}', style: TextStyle(fontSize: 11, color: _warning)),
                            Text('Reason: ${employee.leftReason}', style: TextStyle(fontSize: 11, color: _warning), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==================== INFO ROW ====================
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _text3),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9, color: _text3)),
              Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _text1), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline, size: 40, color: primary),
            ),
            const SizedBox(height: 20),
            const Text('No Employees Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text1)),
            const SizedBox(height: 8),
            Text('You haven\'t hired any employees yet.', style: TextStyle(fontSize: 13, color: _text2)),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER ====================
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}