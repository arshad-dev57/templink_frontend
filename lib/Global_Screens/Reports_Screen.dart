import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const ReportsScreen({
    super.key,
    this.onBackPressed,
    this.showSidebar = true,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? _earningsData;
  Map<String, dynamic>? _proposalsData;
  Map<String, dynamic>? _projectsData;
  Map<String, dynamic>? _activityData;
  bool _isLoading = true;
  String _selectedPeriod = 'month'; // week, month, year

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final userId = prefs.getString('auth_user_id') ?? '';

      if (token.isEmpty || userId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load earnings history
      final earningsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/employee-stats/earnings-history?period=$_selectedPeriod'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (earningsResponse.statusCode == 200) {
        setState(() {
          _earningsData = json.decode(earningsResponse.body);
        });
      }

      // Load employee stats for proposals and projects
      final statsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/employee-stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (statsResponse.statusCode == 200) {
        final statsData = json.decode(statsResponse.body);
        setState(() {
          _proposalsData = statsData['stats'];
          _projectsData = statsData['stats'];
          _activityData = statsData['stats'];
        });
      }
    } catch (e) {
      print('Error loading reports data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
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
            "Reports",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _selectedPeriod,
            items: const [
              DropdownMenuItem(value: 'week', child: Text('Week')),
              DropdownMenuItem(value: 'month', child: Text('Month')),
              DropdownMenuItem(value: 'year', child: Text('Year')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPeriod = value;
                });
                _loadReportsData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningsReport(),
          const SizedBox(height: 24),
          _buildProposalsReport(),
          const SizedBox(height: 24),
          _buildProjectsReport(),
          const SizedBox(height: 24),
          _buildActivityReport(),
        ],
      ),
    );
  }

  Widget _buildEarningsReport() {
    final totalEarnings = _earningsData?['earnings']?.reduce((a, b) => a + b) ?? 0;
    final labels = _earningsData?['labels'] ?? [];
    final earnings = _earningsData?['earnings'] ?? [];

    return _buildReportSection(
      title: 'Earnings Report',
      icon: Icons.account_balance_wallet,
      color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings: \$${totalEarnings.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: labels.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        labels[index],
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${earnings[index].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalsReport() {
    final proposals = _proposalsData?['proposals'] ?? {};
    final total = proposals['total'] ?? 0;
    final accepted = proposals['accepted'] ?? 0;
    final pending = proposals['pending'] ?? 0;
    final rejected = proposals['rejected'] ?? 0;
    final successRate = proposals['successRate'] ?? 0;

    return _buildReportSection(
      title: 'Proposals Report',
      icon: Icons.description,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard('Total', total.toString(), Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('Accepted', accepted.toString(), Colors.green),
              const SizedBox(width: 12),
              _buildStatCard('Pending', pending.toString(), Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard('Rejected', rejected.toString(), Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: successRate / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          Text('Success Rate: $successRate%'),
        ],
      ),
    );
  }

  Widget _buildProjectsReport() {
    final projects = _projectsData?['projects'] ?? {};
    final working = projects['working'] ?? 0;
    final completed = projects['completed'] ?? 0;

    return _buildReportSection(
      title: 'Projects Report',
      icon: Icons.work,
      color: Colors.purple,
      child: Row(
        children: [
          _buildStatCard('Active', working.toString(), Colors.purple),
          const SizedBox(width: 12),
          _buildStatCard('Completed', completed.toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _buildActivityReport() {
    final performance = _activityData?['performance'] ?? {};
    final averageRating = performance['averageRating'] ?? '0.0';
    final totalRatings = performance['totalRatings'] ?? 0;
    final responseRate = performance['responseRate'] ?? 0;

    return _buildReportSection(
      title: 'Activity Report',
      icon: Icons.bar_chart,
      color: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard('Rating', averageRating, Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard('Reviews', totalRatings.toString(), Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('Response Rate', '$responseRate%', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
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
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
