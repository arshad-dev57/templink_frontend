// lib/Employeer/Screens/MyStatsScreen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:templink/Employee/Controllers/employee_stats_controller.dart';
import 'package:templink/Employee/Screens/wallet_screen.dart';
import 'package:templink/Global_Screens/Coins_purchase_screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

class MyStatsScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCoins;
  final VoidCallback? onNavigateToWallet;
  final VoidCallback? onBackPressed;
  final bool showSidebar;
  
  const MyStatsScreen({
    Key? key,
    this.onNavigateToCoins,
    this.onNavigateToWallet,
    this.onBackPressed,
    this.showSidebar = true,
  }) : super(key: key);

  @override
  State<MyStatsScreen> createState() => _MyStatsScreenState();
}

class _MyStatsScreenState extends State<MyStatsScreen> {
  final EmployeeStatsController controller = Get.put(EmployeeStatsController());
  String _selectedTimeRange = 'Last 12 Months';
  final List<String> _timeRanges = ['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'Last 12 Months'];
  
  @override
  void initState() {
    super.initState();
    controller.fetchAllStats();
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
          if (widget.showSidebar && widget.onBackPressed != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: widget.onBackPressed,
            ),
          const Text(
            "My Stats",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            "View proposal history, earnings, profiles",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchAllStats(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              
              if (isWide) {
                return _buildTwoColumnLayout();
              } else {
                return _buildSingleColumnLayout();
              }
            },
          ),
        ),
      );
    });
  }

  // Two-column layout for wider screens
  Widget _buildTwoColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildEarningsCard(),
              const SizedBox(height: 20),
              _buildProposalsCard(),
              const SizedBox(height: 20),
              _buildPerformanceMetrics(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 20),
              _buildRecentActivity(),
            ],
          ),
        ),
      ],
    );
  }

  // Single column layout for narrower screens
  Widget _buildSingleColumnLayout() {
    return Column(
      children: [
        _buildEarningsCard(),
        const SizedBox(height: 20),
        _buildBalanceCard(),
        const SizedBox(height: 20),
        _buildProposalsCard(),
        const SizedBox(height: 20),
        _buildRecentActivity(),
        const SizedBox(height: 20),
        _buildPerformanceMetrics(),
        const SizedBox(height: 40),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Stats",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAllStats(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "View proposal history, earnings, profiles",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                _buildEarningsCard(),
                const SizedBox(height: 20),
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _buildProposalsCard(),
                const SizedBox(height: 20),
                _buildRecentActivity(),
                const SizedBox(height: 20),
                _buildPerformanceMetrics(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ==================== BALANCE CARD (Points + Wallet with separate buttons) ====================
  Widget _buildBalanceCard() {
    final totalPoints = controller.pointsBalance.value;
    final totalPointsTarget = 2000;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.1), primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "My Balance",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Points & Wallet Balance",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Points Section with Buy Coins Button
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Points Balance",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // Buy Coins Button - Separate
                        GestureDetector(
                          onTap: () {
                            final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
                            if (isWeb && widget.onNavigateToCoins != null) {
                              widget.onNavigateToCoins!();
                            } else {
                              Get.to(() => const CoinsPurchaseScreen());
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_circle_outline, color: primary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "Buy Coins",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${controller.pointsBalance.value}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: totalPoints / totalPointsTarget,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${((totalPoints / totalPointsTarget) * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Divider(color: Colors.grey.shade300, height: 1),
          
          const SizedBox(height: 16),
          
          // Wallet Section with Go to Wallet Button
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Wallet Balance",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // Go to Wallet Button - Separate
                        GestureDetector(
                          onTap: () {
                            final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
                            if (isWeb && widget.onNavigateToWallet != null) {
                              widget.onNavigateToWallet!();
                            } else {
                              Get.to(() => const WalletScreen());
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_forward, color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  "Go to Wallet",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.formatCurrency(controller.walletBalance.value),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Available for withdrawals",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== EARNINGS CARD ====================
  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Earnings",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "USD",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(
                  controller.formatCurrency(controller.totalEarnings.value),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${controller.successRate.value}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                "Pending: ${controller.formatCurrency(controller.pendingEarnings.value)}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Avg/Project: ${controller.formatCurrency(controller.averagePerProject.value)}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Member since: ${controller.memberSince.value} (${controller.totalDays.value} days)",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROPOSALS CARD ====================
  Widget _buildProposalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Proposals & Contracts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTimeRange,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade600,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTimeRange = newValue!;
                        String period = 'month';
                        if (newValue == 'Last 7 Days') period = 'week';
                        if (newValue == 'Last 30 Days') period = 'month';
                        if (newValue == 'Last 90 Days') period = 'month';
                        if (newValue == 'Last 12 Months') period = 'year';
                        controller.fetchEarningsHistory(period: period);
                      });
                    },
                    items: _timeRanges.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Stats Overview - Responsive grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 400;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _statBox(label: 'Total', value: controller.totalProposals.value.toString(), color: Colors.blue)),
                    Expanded(child: _statBox(label: 'Accepted', value: controller.acceptedProposals.value.toString(), color: Colors.green)),
                    Expanded(child: _statBox(label: 'Pending', value: controller.pendingProposals.value.toString(), color: Colors.orange)),
                    Expanded(child: _statBox(label: 'Rejected', value: controller.rejectedProposals.value.toString(), color: Colors.red)),
                  ],
                );
              } else {
                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _statBox(label: 'Total', value: controller.totalProposals.value.toString(), color: Colors.blue),
                    _statBox(label: 'Accepted', value: controller.acceptedProposals.value.toString(), color: Colors.green),
                    _statBox(label: 'Pending', value: controller.pendingProposals.value.toString(), color: Colors.orange),
                    _statBox(label: 'Rejected', value: controller.rejectedProposals.value.toString(), color: Colors.red),
                  ],
                );
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // Contracts Stats - Responsive
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;
                if (isWide) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _contractStat(label: 'Active', value: controller.activeContracts.value.toString(), icon: Icons.play_circle, color: Colors.green),
                      _contractStat(label: 'Completed', value: controller.completedContracts.value.toString(), icon: Icons.check_circle, color: Colors.blue),
                      _contractStat(label: 'Working', value: controller.workingProjects.value.toString(), icon: Icons.work, color: Colors.purple),
                    ],
                  );
                } else {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _contractStat(label: 'Active', value: controller.activeContracts.value.toString(), icon: Icons.play_circle, color: Colors.green),
                      _contractStat(label: 'Completed', value: controller.completedContracts.value.toString(), icon: Icons.check_circle, color: Colors.blue),
                      _contractStat(label: 'Working', value: controller.workingProjects.value.toString(), icon: Icons.work, color: Colors.purple),
                    ],
                  );
                }
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Proposal Progress
          _proposalProgress(
            label: "Proposals Sent",
            value: controller.totalProposals.value,
            maxValue: controller.totalProposals.value > 0 ? controller.totalProposals.value : 1,
          ),
          const SizedBox(height: 12),
          _proposalProgress(
            label: "Accepted",
            value: controller.acceptedProposals.value,
            maxValue: controller.totalProposals.value > 0 ? controller.totalProposals.value : 1,
          ),
          const SizedBox(height: 12),
          _proposalProgress(
            label: "Success Rate",
            value: controller.successRate.value,
            maxValue: 100,
          ),
        ],
      ),
    );
  }

  Widget _statBox({required String label, required String value, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _contractStat({required String label, required String value, required IconData icon, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
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

  // ==================== RECENT ACTIVITY ====================
  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your latest proposals and contracts",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoadingActivity.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (controller.recentActivities.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentActivities.length > 3 ? 3 : controller.recentActivities.length,
              itemBuilder: (context, index) {
                final activity = controller.recentActivities[index];
                return _activityItem(activity);
              },
            );
          }),
          if (controller.recentActivities.length > 3)
            const SizedBox(height: 16),
          if (controller.recentActivities.length > 3)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // View all activity
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "View All Activity",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _activityItem(Map<String, dynamic> activity) {
    final type = activity['type'];
    final status = activity['status'];
    final color = controller.getActivityColor(status);
    final icon = controller.getActivityIcon(type);
    final date = activity['date'] != null 
        ? DateTime.parse(activity['date'].toString()) 
        : DateTime.now();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? activity['projectName'] ?? 'Activity',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(date)} • ${controller.getActivityStatusText(status)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (activity['amount'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '\$${activity['amount']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== PERFORMANCE METRICS ====================
  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Performance Metrics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _metricCard(title: 'Response Rate', value: '${controller.responseRate.value}%', subtitle: '', icon: Icons.timer_outlined, color: Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _metricCard(title: 'Success Rate', value: '${controller.successRate.value}%', subtitle: '', icon: Icons.check_circle_outline, color: Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _metricCard(title: 'Rating', value: controller.averageRating.value.toStringAsFixed(1), subtitle: '', icon: Icons.star_outline, color: Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _metricCard(title: 'Projects', value: controller.completedProjects.value.toString(), subtitle: '', icon: Icons.work_outline, color: Colors.purple)),
                  ],
                );
              } else {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _metricCard(title: 'Response Rate', value: '${controller.responseRate.value}%', subtitle: '', icon: Icons.timer_outlined, color: Colors.blue),
                    _metricCard(title: 'Success Rate', value: '${controller.successRate.value}%', subtitle: '', icon: Icons.check_circle_outline, color: Colors.green),
                    _metricCard(title: 'Rating', value: controller.averageRating.value.toStringAsFixed(1), subtitle: '', icon: Icons.star_outline, color: Colors.orange),
                    _metricCard(title: 'Projects', value: controller.completedProjects.value.toString(), subtitle: '', icon: Icons.work_outline, color: Colors.purple),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _proposalProgress({
    required String label,
    required int value,
    required int maxValue,
  }) {
    final double progress = maxValue == 0 ? 0 : value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              value == maxValue ? Colors.green : primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).round()} weeks ago';
    return '${(difference / 30).round()} months ago';
  }
}