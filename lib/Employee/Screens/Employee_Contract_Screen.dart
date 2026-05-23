import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/proposal_controller.dart';
import 'package:templink/Employee/Controllers/Employee_Contract_Controller.dart';
import 'package:templink/Utils/colors.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:signature/signature.dart';

class EmployeeContractScreen extends StatefulWidget {
  final String projectId;
  final String? contractId;
  final bool viewOnly;

  const EmployeeContractScreen({
    Key? key,
    required this.projectId,
    this.contractId,
    this.viewOnly = false,
  }) : super(key: key);

  @override
  State<EmployeeContractScreen> createState() => _EmployeeContractScreenState();
}

class _EmployeeContractScreenState extends State<EmployeeContractScreen> {
  final EmployeeContractController controller =
      Get.put(EmployeeContractController());
  final ProposalController proposalController = Get.put(ProposalController());

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _agreeToTerms = false;
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _loadContract();
    signatureController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    signatureController.dispose();
    super.dispose();
  }

  Future<void> _loadContract() async {
    if (widget.contractId != null) {
      await controller.getContract(widget.contractId!);
    } else {
      await controller.getContractByProject(widget.projectId);
    }
    if (controller.isEmployeeSigned) {
      setState(() {
        _agreeToTerms = true;
        _currentStep = 2;
      });
    }
  }

  Future<void> _saveSignature() async {
    if (!_agreeToTerms) {
      Get.snackbar('Terms & Conditions', 'Please agree to terms before signing',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    if (signatureController.isEmpty) {
      Get.snackbar('Signature Required', 'Please draw your signature',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }
    final Uint8List? signatureData = await signatureController.toPngBytes();
    if (signatureData == null) return;
    String base64Signature =
        "data:image/png;base64,${base64Encode(signatureData)}";
    final success = await controller.employeeSignContract(
      contractId: controller.contract.value['_id'] ?? '',
      signature: base64Signature,
    );
    if (success) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        } else {
          Get.back(result: true);
          proposalController.fetchMyProposals();
        }
      }
    }
  }

  Uint8List _base64ToImage(String base64String) {
    String cleaned = base64String;
    if (base64String.contains(',')) {
      cleaned = base64String.split(',').last;
    }
    return base64Decode(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.contract.value.isEmpty) {
          return _buildErrorState();
        }
        return Column(
          children: [
            _buildTopBar(isWide),
            if (!widget.viewOnly) _buildStepBar(isWide),
            Expanded(
              child: widget.viewOnly
                  ? _buildViewOnlyBody(isWide)
                  : _buildSigningBody(isWide),
            ),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────
  Widget _buildTopBar(bool isWide) {
  final contract = controller.contract.value;
  final employerSigned = controller.isEmployerSigned;
  final isActive = controller.isContractActive;

  return Container(
    // Remove the 'color' property and add it to decoration
    padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,  // ✅ Move color here
      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 18, color: Colors.black54),
                const SizedBox(width: 6),
                Text('Back',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ),
        const Spacer(),
        Column(
          children: [
            Text(
              widget.viewOnly ? 'Contract details' : 'Contract agreement',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              'ID: ${contract['contractNumber'] ?? ''}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        const Spacer(),
        if (isActive)
          _topBadge('Active', Colors.green.shade600)
        else if (employerSigned)
          _topBadge('Employer signed', Colors.blue.shade600)
        else
          _topBadge('Pending', Colors.orange.shade600),
      ],
    ),
  );
}
  Widget _topBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildStepBar(bool isWide) {
  return Container(
    // Remove 'color' property
    padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,  // ✅ Move color here
      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        _stepNode(1, 'Review', Icons.description_outlined),
        Expanded(child: _stepLine(_currentStep >= 2)),
        _stepNode(2, 'Sign', Icons.draw_outlined),
        Expanded(child: _stepLine(_currentStep >= 3)),
        _stepNode(3, 'Complete', Icons.check_circle_outline),
      ],
    ),
  );
}

  Widget _stepNode(int step, String label, IconData icon) {
    final done = _currentStep > step;
    final active = _currentStep == step;
    Color bg = done
        ? Colors.green.shade600
        : active
            ? primary
            : Colors.grey.shade200;
    Color fg = (done || active) ? Colors.white : Colors.grey.shade500;

    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Icon(icon, size: 16, color: fg),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? primary : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool filled) {
    return Container(
      height: 1.5,
      margin: const EdgeInsets.only(bottom: 18),
      color: filled ? Colors.green.shade600 : Colors.grey.shade300,
    );
  }

  // ─────────────────────────────────────────────────────────
  // BODIES
  // ─────────────────────────────────────────────────────────
  Widget _buildViewOnlyBody(bool isWide) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 280,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildSidebar(),
            ),
          ),
          Container(width: 0.5, color: Colors.grey.shade200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildContractContent(showTermsCheckbox: false),
            ),
          ),
        ],
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSidebar(),
          const SizedBox(height: 16),
          _buildContractContent(showTermsCheckbox: false),
        ],
      ),
    );
  }

  Widget _buildSigningBody(bool isWide) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 280,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildSidebar(),
            ),
          ),
          Container(width: 0.5, color: Colors.grey.shade200),
          Expanded(
            child: IndexedStack(
              index: _currentStep - 1,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildContractContent(showTermsCheckbox: true),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildSignStep(),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    // Mobile version
    return IndexedStack(
      index: _currentStep - 1,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildContractContent(showTermsCheckbox: true),
              const SizedBox(height: 12),
              _buildSidebar(),
            ],
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildSignStep(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // SIDEBAR
  // ─────────────────────────────────────────────────────────
  Widget _buildSidebar() {
    final contract = controller.contract.value;
    final milestones = contract['milestones'] as List? ?? [];
    final terms = contract['terms'] ?? {};
    final employerSigned = controller.isEmployerSigned;
    final employeeSigned = controller.isEmployeeSigned;
    final employerSignedAt = controller.getEmployerSignedAt();
    final employeeSignedAt = controller.getEmployeeSignedAt();

    double total = 0;
    for (final m in milestones) {
      total += (m['amount'] as num?)?.toDouble() ?? 0;
    }
    final platformFee = total * 0.1;
    final youReceive = total - platformFee;

    return Column(
      children: [
        // Signature status
        _sideCard(
          title: 'Signature status',
          child: Column(
            children: [
              _sigStatusRow(
                name: contract['employerId']?['firstName'] ?? 'Employer',
                signed: employerSigned,
                date: employerSignedAt,
              ),
              const SizedBox(height: 8),
              _sigStatusRow(
                name: 'You',
                signed: employeeSigned,
                date: employeeSignedAt,
                isYou: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Payment summary
        _sideCard(
          title: 'Payment summary',
          child: Column(
            children: [
              ...milestones.asMap().entries.map((e) {
                final i = e.key;
                final m = e.value;
                return _summaryRow(
                  'Milestone ${i + 1}',
                  '\$${m['amount'] ?? 0}',
                );
              }),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Divider(height: 1),
              ),
              _summaryRow('Total', '\$${total.toStringAsFixed(0)}',
                  bold: true),
              _summaryRow(
                  'Platform fee (10%)', '−\$${platformFee.toStringAsFixed(0)}',
                  muted: true),
              const SizedBox(height: 4),
              _summaryRow(
                  'You receive', '\$${youReceive.toStringAsFixed(0)}',
                  green: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Key terms
        _sideCard(
          title: 'Key terms',
          child: Column(
            children: [
              _termsRow('Revisions',
                  '${terms['revisionCount'] ?? 2} free in ${terms['revisionDays'] ?? 7} days'),
              _termsRow('Notice period',
                  '${terms['terminationNotice'] ?? 7} days'),
              _termsRow('Confidential',
                  terms['confidentialityRequired'] == true ? 'Yes' : 'No'),
              _termsRow('IP transfer',
                  _getIpShort(terms['intellectualProperty']?.toString())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sideCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _sigStatusRow(
      {required String name,
      required bool signed,
      required String date,
      bool isYou = false}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: signed ? Colors.green.shade600 : Colors.orange.shade400,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
              Text(
                signed ? 'Signed · ${_formatDateShort(date)}' : 'Pending',
                style: TextStyle(
                    fontSize: 11,
                    color: signed
                        ? Colors.green.shade600
                        : Colors.orange.shade600),
              ),
            ],
          ),
        ),
        if (signed)
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
      ],
    );
  }

  Widget _summaryRow(String label, String value,
      {bool bold = false, bool muted = false, bool green = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: muted
                        ? Colors.grey.shade500
                        : Colors.grey.shade700)),
          ),
          Text(value,
              style: TextStyle(
                fontSize: bold || green ? 13 : 12,
                fontWeight: bold || green ? FontWeight.w600 : FontWeight.normal,
                color: green
                    ? Colors.green.shade700
                    : Colors.black87,
              )),
        ],
      ),
    );
  }

  Widget _termsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600))),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CONTRACT CONTENT
  // ─────────────────────────────────────────────────────────
  Widget _buildContractContent({required bool showTermsCheckbox}) {
    final contract = controller.contract.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContractHeader(contract),
        const SizedBox(height: 16),
        _buildPartiesSection(contract),
        const SizedBox(height: 16),
        _buildProjectSection(contract),
        const SizedBox(height: 16),
        _buildMilestonesSection(contract),
        const SizedBox(height: 16),
        _buildTermsSection(showCheckbox: showTermsCheckbox),
        if (showTermsCheckbox) ...[
          const SizedBox(height: 16),
          _buildReviewActions(),
        ],
        if (!showTermsCheckbox && widget.viewOnly) ...[
          const SizedBox(height: 16),
          _buildSignatureStatusSection(),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── Contract Header ───────────────────────────────────────
  Widget _buildContractHeader(dynamic contract) {
    final project = contract['projectSnapshot'] ?? {};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
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
                      'CONTRACT #${contract['contractNumber'] ?? ''}',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.8,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project['title'] ?? 'Contract Agreement',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  controller.getStatusText(contract['status'] ?? ''),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _headerChip(Icons.calendar_today_outlined,
                  'Entered: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}'),
              const SizedBox(width: 8),
              _headerChip(Icons.schedule_outlined, project['duration'] ?? 'N/A'),
              const SizedBox(width: 8),
              _headerChip(Icons.place_outlined, 'Remote'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // ─── Parties ───────────────────────────────────────────────
  Widget _buildPartiesSection(dynamic contract) {
    return _sectionCard(
      title: 'Parties involved',
      child: Row(
        children: [
          Expanded(
            child: _partyBox(
              initials: (contract['employerId']?['firstName'] ?? 'E')
                  .substring(0, 1)
                  .toUpperCase(),
              role: 'Employer',
              name: contract['employerId']?['firstName'] ?? 'Employer',
              sub: contract['employerId']?['employerProfile']?['companyName'] ??
                  '',
              bgColor: Colors.blue.shade50,
              textColor: Colors.blue.shade800,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.swap_horiz, color: Colors.grey.shade400),
          ),
          Expanded(
            child: _partyBox(
              initials: (contract['employeeId']?['firstName'] ?? 'Y')
                  .substring(0, 1)
                  .toUpperCase(),
              role: 'You (freelancer)',
              name: contract['employeeId']?['firstName'] ?? 'You',
              sub: contract['employeeId']?['employeeProfile']?['title'] ??
                  'Freelancer',
              bgColor: Colors.green.shade50,
              textColor: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _partyBox({
    required String initials,
    required String role,
    required String name,
    required String sub,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            alignment: Alignment.center,
            child: Text(initials,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
          ),
          const SizedBox(height: 8),
          Text(role.toUpperCase(),
              style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.6,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(name,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Text(sub,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ─── Project Details ───────────────────────────────────────
  Widget _buildProjectSection(dynamic contract) {
    final project = contract['projectSnapshot'] ?? {};
    return _sectionCard(
      title: 'Project details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project['title'] ?? '',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(project['description'] ?? '',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.6)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _infoChip(Icons.category_outlined,
                  project['category'] ?? 'N/A', Colors.blue),
              _infoChip(Icons.schedule_outlined,
                  project['duration'] ?? 'N/A', Colors.orange),
              _infoChip(Icons.attach_money_outlined,
                  'Total: \$${controller.totalAmount}', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─── Milestones ────────────────────────────────────────────
  Widget _buildMilestonesSection(dynamic contract) {
    final milestones = contract['milestones'] as List? ?? [];
    return _sectionCard(
      title: 'Milestones',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('${milestones.length} milestones',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700)),
      ),
      child: Column(
        children: List.generate(milestones.length, (i) {
          final m = milestones[i];
          final isFirst = i == 0;
          return _milestoneRow(
            number: i + 1,
            title: m['title']?.toString() ?? 'Milestone ${i + 1}',
            description: m['description']?.toString() ?? '',
            amount: m['amount']?.toString() ?? '0',
            isFirst: isFirst,
          );
        }),
      ),
    );
  }

  Widget _milestoneRow({
    required int number,
    required String title,
    required String description,
    required String amount,
    required bool isFirst,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFirst
                  ? Colors.green.shade50
                  : Colors.grey.shade100,
              border: Border.all(
                color: isFirst
                    ? Colors.green.shade300
                    : Colors.grey.shade300,
                width: 0.8,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isFirst
                    ? Colors.green.shade700
                    : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(description,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isFirst ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFirst
                    ? Colors.green.shade200
                    : Colors.grey.shade200,
                width: 0.5,
              ),
            ),
            child: Text(
              '\$$amount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isFirst
                    ? Colors.green.shade700
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Terms ─────────────────────────────────────────────────
  Widget _buildTermsSection({required bool showCheckbox}) {
    final contract = controller.contract.value;
    final terms = contract['terms'] ?? {};

    return _sectionCard(
      title: 'Terms & conditions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _termItem(Icons.edit_outlined, 'Revisions',
              '${terms['revisionCount'] ?? 2} free revisions within ${terms['revisionDays'] ?? 7} days'),
          _termItem(Icons.copyright_outlined, 'Intellectual property',
              _getIpText(terms['intellectualProperty']?.toString())),
          _termItem(Icons.lock_outline, 'Confidentiality',
              terms['confidentialityRequired'] == true
                  ? 'Required — NDA applies to this contract'
                  : 'No confidentiality clause'),
          _termItem(Icons.notifications_none_outlined, 'Termination',
              '${terms['terminationNotice'] ?? 7} days written notice required'),
          if (showCheckbox) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _agreeToTerms
                    ? Colors.green.shade50
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _agreeToTerms
                      ? Colors.green.shade200
                      : Colors.grey.shade200,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (v) =>
                        setState(() => _agreeToTerms = v ?? false),
                    activeColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Expanded(
                    child: Text(
                      'I have read and agree to all terms and conditions of this contract, and confirm my identity as the authorized signatory.',
                      style: TextStyle(
                          fontSize: 12,
                          color: _agreeToTerms
                              ? Colors.green.shade800
                              : Colors.grey.shade700,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _termItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200, width: 0.5),
            ),
            child: Icon(icon, size: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Signature Status (view only) ──────────────────────────
  Widget _buildSignatureStatusSection() {
    final isActive = controller.isContractActive;
    final employerSigned = controller.isEmployerSigned;
    final employeeSigned = controller.isEmployeeSigned;
    final employerSignature = controller.getEmployerSignature();
    final employeeSignature = controller.getEmployeeSignature();
    final employerSignedAt = controller.getEmployerSignedAt();
    final employeeSignedAt = controller.getEmployeeSignedAt();

    return _sectionCard(
      title: isActive ? 'Contract active' : 'Signature status',
      titleColor: isActive ? Colors.green.shade700 : null,
      child: Column(
        children: [
          _signatureBlock(
            label: 'Employer signature',
            signed: employerSigned,
            date: employerSignedAt,
            signatureBase64: employerSignature,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _signatureBlock(
            label: 'Your signature',
            signed: employeeSigned,
            date: employeeSignedAt,
            signatureBase64: employeeSignature,
          ),
          if (!employerSigned) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200, width: 0.8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange.shade700, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Waiting for employer to sign the contract.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _signatureBlock({
    required String label,
    required bool signed,
    required String date,
    String? signatureBase64,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: signed ? Colors.green.shade50 : Colors.grey.shade100,
              ),
              child: Icon(
                signed ? Icons.check_circle_outline : Icons.schedule_outlined,
                size: 18,
                color: signed ? Colors.green.shade600 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(
                    signed
                        ? 'Signed on ${_formatDateShort(date)}'
                        : 'Pending signature',
                    style: TextStyle(
                        fontSize: 11,
                        color: signed
                            ? Colors.green.shade600
                            : Colors.orange.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (signed &&
            signatureBase64 != null &&
            signatureBase64.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(left: 46),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signature',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: Colors.grey.shade200, width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.memory(
                      _base64ToImage(signatureBase64),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── Review Actions ────────────────────────────────────────
  Widget _buildReviewActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _agreeToTerms
                ? () {
                    setState(() => _currentStep = 2);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue to sign', style: TextStyle(fontSize: 13)),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
Widget _buildSignStep() {
  final contract = controller.contract.value;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Employer signed info
      if (controller.isEmployerSigned) ...[
        _sectionCard(
          title: 'Employer signature',
          titleColor: Colors.blue.shade700,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade50,
                ),
                child: Icon(Icons.business_outlined,
                    color: Colors.blue.shade600, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Employer has signed',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(
                      controller.formatDate(contract['signatures']
                          ?['employer']?['signedAt']
                          ?.toString()),
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.verified, color: Colors.blue.shade600, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],

      // Signature pad - FIXED VERSION
      _sectionCard(
        title: 'Your signature',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Draw your signature below to execute this contract',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            // FIX: Use SizedBox instead of Container for fixed height
            SizedBox(
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: signatureController.isEmpty
                        ? Colors.grey.shade300
                        : primary,
                    width: signatureController.isEmpty ? 0.8 : 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Signature(
                    controller: signatureController,
                    backgroundColor: Colors.grey.shade50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _sigControl(Icons.delete_outline, 'Clear',
                    () => signatureController.clear()),
                const SizedBox(width: 8),
                _sigControl(Icons.undo_outlined, 'Undo',
                    () => signatureController.undo()),
                const SizedBox(width: 8),
                _sigControl(Icons.redo_outlined, 'Redo',
                    () => signatureController.redo()),
              ],
            ),
            if (!signatureController.isEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.green.shade200, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 16),
                    const SizedBox(width: 8),
                    Text('Signature captured',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),

      const SizedBox(height: 16),

      // Actions
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() => _currentStep = 1);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 16),
                  SizedBox(width: 6),
                  Text('Back', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isProcessing.value ? null : _saveSignature,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: controller.isProcessing.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.draw_outlined, size: 16),
                          SizedBox(width: 6),
                          Text('Sign contract',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
    ],
  );
}
  Widget _sigControl(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200, width: 0.8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Generic Section Card ──────────────────────────────────
  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
    Color? titleColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: titleColor ?? Colors.grey.shade500,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ─── Error State ───────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No contract found',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Unable to load contract details',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadContract,
            style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────
  String _formatDateShort(dynamic date) {
    if (date == null || date.toString().isEmpty) return 'Not signed';
    try {
      final d = DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy').format(d);
    } catch (_) {
      return 'Invalid date';
    }
  }

  String _getIpText(String? ip) {
    switch (ip) {
      case 'EMPLOYER':
        return 'Transfers to employer after final payment';
      case 'EMPLOYEE':
        return 'Retained by you';
      default:
        return 'Transfers on final payment';
    }
  }

  String _getIpShort(String? ip) {
    switch (ip) {
      case 'EMPLOYER':
        return 'On completion';
      case 'EMPLOYEE':
        return 'You retain';
      default:
        return 'On completion';
    }
  }
}