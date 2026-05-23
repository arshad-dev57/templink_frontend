import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/Controller/employer_proposals_projects_controller.dart';
import 'package:templink/Employeer/Screens/Employer_Contract_Screen.dart';
import 'package:templink/Employeer/Screens/talent_profile.dart';
import 'package:templink/Employeer/model/employer_project_model.dart' as employer_models;
import 'package:templink/Employeer/model/talent_model.dart' as talent_model;
import 'package:templink/Global_Screens/Chat_Screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';

class ProposalDetailScreen extends StatefulWidget {
  final employer_models.ProjectProposal proposal;
  final employer_models.EmployerProject project;
  
  const ProposalDetailScreen({
    Key? key,
    required this.proposal,
    required this.project,
  }) : super(key: key);

  @override
  State<ProposalDetailScreen> createState() => _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends State<ProposalDetailScreen> {
  final EmployerProposalsProjectsController controller = Get.find<EmployerProposalsProjectsController>();
  
  bool _isExpanded = false;

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
          const Text(
            'Proposal Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (widget.proposal.status == 'PENDING')
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'accept',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('Accept Proposal'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Reject Proposal'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'accept') {
                  _showAcceptDialog();
                } else if (value == 'reject') {
                  _showRejectDialog();
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWebContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
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
    );
  }

  Widget _buildTwoColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildBidDetailsCard(),
              const SizedBox(height: 16),
              _buildCoverLetterCard(),
              if (widget.proposal.attachedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAttachedFilesCard(),
              ],
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right Column
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildFreelancerCard(),
              const SizedBox(height: 16),
              if (widget.proposal.selectedPortfolioProjects.isNotEmpty)
                _buildPortfolioCard(),
              const SizedBox(height: 16),
              _buildTimelineCard(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 16),
        _buildFreelancerCard(),
        const SizedBox(height: 16),
        _buildBidDetailsCard(),
        const SizedBox(height: 16),
        _buildCoverLetterCard(),
        if (widget.proposal.attachedFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAttachedFilesCard(),
        ],
        if (widget.proposal.selectedPortfolioProjects.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildPortfolioCard(),
        ],
        const SizedBox(height: 16),
        _buildTimelineCard(),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Proposal Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          if (widget.proposal.status == 'PENDING')
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'accept',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('Accept Proposal'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Reject Proposal'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'accept') {
                  _showAcceptDialog();
                } else if (value == 'reject') {
                  _showRejectDialog();
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildFreelancerCard(),
            const SizedBox(height: 16),
            _buildBidDetailsCard(),
            const SizedBox(height: 16),
            _buildCoverLetterCard(),
            if (widget.proposal.attachedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAttachedFilesCard(),
            ],
            if (widget.proposal.selectedPortfolioProjects.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPortfolioCard(),
            ],
            const SizedBox(height: 16),
            _buildTimelineCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==================== CARDS (Responsive) ====================
  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.description, color: primary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.project.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: widget.proposal.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: widget.proposal.statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: widget.proposal.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.proposal.displayStatus,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.proposal.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _buildInfoChipWeb(Icons.attach_money, 'Budget: ${widget.project.displayBudget}'),
              _buildInfoChipWeb(Icons.access_time, 'Duration: ${widget.project.duration}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChipWeb(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey.shade600),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildFreelancerCard() {
    final employee = widget.proposal.employee;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Freelancer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35.r,
                backgroundColor: primary.withOpacity(0.1),
                backgroundImage: employee.employeeProfile.photoUrl.isNotEmpty
                    ? NetworkImage(employee.employeeProfile.photoUrl)
                    : null,
                child: employee.employeeProfile.photoUrl.isEmpty
                    ? Text(
                        employee.initials,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.displayName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (employee.employeeProfile.rating > 0)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 14.sp, color: Colors.amber),
                                SizedBox(width: 2.w),
                                Text(
                                  employee.employeeProfile.rating.toStringAsFixed(1),
                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      employee.email,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 4.h),
                    if (employee.employeeProfile.title.isNotEmpty)
                      Text(
                        employee.employeeProfile.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: employee.employeeProfile.skills.take(3).map((skill) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(skill, style: TextStyle(fontSize: 11.sp)),
                        );
                      }).toList(),
                    ),
                    if (employee.employeeProfile.skills.length > 3)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          '+${employee.employeeProfile.skills.length - 3} more skills',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToTalentProfile(),
                  icon: Icon(Icons.person, size: 18.sp),
                  label: const Text('View Full Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openChat(),
                  icon: Icon(Icons.chat_bubble_outline, size: 18.sp),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBidDetailsCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bid Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 500;
              
              if (isSmall) {
                return Column(
                  children: [
                    _buildDetailItem(
                      icon: Icons.attach_money,
                      label: 'Bid Amount',
                      value: '\$${widget.proposal.fixedPrice}',
                      valueColor: primary,
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailItem(
                      icon: Icons.access_time,
                      label: 'Duration',
                      value: '${widget.proposal.projectDuration} months',
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailItem(
                      icon: Icons.calculate,
                      label: 'Service Fee (20%)',
                      value: '\$${(widget.proposal.fixedPrice * 0.2).toStringAsFixed(2)}',
                      valueColor: Colors.orange,
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailItem(
                      icon: Icons.account_balance_wallet,
                      label: 'You\'ll Receive',
                      value: '\$${(widget.proposal.fixedPrice * 0.8).toStringAsFixed(2)}',
                      valueColor: Colors.green,
                    ),
                  ],
                );
              }
              
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildDetailItem(
                        icon: Icons.attach_money,
                        label: 'Bid Amount',
                        value: '\$${widget.proposal.fixedPrice}',
                        valueColor: primary,
                      )),
                      Expanded(child: _buildDetailItem(
                        icon: Icons.access_time,
                        label: 'Duration',
                        value: '${widget.proposal.projectDuration} months',
                      )),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(child: _buildDetailItem(
                        icon: Icons.calculate,
                        label: 'Service Fee (20%)',
                        value: '\$${(widget.proposal.fixedPrice * 0.2).toStringAsFixed(2)}',
                        valueColor: Colors.orange,
                      )),
                      Expanded(child: _buildDetailItem(
                        icon: Icons.account_balance_wallet,
                        label: 'You\'ll Receive',
                        value: '\$${(widget.proposal.fixedPrice * 0.8).toStringAsFixed(2)}',
                        valueColor: Colors.green,
                      )),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black87,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade600),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverLetterCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                'Cover Letter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 18.sp),
                label: Text(_isExpanded ? 'Show Less' : 'Read More', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              widget.proposal.coverLetter,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.5),
              maxLines: _isExpanded ? null : 5,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachedFilesCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attached Files',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          ...widget.proposal.attachedFiles.map((file) {
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(_getFileIcon(file.fileName), color: Colors.blue.shade700, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.fileName,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.download, color: primary, size: 20.sp),
                    onPressed: () => _downloadFile(file.fileUrl),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Projects',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.proposal.selectedPortfolioProjects.length,
              itemBuilder: (context, index) {
                final project = widget.proposal.selectedPortfolioProjects[index];
                return Container(
                  width: 100.w,
                  margin: EdgeInsets.only(right: 12.w),
                  child: Column(
                    children: [
                      Container(
                        height: 70.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10.r),
                          image: project.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(project.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: project.imageUrl.isEmpty
                            ? Icon(Icons.image, size: 30.sp, color: Colors.grey)
                            : null,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        project.title,
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
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

  Widget _buildTimelineCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          _buildTimelineItem(
            'Proposal Sent',
            DateFormat('MMM dd, yyyy • hh:mm a').format(widget.proposal.createdAt),
            Icons.send,
            Colors.blue,
          ),
          const Divider(height: 16),
          _buildTimelineItem(
            'Expected Duration',
            '${widget.proposal.projectDuration} months',
            Icons.access_time,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.sp, color: color),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.proposal.status == 'ACCEPTED') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Get.to(() => EmployerContractScreen(
                  projectId: widget.project.id,
                ));
              },
              icon: Icon(Icons.description, size: 18.sp),
              label: const Text('View Contract'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openChat(),
              icon: Icon(Icons.message, size: 18.sp),
              label: const Text('Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ],
      );
    }
    
    if (widget.proposal.status == 'PENDING') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(),
              icon: Icon(Icons.close, size: 18.sp),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openChat(),
              icon: Icon(Icons.chat_bubble_outline, size: 18.sp),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAcceptDialog(),
              icon: Icon(Icons.check_circle, size: 18.sp),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  // ==================== HELPER METHODS ====================
  void _navigateToTalentProfile() {
    final employee = widget.proposal.employee;
    final talent = talent_model.TalentModel(
      id: employee.id,
      firstName: employee.firstName,
      lastName: employee.lastName,
      email: employee.email,
      country: employee.country,
      createdAt: null,
      title: employee.employeeProfile.title,
      bio: employee.employeeProfile.bio,
      skills: employee.employeeProfile.skills,
      experienceLevel: employee.employeeProfile.experienceLevel,
      category: employee.employeeProfile.category,
      hourlyRate: employee.employeeProfile.hourlyRate,
      photoUrl: employee.employeeProfile.photoUrl,
      rating: employee.employeeProfile.rating,
      totalReviews: 0,
      availability: '',
      workExperiences: employee.employeeProfile.workExperiences,
      educations: employee.employeeProfile.educations,
      portfolioProjects: employee.employeeProfile.portfolioProjects.map((project) {
        final projectMap = project as Map<String, dynamic>? ?? {};
        return talent_model.PortfolioProject(
          id: projectMap['_id']?.toString() ?? '',
          title: projectMap['title']?.toString() ?? '',
          description: projectMap['description']?.toString() ?? '',
          imageUrl: projectMap['imageUrl']?.toString() ?? '',
          images: [],
          category: '',
          completionDate: projectMap['completionDate']?.toString() ?? '',
          clientName: '',
          projectUrl: '',
        );
      }).toList(),
    );
    Get.to(() => TalentProfileScreen(talent: talent));
  }

  Future<void> _openChat() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final myUserId = prefs.getString('auth_user_id') ?? '';
      final myToken = prefs.getString('auth_token') ?? '';
      final userJson = prefs.getString('auth_user');

      if (Get.isDialogOpen ?? false) Get.back();

      if (myUserId.isEmpty || myToken.isEmpty) {
        Get.snackbar('Error', 'Please login first',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      Get.to(() => ChatScreen(
        userName: widget.proposal.employee.displayName,
        userOnline: false,
        toUserId: widget.proposal.employee.id,
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

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'xls': case 'xlsx': return Icons.table_chart;
      case 'jpg': case 'jpeg': case 'png': case 'gif': return Icons.image;
      case 'zip': case 'rar': return Icons.archive;
      default: return Icons.insert_drive_file;
    }
  }

  Future<void> _downloadFile(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        Get.snackbar('Error', 'Could not open file',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Accept Proposal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to accept ${widget.proposal.employee.firstName}\'s proposal?'),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will generate a contract and notify the freelancer',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
            onPressed: controller.isAccepting.value ? null : () async {
              await controller.acceptProposal(widget.proposal.id);
              Navigator.pop(context);
              Get.to(() => EmployerContractScreen(projectId: widget.project.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: controller.isAccepting.value
                ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Accept'),
          )),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Reject Proposal'),
        content: Text('Are you sure you want to reject ${widget.proposal.employee.firstName}\'s proposal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}