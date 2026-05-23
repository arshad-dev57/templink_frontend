// screens/employer/employer_invoice_view_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:templink/Employeer/Controller/employer_invoice_controller.dart';
import 'package:templink/Employeer/model/Invoice_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class EmployerInvoiceViewScreen extends StatelessWidget {
  final String projectId;
  final controller = Get.put(EmployerInvoiceController());
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final dateFormat = DateFormat('MMM dd, yyyy');

  EmployerInvoiceViewScreen({
    Key? key,
    required this.projectId,
  }) : super(key: key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchInvoiceByProjectId(projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text(
          'TAX INVOICE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: _generateAndDownloadPDF,
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _sharePDF,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: _printInvoice,
            tooltip: 'Print',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.black54),
                SizedBox(height: 16),
                Text('Loading invoice...'),
              ],
            ),
          );
        }

        if (controller.invoice.value == null) {
          return _buildErrorState();
        }

        final invoice = controller.invoice.value!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildInvoicePaper(invoice),
          ),
        );
      }),
    );
  }

  // ==================== INVOICE PAPER (PRINTABLE) ====================
  Widget _buildInvoicePaper(Invoice invoice) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildInvoiceHeader(invoice),
          const Divider(height: 32, thickness: 1),
          
          // Company & Client Details
          _buildCompanyClientDetails(invoice),
          const Divider(height: 32, thickness: 1),
          
          // Invoice Details
          _buildInvoiceDetailsTable(invoice),
          const Divider(height: 32, thickness: 1),
          
          // Milestone Breakdown Table
          _buildMilestoneTable(invoice),
          const Divider(height: 32, thickness: 1),
          
          // Payment Summary
          _buildPaymentSummary(invoice),
          const Divider(height: 32, thickness: 1),
          
          // Bank Details
          _buildBankDetails(),
          const Divider(height: 32, thickness: 1),
          
          // Footer
          _buildFooter(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==================== INVOICE HEADER ====================
  Widget _buildInvoiceHeader(Invoice invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Text(
                'INVOICE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              invoice.invoiceNumber,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 60,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                ),
                child: const Center(
                  child: Text(
                    'Templink',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Templink Inc.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== COMPANY & CLIENT DETAILS ====================
  Widget _buildCompanyClientDetails(Invoice invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FROM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Templink Inc.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '123 Business Avenue',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Text(
                'Suite 100, New York, NY 10001',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              const Text(
                'support@templink.com',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Text(
                '+1 (555) 123-4567',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                invoice.employerCompany ?? invoice.employerName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                invoice.employerEmail,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              if (invoice.contractNumber != null) ...[
                const SizedBox(height: 2),
                Text(
                  invoice.contractNumber!,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                ),
                child: Text(
                  'Project ID: ${invoice.projectId.toString().substring(0, 8)}...',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== INVOICE DETAILS TABLE ====================
  Widget _buildInvoiceDetailsTable(Invoice invoice) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            _buildDetailCell('Invoice Date:', isHeader: true),
            _buildDetailCell(dateFormat.format(invoice.issuedAt)),
          ],
        ),
        TableRow(
          children: [
            _buildDetailCell('Due Date:', isHeader: true),
            _buildDetailCell(
              invoice.dueDate != null
                  ? dateFormat.format(invoice.dueDate!)
                  : dateFormat.format(invoice.issuedAt.add(const Duration(days: 15))),
            ),
          ],
        ),
        TableRow(
          children: [
            _buildDetailCell('Payment Method:', isHeader: true),
            _buildDetailCell(invoice.paymentMethod ?? 'Bank Transfer / Credit Card'),
          ],
        ),
        TableRow(
          children: [
            _buildDetailCell('Project Title:', isHeader: true),
            _buildDetailCell(invoice.projectTitle),
          ],
        ),
        TableRow(
          children: [
            _buildDetailCell('Freelancer:', isHeader: true),
            _buildDetailCell(invoice.employeeName),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: isHeader ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }

  // ==================== MILESTONE TABLE ====================
  Widget _buildMilestoneTable(Invoice invoice) {
    double subtotal = invoice.milestones.fold(0, (sum, m) => sum + m.amount);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MILESTONE BREAKDOWN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'AMOUNT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        
        // Milestone Items
        ...invoice.milestones.map((m) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  m.title,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  currencyFormat.format(m.amount),
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        )),
        
        const Divider(height: 24),
        
        // Totals
        _buildTotalLine('Subtotal', currencyFormat.format(subtotal)),
        const SizedBox(height: 6),
        _buildTotalLine('Platform Fee (10%)', currencyFormat.format(subtotal * 0.1)),
        const Divider(height: 16),
        _buildTotalLine('TOTAL', currencyFormat.format(subtotal * 1.1), isBold: true),
      ],
    );
  }

  Widget _buildTotalLine(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==================== PAYMENT SUMMARY ====================
  Widget _buildPaymentSummary(Invoice invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYMENT SUMMARY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            children: [
              _buildSummaryRow('Payment Status', 'PAID', isPaid: true),
              const SizedBox(height: 10),
              _buildSummaryRow('Transaction ID', 'TXN-${invoice.id.toString().substring(0, 8).toUpperCase()}'),
              const SizedBox(height: 10),
              _buildSummaryRow('Payment Date', dateFormat.format(invoice.issuedAt)),
              const SizedBox(height: 10),
              _buildSummaryRow('Payment Method', invoice.paymentMethod ?? 'Bank Transfer'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isPaid = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isPaid ? FontWeight.bold : FontWeight.normal,
            color: isPaid ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  // ==================== BANK DETAILS ====================
  Widget _buildBankDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BANK DETAILS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        _buildBankRow('Bank Name:', 'Chase Bank'),
        _buildBankRow('Account Name:', 'Templink Inc.'),
        _buildBankRow('Account Number:', '**** **** **** 1234'),
        _buildBankRow('Routing Number:', '021000021'),
        _buildBankRow('SWIFT Code:', 'CHASUS33'),
      ],
    );
  }

  Widget _buildBankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ==================== FOOTER ====================
  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'Thank you for your business!',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This is a computer generated invoice. No signature required.',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Templink Inc.',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'support@templink.com',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'www.templink.com',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== PDF GENERATION ====================
  Future<void> _generateAndDownloadPDF() async {
    try {
      final invoice = controller.invoice.value;
      if (invoice == null) {
        Get.snackbar('Error', 'No invoice data available');
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdf = await _generatePDF(invoice);
      final output = await getTemporaryDirectory();
      final filePath = '${output.path}/Invoice_${invoice.invoiceNumber}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdf);

      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        'Success',
        'Invoice downloaded successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () => _openFile(filePath),
          child: const Text('OPEN', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Failed to generate PDF: $e');
    }
  }

  Future<Uint8List> _generatePDF(Invoice invoice) async {
    final pdf = pw.Document();

    // Load fonts
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          double subtotal = invoice.milestones.fold(0, (sum, m) => sum + m.amount);
          double platformFee = subtotal * 0.1;
          double total = subtotal + platformFee;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 2),
                        ),
                        child: pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        invoice.invoiceNumber,
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Templink Inc.',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('123 Business Avenue', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('Suite 100, New York, NY 10001', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.SizedBox(height: 4),
                      pw.Text('support@templink.com', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('+1 (555) 123-4567', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Divider(),
              pw.SizedBox(height: 32),
              
              // Client Details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILL TO',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          invoice.employerCompany ?? invoice.employerName,
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(invoice.employerEmail, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
                        if (invoice.contractNumber != null) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(invoice.contractNumber!, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
                        ],
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INVOICE DETAILS',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        _buildPdfDetailRow('Invoice Date:', dateFormat.format(invoice.issuedAt)),
                        _buildPdfDetailRow('Due Date:', invoice.dueDate != null
                            ? dateFormat.format(invoice.dueDate!)
                            : dateFormat.format(invoice.issuedAt.add(const Duration(days: 15)))),
                        _buildPdfDetailRow('Project:', invoice.projectTitle),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Divider(),
              pw.SizedBox(height: 24),
              
              // Milestone Table
              pw.Text(
                'MILESTONE BREAKDOWN',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 12),
              
              // Table Header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'DESCRIPTION',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'AMOUNT',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Milestone Items
              ...invoice.milestones.map((m) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(m.title, style: pw.TextStyle(fontSize: 11)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        '\$${m.amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 11),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
              
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),
              
              // Totals
              _buildPdfTotalLine('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'),
              _buildPdfTotalLine('Platform Fee (10%):', '\$${platformFee.toStringAsFixed(2)}'),
              pw.SizedBox(height: 4),
              _buildPdfTotalLine('TOTAL:', '\$${total.toStringAsFixed(2)}', isBold: true),
              
              pw.SizedBox(height: 32),
              pw.Divider(),
              pw.SizedBox(height: 24),
              
              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for your business!',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'This is a computer generated invoice. No signature required.',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'Templink Inc. | support@templink.com | www.templink.com',
                      style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(label, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTotalLine(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No Invoice Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Invoice for this project has not been generated yet.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  Future<void> _sharePDF() async {
    try {
      final invoice = controller.invoice.value;
      if (invoice == null) return;

      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final pdf = await _generatePDF(invoice);
      final output = await getTemporaryDirectory();
      final filePath = '${output.path}/Invoice_${invoice.invoiceNumber}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdf);

      if (Get.isDialogOpen ?? false) Get.back();

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Invoice ${invoice.invoiceNumber} for project ${invoice.projectTitle}',
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Failed to share PDF: $e');
    }
  }

  Future<void> _printInvoice() async {
    try {
      final invoice = controller.invoice.value;
      if (invoice == null) return;

      final pdf = await _generatePDF(invoice);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to print: $e');
    }
  }

  void _openFile(String path) {
    // Open file functionality can be added here
    Get.snackbar('Info', 'File saved to: $path');
  }
}