// lib/Screens/crm/crm_email_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmEmailScreen extends StatefulWidget {
  const CrmEmailScreen({Key? key}) : super(key: key);

  @override
  State<CrmEmailScreen> createState() => _CrmEmailScreenState();
}

class _CrmEmailScreenState extends State<CrmEmailScreen> {
  bool _isLoading = true;
  List<CrmEmailRecord> _emails = [];

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    setState(() => _isLoading = true);
    final emails = await CrmApiService.getEmails();
    if (mounted) {
      setState(() {
        _emails = emails;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmHeader(
            title: 'Email Communication',
            subtitle: 'Real SMTP email communication history and outbound messages.',
            icon: Icons.email_outlined,
            onRefresh: _loadEmails,
            actionLabel: 'Compose Email',
            actionIcon: Icons.send,
            onAction: () async {
              final ok = await CrmDialogs.showComposeEmailDialog(context);
              if (ok == true) _loadEmails();
            },
          ),

          // Email Table
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                : _emails.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.mark_email_unread_outlined,
                        title: 'No Emails Sent Yet',
                        message: 'Compose and dispatch real emails directly to your leads and contacts via SMTP.',
                        actionLabel: 'Compose Email',
                        onAction: () async {
                          final ok = await CrmDialogs.showComposeEmailDialog(context);
                          if (ok == true) _loadEmails();
                        },
                      )
                    : Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(CrmTheme.bgLight),
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text('Recipient', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Delivery Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Sent Timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Details', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _emails.map((e) {
                                return DataRow(cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(e.toName.isNotEmpty ? e.toName : e.toEmail, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        if (e.toName.isNotEmpty) Text(e.toEmail, style: const TextStyle(fontSize: 12, color: CrmTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(e.subject, style: const TextStyle(fontWeight: FontWeight.w500))),
                                  DataCell(CrmBadge.status(e.status)),
                                  DataCell(Text('${e.sentAt.month}/${e.sentAt.day}/${e.sentAt.year} ${e.sentAt.hour}:${e.sentAt.minute.toString().padLeft(2, '0')}')),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: CrmTheme.primaryColor),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text(e.subject),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('To: ${e.toEmail}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 4),
                                                  Text('Status: ${e.status}', style: TextStyle(color: e.status == 'sent' ? CrmTheme.emerald : CrmTheme.rose)),
                                                  if (e.errorMessage.isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Text('Error: ${e.errorMessage}', style: const TextStyle(color: CrmTheme.rose, fontSize: 12)),
                                                  ],
                                                  const Divider(height: 16),
                                                  Text(e.bodyText),
                                                ],
                                              ),
                                            ),
                                            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
