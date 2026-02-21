import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/Employer_Contract_Controller.dart';
import 'package:templink/Utils/colors.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:signature/signature.dart';

class EmployerContractScreen extends StatefulWidget {
  final String projectId;
  final String? contractId;
  final bool viewOnly;
  final bool isProposalSigning;

  const EmployerContractScreen({
    Key? key,
    required this.projectId,
    this.contractId,
    this.viewOnly = false,
    this.isProposalSigning = false,
  }) : super(key: key);

  @override
  State<EmployerContractScreen> createState() => _EmployerContractScreenState();
}

class _EmployerContractScreenState extends State<EmployerContractScreen> {
  final ContractController contractController = Get.put(ContractController());
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _agreeToTerms = false;
  final PageController _pageController = PageController();
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _loadContract();
    signatureController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    signatureController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadContract() async {
    if (widget.contractId != null) {
      await contractController.getContract(widget.contractId!);
    } else {
      await contractController.getContractByProject(widget.projectId);
    }

    final contract = contractController.contract.value;
    if (contract != null) {
      print('📄 Contract Status: ${contract['status']}');
      print('👤 Employer Signed: ${contractController.isEmployerSigned}');
      print('👤 Employee Signed: ${contractController.isEmployeeSigned}');

      // ✅ Agar proposal signing mode mein already sign ho chuka hai to back jao
      if (widget.isProposalSigning && contractController.isEmployerSigned) {
        print('✅ Already signed - going back');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'ℹ️ Info',
            'You have already signed this proposal',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Get.back();
              }
            }
          });
        });
        return;
      }
    }

    // ✅ Agar employer already sign kar chuka hai to agree to terms set karo
    if (contractController.isEmployerSigned) {
      setState(() {
        _agreeToTerms = true;
        _currentStep = 2;
      });
    }
  }

  // ==================== SAVE SIGNATURE ====================
  Future<void> _saveSignature() async {
    if (!_agreeToTerms) {
      Get.snackbar(
        'Terms & Conditions',
        'Please agree to terms before signing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (signatureController.isEmpty) {
      Get.snackbar(
        'Signature Required',
        'Please draw your signature',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final Uint8List? signatureData = await signatureController.toPngBytes();
    if (signatureData == null) return;

    String base64Signature =
        "data:image/png;base64,${base64Encode(signatureData)}";

    final success = await contractController.employerSignContract(
      contractId: contractController.contract.value?['_id'] ?? '',
      signature: base64Signature,
    );

    if (success) {
      Get.snackbar(
        '✅ Signed Successfully',
        'Your signature has been saved.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        } else {
          Get.back(result: true);
        }
      }
    }
    // ❌ Error case: contractController mein snackbar already show hota hai
    // Koi extra handling nahi chahiye - user screen par hi rahega retry ke liye
  }

  void _clearSignature() {
    signatureController.clear();
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
        title: Text(
          widget.viewOnly || contractController.isContractActive
              ? 'Contract Details'
              : widget.isProposalSigning
                  ? 'Sign Proposal'
                  : 'Contract Agreement',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: (widget.viewOnly || contractController.isContractActive)
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildStepIndicator(1, 'Review', Icons.description),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: _currentStep >= 2
                              ? primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      _buildStepIndicator(2, 'Sign', Icons.draw),
                    ],
                  ),
                ),
              ),
      ),
      body: Obx(() {
        if (contractController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (contractController.contract.value == null) {
          return _buildErrorState();
        }

        // ✅ View Only ya Active Contract - sirf contract details dikhao
        if (widget.viewOnly || contractController.isContractActive) {
          return _buildViewOnlyStep();
        }

        // ✅ Signing flow - sirf 2 steps: Review + Sign
        return PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildReviewStep(),
            _buildSignStep(),
          ],
        );
      }),
    );
  }

  // ==================== VIEW ONLY STEP (UPDATED WITH SIGNATURES) ====================
  Widget _buildViewOnlyStep() {
    final contract = contractController.contract.value;
    if (contract == null) return const SizedBox.shrink();

    final isActive = contractController.isContractActive;
    final employerSigned = contractController.isEmployerSigned;
    final employeeSigned = contractController.isEmployeeSigned;
    final employerSignedAt = contractController.getEmployerSignedAt();
    final employeeSignedAt = contractController.getEmployeeSignedAt();
    final employerSignature = contractController.getEmployerSignature();
    final employeeSignature = contractController.getEmployeeSignature();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContractHeader(contract),
          const SizedBox(height: 20),
          _buildPartiesInfo(contract),
          const SizedBox(height: 20),
          _buildProjectDetails(contract),
          const SizedBox(height: 20),
          _buildMilestones(contract),
          const SizedBox(height: 20),

          // ✅ Signature Status Card with Images
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    Icon(
                      isActive ? Icons.check_circle : Icons.access_time,
                      color: isActive ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isActive ? 'CONTRACT ACTIVE' : 'SIGNATURE STATUS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                
                // Employer Signature
                _buildSignatureWithImage(
                  'Your Signature (Employer)',
                  employerSigned,
                  employerSignedAt,
                  employerSignature,
                ),
                const SizedBox(height: 20),
                
                // Employee Signature
                _buildSignatureWithImage(
                  'Employee Signature',
                  employeeSigned,
                  employeeSignedAt,
                  employeeSignature,
                ),
                
                if (!employeeSigned) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Waiting for employee to sign the contract.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Next Steps - only if active
          if (isActive)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.work, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Next Steps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStepItem(
                    '1',
                    'Make first milestone payment',
                    'Proceed to milestone 1 payment to start the work',
                  ),
                  _buildStepItem(
                    '2',
                    'Review work',
                    'Employee will submit work for your review',
                  ),
                  _buildStepItem(
                    '3',
                    'Release payment',
                    'After approval, next milestone unlocks',
                  ),
                ],
              ),
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==================== NEW: Signature with Image Widget ====================
  Widget _buildSignatureWithImage(String label, bool signed, String date, String? signatureBase64) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: signed ? Colors.green.shade50 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                signed ? Icons.check_circle : Icons.access_time,
                size: 20,
                color: signed ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    signed ? 'Signed on ${_formatDateSafe(date)}' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: signed ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // ✅ Signature Image (agar signed hai to dikhao)
        if (signed && signatureBase64 != null && signatureBase64.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12, left: 36),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signature:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
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
    );
  }

  // ==================== Helper: Base64 to Image ====================
  Uint8List _base64ToImage(String base64String) {
    // Remove data URL prefix if present
    String cleanedBase64 = base64String;
    if (base64String.contains(',')) {
      cleanedBase64 = base64String.split(',').last;
    }
    return base64Decode(cleanedBase64);
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    bool isActive = _currentStep >= step;
    bool isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? primary : Colors.grey.shade300,
            border: isActive && !isCompleted
                ? Border.all(color: primary, width: 3)
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? primary : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ==================== REVIEW STEP ====================
  Widget _buildReviewStep() {
    final contract = contractController.contract.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContractHeader(contract),
          const SizedBox(height: 20),
          _buildPartiesInfo(contract),
          const SizedBox(height: 20),
          _buildProjectDetails(contract),
          const SizedBox(height: 20),
          _buildMilestones(contract),
          const SizedBox(height: 20),
          _buildTermsAndConditions(),
          const SizedBox(height: 20),
          _buildReviewActions(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==================== SIGN STEP ====================
  Widget _buildSignStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                  'Draw Your Signature',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use your finger or stylus to draw your signature in the box below',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: signatureController.isEmpty
                          ? Colors.grey.shade300
                          : primary,
                      width: 2,
                    ),
                  ),
                  child: Signature(
                    controller: signatureController,
                    height: 200,
                    backgroundColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSignatureControlButton(
                      icon: Icons.brush,
                      label: 'Draw',
                      onTap: () {},
                    ),
                    _buildSignatureControlButton(
                      icon: Icons.clear,
                      label: 'Clear',
                      onTap: _clearSignature,
                    ),
                    _buildSignatureControlButton(
                      icon: Icons.undo,
                      label: 'Undo',
                      onTap: () => signatureController.undo(),
                    ),
                    _buildSignatureControlButton(
                      icon: Icons.redo,
                      label: 'Redo',
                      onTap: () => signatureController.redo(),
                    ),
                  ],
                ),
                if (!signatureController.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Signature captured successfully',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => ElevatedButton(
                    onPressed: contractController.isProcessing.value
                        ? null
                        : _saveSignature,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: contractController.isProcessing.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(widget.isProposalSigning
                            ? 'Sign Proposal'
                            : 'Sign Contract'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  String _safeGetString(Map map, List<String> keys,
      {String defaultValue = 'Not signed'}) {
    try {
      var current = map;
      for (var key in keys) {
        if (current == null || current[key] == null) return defaultValue;
        current = current[key];
      }
      return current?.toString() ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  Widget _buildSignatureControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.grey.shade700),
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
      ),
    );
  }

  String _formatDateSafe(String dateString) {
    if (dateString.isEmpty || dateString == 'Not signed') return 'Not signed';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractHeader(dynamic contract) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  contractController
                      .getStatusText(_safeGetString(contract, ['status'])),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                _safeGetString(contract, ['contractNumber'], defaultValue: ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'CONTRACT AGREEMENT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This agreement is entered into on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartiesInfo(dynamic contract) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'PARTIES INVOLVED',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPartyCard(
                  'EMPLOYER',
                  _safeGetString(contract, ['employerId', 'firstName'],
                      defaultValue: 'You'),
                  _safeGetString(
                      contract, ['employerId', 'employerProfile', 'companyName']),
                  Icons.business,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.swap_horiz, color: Colors.grey),
              ),
              Expanded(
                child: _buildPartyCard(
                  'EMPLOYEE',
                  _safeGetString(contract, ['employeeId', 'firstName'],
                      defaultValue: 'Employee'),
                  _safeGetString(
                      contract, ['employeeId', 'employeeProfile', 'title'],
                      defaultValue: 'Freelancer'),
                  Icons.person,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard(
      String role, String name, String detail, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            role,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            detail,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetails(dynamic contract) {
    final project = contract['projectSnapshot'] ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'PROJECT DETAILS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 24),
          Text(
            project['title']?.toString() ?? 'Untitled Project',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project['description']?.toString() ?? 'No description',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                Icons.category,
                project['category']?.toString() ?? 'N/A',
              ),
              _buildInfoChip(
                Icons.timer,
                project['duration']?.toString() ?? 'N/A',
              ),
              _buildInfoChip(
                Icons.attach_money,
                'Total: \$${contractController.totalAmount}',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color color = primary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones(dynamic contract) {
    final milestones = contract['milestones'] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                'MILESTONES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${milestones.length} Milestones',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              if (index >= milestones.length) return const SizedBox.shrink();
              final milestone = milestones[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: primary),
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
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
                            milestone['title']?.toString() ??
                                'Milestone ${index + 1}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (milestone['description']
                                  ?.toString()
                                  .isNotEmpty ??
                              false)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                milestone['description'].toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${(milestone['amount'] ?? 0).toString()}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    final contract = contractController.contract.value!;
    final terms = contract['terms'] ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'TERMS & CONDITIONS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTermItem(
            'Revisions',
            '${terms['revisionCount'] ?? 2} free revisions within ${terms['revisionDays'] ?? 7} days',
            Icons.edit,
          ),
          _buildTermItem(
            'Intellectual Property',
            _getIpText(terms['intellectualProperty']?.toString()),
            Icons.copyright,
          ),
          _buildTermItem(
            'Confidentiality',
            terms['confidentialityRequired'] == true
                ? 'Confidentiality required'
                : 'No confidentiality clause',
            Icons.lock,
          ),
          _buildTermItem(
            'Termination',
            '${terms['terminationNotice'] ?? 7} days notice required',
            Icons.cancel,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                activeColor: primary,
              ),
              Expanded(
                child: Text(
                  'I have read and agree to all the terms and conditions mentioned above',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _agreeToTerms
                ? () {
                    setState(() {
                      _currentStep = 2;
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Continue to Sign'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Contract Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load contract details',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadContract,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _getIpText(String? ip) {
    switch (ip) {
      case 'EMPLOYER':
        return 'Transfers to employer after final payment';
      case 'EMPLOYEE':
        return 'Retained by employee';
      default:
        return 'Transfers on final payment';
    }
  }
}