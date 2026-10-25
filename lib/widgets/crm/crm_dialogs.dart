// lib/widgets/crm/crm_dialogs.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmDialogs {
  // Helper to show styled modal
  static Future<T?> _showDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    double maxWidth = 540,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: CrmTheme.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: CrmTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: CrmTheme.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 1. CREATE / EDIT LEAD DIALOG ====================
  static Future<bool?> showLeadDialog(
    BuildContext context, {
    CrmLead? lead,
    List<CrmTeamMember> teamMembers = const [],
  }) {
    final nameCtrl = TextEditingController(text: lead?.name ?? '');
    final emailCtrl = TextEditingController(text: lead?.email ?? '');
    final phoneCtrl = TextEditingController(text: lead?.phone ?? '');
    final companyCtrl = TextEditingController(text: lead?.company ?? '');
    final jobTitleCtrl = TextEditingController(text: lead?.jobTitle ?? '');
    final valueCtrl = TextEditingController(
      text: lead != null && lead.estimatedDealValue > 0
          ? lead.estimatedDealValue.toStringAsFixed(0)
          : '',
    );
    final descCtrl = TextEditingController(text: lead?.description ?? '');

    String status = lead?.status ?? 'new';
    String priority = lead?.priority ?? 'medium';
    String source = lead?.leadSource ?? 'website';
    String? assignedToId = lead?.assignedTo?.id;

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: lead == null ? 'Create New Lead' : 'Edit Lead',
      content: StatefulBuilder(
        builder: (ctx, setState) => Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: CrmTheme.inputDecoration(hintText: 'Full Name *', labelText: 'Lead Name *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: emailCtrl,
                      decoration: CrmTheme.inputDecoration(hintText: 'Email address', labelText: 'Email'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: phoneCtrl,
                      decoration: CrmTheme.inputDecoration(hintText: 'Phone number', labelText: 'Phone'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: companyCtrl,
                      decoration: CrmTheme.inputDecoration(hintText: 'Company name', labelText: 'Company'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: jobTitleCtrl,
                      decoration: CrmTheme.inputDecoration(hintText: 'Job title', labelText: 'Job Title'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: status,
                      decoration: CrmTheme.inputDecoration(hintText: 'Status', labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'new', child: Text('New')),
                        DropdownMenuItem(value: 'contacted', child: Text('Contacted')),
                        DropdownMenuItem(value: 'qualified', child: Text('Qualified')),
                        DropdownMenuItem(value: 'proposal_sent', child: Text('Proposal Sent')),
                        DropdownMenuItem(value: 'negotiation', child: Text('Negotiation')),
                        DropdownMenuItem(value: 'converted', child: Text('Converted')),
                        DropdownMenuItem(value: 'lost', child: Text('Lost')),
                        DropdownMenuItem(value: 'unqualified', child: Text('Unqualified')),
                      ],
                      onChanged: (v) => setState(() => status = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: priority,
                      decoration: CrmTheme.inputDecoration(hintText: 'Priority', labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                        DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                      ],
                      onChanged: (v) => setState(() => priority = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: source,
                      decoration: CrmTheme.inputDecoration(hintText: 'Source', labelText: 'Lead Source'),
                      items: const [
                        DropdownMenuItem(value: 'website', child: Text('Website')),
                        DropdownMenuItem(value: 'referral', child: Text('Referral')),
                        DropdownMenuItem(value: 'linkedin', child: Text('LinkedIn')),
                        DropdownMenuItem(value: 'cold_outreach', child: Text('Cold Outreach')),
                        DropdownMenuItem(value: 'advertisement', child: Text('Advertisement')),
                        DropdownMenuItem(value: 'event', child: Text('Event')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => source = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: valueCtrl,
                      keyboardType: TextInputType.number,
                      decoration: CrmTheme.inputDecoration(hintText: 'Deal Value (\$)', labelText: 'Estimated Value (\$)'),
                    ),
                  ),
                ],
              ),
              if (teamMembers.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: assignedToId,
                  decoration: CrmTheme.inputDecoration(hintText: 'Assign to', labelText: 'Assigned Member'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Unassigned')),
                    ...teamMembers.map(
                      (m) => DropdownMenuItem(value: m.id, child: Text('${m.fullName} (${m.role})')),
                    ),
                  ],
                  onChanged: (v) => setState(() => assignedToId = v),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: CrmTheme.inputDecoration(hintText: 'Additional notes or requirements...', labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: isSaving ? null : () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: CrmTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: CrmTheme.textSecondary)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setState(() => isSaving = true);
                            final payload = {
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'company': companyCtrl.text.trim(),
                              'jobTitle': jobTitleCtrl.text.trim(),
                              'status': status,
                              'priority': priority,
                              'leadSource': source,
                              'estimatedDealValue': double.tryParse(valueCtrl.text.trim()) ?? 0,
                              'description': descCtrl.text.trim(),
                              if (assignedToId != null) 'assignedTo': assignedToId,
                            };

                            bool ok = false;
                            if (lead == null) {
                              ok = await CrmApiService.createLead(payload);
                            } else {
                              ok = await CrmApiService.updateLead(lead.id, payload);
                            }
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop(ok);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CrmTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(lead == null ? 'Create Lead' : 'Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 2. CONVERT LEAD DIALOG ====================
  static Future<bool?> showConvertLeadDialog(BuildContext context, CrmLead lead) {
    final dealTitleCtrl = TextEditingController(text: '${lead.company.isNotEmpty ? lead.company : lead.name} - Opportunity');
    final amountCtrl = TextEditingController(text: lead.estimatedDealValue > 0 ? lead.estimatedDealValue.toStringAsFixed(0) : '5000');
    bool createContact = true;
    bool createCompany = lead.company.isNotEmpty;
    bool createDeal = true;
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: 'Convert Lead: ${lead.name}',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Converting this lead will automatically generate synchronized records in your CRM:',
              style: TextStyle(fontSize: 13, color: CrmTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Create Contact', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(lead.email.isNotEmpty ? lead.email : lead.name, style: const TextStyle(fontSize: 12, color: CrmTheme.textMuted)),
              value: createContact,
              activeColor: CrmTheme.primaryColor,
              onChanged: (v) => setState(() => createContact = v!),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Create Company / Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(lead.company.isNotEmpty ? lead.company : 'No company specified on lead', style: const TextStyle(fontSize: 12, color: CrmTheme.textMuted)),
              value: createCompany,
              activeColor: CrmTheme.primaryColor,
              onChanged: lead.company.isNotEmpty ? (v) => setState(() => createCompany = v!) : null,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Create Deal / Opportunity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              value: createDeal,
              activeColor: CrmTheme.primaryColor,
              onChanged: (v) => setState(() => createDeal = v!),
            ),
            if (createDeal) ...[
              const SizedBox(height: 10),
              TextField(
                controller: dealTitleCtrl,
                decoration: CrmTheme.inputDecoration(hintText: 'Deal title', labelText: 'Deal Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: CrmTheme.inputDecoration(hintText: 'Amount (\$)', labelText: 'Deal Amount (\$)'),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: isSaving ? null : () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() => isSaving = true);
                          final ok = await CrmApiService.convertLead(lead.id, {
                            'createContact': createContact,
                            'createCompany': createCompany,
                            'createDeal': createDeal,
                            'dealTitle': dealTitleCtrl.text.trim(),
                            'dealAmount': double.tryParse(amountCtrl.text.trim()) ?? 0,
                          });
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop(ok);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CrmTheme.emerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirm Conversion'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 3. CONTACT DIALOG ====================
  static Future<bool?> showContactDialog(BuildContext context, {CrmContact? contact, List<CrmCompany> companies = const []}) {
    final fnCtrl = TextEditingController(text: contact?.firstName ?? '');
    final lnCtrl = TextEditingController(text: contact?.lastName ?? '');
    final emailCtrl = TextEditingController(text: contact?.email ?? '');
    final phoneCtrl = TextEditingController(text: contact?.phone ?? '');
    final jobTitleCtrl = TextEditingController(text: contact?.jobTitle ?? '');
    String? companyId = contact?.companyId.isNotEmpty == true ? contact?.companyId : null;
    String stage = contact?.lifecycleStage ?? 'lead';
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: contact == null ? 'New Contact' : 'Edit Contact',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fnCtrl,
                    decoration: CrmTheme.inputDecoration(hintText: 'First Name *', labelText: 'First Name *'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: lnCtrl,
                    decoration: CrmTheme.inputDecoration(hintText: 'Last Name', labelText: 'Last Name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: CrmTheme.inputDecoration(hintText: 'Email Address', labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phoneCtrl,
                    decoration: CrmTheme.inputDecoration(hintText: 'Phone', labelText: 'Phone'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: jobTitleCtrl,
                    decoration: CrmTheme.inputDecoration(hintText: 'Job Title', labelText: 'Job Title'),
                  ),
                ),
              ],
            ),
            if (companies.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: companyId,
                decoration: CrmTheme.inputDecoration(hintText: 'Associated Company', labelText: 'Company'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No Company')),
                  ...companies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => companyId = v),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: stage,
              decoration: CrmTheme.inputDecoration(hintText: 'Lifecycle Stage', labelText: 'Lifecycle Stage'),
              items: const [
                DropdownMenuItem(value: 'lead', child: Text('Lead')),
                DropdownMenuItem(value: 'subscriber', child: Text('Subscriber')),
                DropdownMenuItem(value: 'opportunity', child: Text('Opportunity')),
                DropdownMenuItem(value: 'customer', child: Text('Customer')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => stage = v!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (fnCtrl.text.trim().isEmpty) return;
                          setState(() => isSaving = true);
                          final payload = {
                            'firstName': fnCtrl.text.trim(),
                            'lastName': lnCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                            'jobTitle': jobTitleCtrl.text.trim(),
                            'companyId': companyId,
                            'lifecycleStage': stage,
                          };
                          bool ok = false;
                          if (contact == null) {
                            ok = await CrmApiService.createContact(payload);
                          } else {
                            ok = await CrmApiService.updateContact(contact.id, payload);
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop(ok);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.primaryColor, foregroundColor: Colors.white),
                  child: Text(contact == null ? 'Create Contact' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 4. COMPANY DIALOG ====================
  static Future<bool?> showCompanyDialog(BuildContext context, {CrmCompany? company}) {
    final nameCtrl = TextEditingController(text: company?.name ?? '');
    final websiteCtrl = TextEditingController(text: company?.website ?? '');
    final industryCtrl = TextEditingController(text: company?.industry ?? '');
    final phoneCtrl = TextEditingController(text: company?.phone ?? '');
    final revenueCtrl = TextEditingController(text: company != null && company.annualRevenue > 0 ? company.annualRevenue.toStringAsFixed(0) : '');
    String type = company?.type ?? 'prospect';
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: company == null ? 'New Company' : 'Edit Company',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          children: [
            TextField(controller: nameCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Company Name *', labelText: 'Company Name *')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: websiteCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Website (e.g. acme.com)', labelText: 'Website'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: industryCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Industry', labelText: 'Industry'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: phoneCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Phone', labelText: 'Phone'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: revenueCtrl, keyboardType: TextInputType.number, decoration: CrmTheme.inputDecoration(hintText: 'Annual Revenue (\$)'))),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              decoration: CrmTheme.inputDecoration(hintText: 'Type', labelText: 'Account Type'),
              items: const [
                DropdownMenuItem(value: 'prospect', child: Text('Prospect')),
                DropdownMenuItem(value: 'customer', child: Text('Customer')),
                DropdownMenuItem(value: 'partner', child: Text('Partner')),
                DropdownMenuItem(value: 'vendor', child: Text('Vendor')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => type = v!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isEmpty) return;
                          setState(() => isSaving = true);
                          final payload = {
                            'name': nameCtrl.text.trim(),
                            'website': websiteCtrl.text.trim(),
                            'industry': industryCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                            'annualRevenue': double.tryParse(revenueCtrl.text.trim()) ?? 0,
                            'type': type,
                          };
                          bool ok = false;
                          if (company == null) {
                            ok = await CrmApiService.createCompany(payload);
                          } else {
                            ok = await CrmApiService.updateCompany(company.id, payload);
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop(ok);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.primaryColor, foregroundColor: Colors.white),
                  child: Text(company == null ? 'Create Company' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 5. DEAL DIALOG ====================
  static Future<bool?> showDealDialog(
    BuildContext context, {
    CrmDeal? deal,
    List<CrmCompany> companies = const [],
    List<CrmContact> contacts = const [],
  }) {
    final titleCtrl = TextEditingController(text: deal?.title ?? '');
    final amountCtrl = TextEditingController(text: deal != null ? deal.amount.toStringAsFixed(0) : '');
    String stage = deal?.stage ?? 'lead_in';
    String? compId = deal?.companyId.isNotEmpty == true ? deal?.companyId : null;
    String? contId = deal?.contactId.isNotEmpty == true ? deal?.contactId : null;
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: deal == null ? 'New Deal' : 'Edit Deal',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          children: [
            TextField(controller: titleCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Deal Title *', labelText: 'Deal Title *')),
            const SizedBox(height: 12),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: CrmTheme.inputDecoration(hintText: 'Deal Value (\$) *', labelText: 'Amount (\$) *')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: stage,
              decoration: CrmTheme.inputDecoration(hintText: 'Stage', labelText: 'Pipeline Stage'),
              items: const [
                DropdownMenuItem(value: 'lead_in', child: Text('Lead In')),
                DropdownMenuItem(value: 'contact_made', child: Text('Contact Made')),
                DropdownMenuItem(value: 'needs_discovery', child: Text('Needs Discovery')),
                DropdownMenuItem(value: 'proposal_sent', child: Text('Proposal Sent')),
                DropdownMenuItem(value: 'negotiation', child: Text('Negotiation')),
                DropdownMenuItem(value: 'closed_won', child: Text('Closed Won')),
                DropdownMenuItem(value: 'closed_lost', child: Text('Closed Lost')),
              ],
              onChanged: (v) => setState(() => stage = v!),
            ),
            if (companies.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: compId,
                decoration: CrmTheme.inputDecoration(hintText: 'Company', labelText: 'Associated Company'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No Company')),
                  ...companies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => compId = v),
              ),
            ],
            if (contacts.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: contId,
                decoration: CrmTheme.inputDecoration(hintText: 'Primary Contact', labelText: 'Primary Contact'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No Contact')),
                  ...contacts.map((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName))),
                ],
                onChanged: (v) => setState(() => contId = v),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (titleCtrl.text.trim().isEmpty) return;
                          setState(() => isSaving = true);
                          final payload = {
                            'title': titleCtrl.text.trim(),
                            'amount': double.tryParse(amountCtrl.text.trim()) ?? 0,
                            'stage': stage,
                            'companyId': compId,
                            'contactId': contId,
                          };
                          bool ok = false;
                          if (deal == null) {
                            ok = await CrmApiService.createDeal(payload);
                          } else {
                            ok = await CrmApiService.updateDeal(deal.id, payload);
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop(ok);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.primaryColor, foregroundColor: Colors.white),
                  child: Text(deal == null ? 'Create Deal' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 6. ACTIVITY / TASK / MEETING DIALOG ====================
  static Future<bool?> showActivityDialog(
    BuildContext context, {
    String defaultType = 'task',
    List<CrmTeamMember> teamMembers = const [],
  }) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    String type = defaultType;
    String priority = 'medium';
    String? assignedToId;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: type == 'meeting' ? 'Schedule Meeting' : (type == 'call' ? 'Log Call' : 'New Task / Activity'),
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          children: [
            DropdownButtonFormField<String>(
              value: type,
              decoration: CrmTheme.inputDecoration(hintText: 'Type', labelText: 'Activity Type'),
              items: const [
                DropdownMenuItem(value: 'task', child: Text('Task')),
                DropdownMenuItem(value: 'call', child: Text('Call')),
                DropdownMenuItem(value: 'meeting', child: Text('Meeting')),
                DropdownMenuItem(value: 'follow_up', child: Text('Follow-Up')),
              ],
              onChanged: (v) => setState(() => type = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: titleCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Title *', labelText: 'Title *')),
            if (type == 'meeting') ...[
              const SizedBox(height: 12),
              TextField(controller: linkCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Meeting link (Google Meet, Zoom, etc.)', labelText: 'Meeting Link')),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: priority,
                    decoration: CrmTheme.inputDecoration(hintText: 'Priority', labelText: 'Priority'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                    ],
                    onChanged: (v) => setState(() => priority = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 7)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text('${selectedDate.month}/${selectedDate.day}/${selectedDate.year}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: CrmTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            if (teamMembers.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: assignedToId,
                decoration: CrmTheme.inputDecoration(hintText: 'Assign to', labelText: 'Assigned Member'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Assign to myself')),
                  ...teamMembers.map((m) => DropdownMenuItem(value: m.id, child: Text(m.fullName))),
                ],
                onChanged: (v) => setState(() => assignedToId = v),
              ),
            ],
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, decoration: CrmTheme.inputDecoration(hintText: 'Description or agenda', labelText: 'Description')),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (titleCtrl.text.trim().isEmpty) return;
                          setState(() => isSaving = true);
                          final ok = await CrmApiService.createActivity({
                            'activityType': type,
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'priority': priority,
                            'dueDate': selectedDate.toIso8601String(),
                            'meetingLink': linkCtrl.text.trim(),
                            if (assignedToId != null) 'assignedTo': assignedToId,
                          });
                          if (ctx.mounted) Navigator.of(ctx).pop(ok);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.primaryColor, foregroundColor: Colors.white),
                  child: const Text('Save Activity'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 7. NOTE DIALOG ====================
  static Future<bool?> showNoteDialog(BuildContext context, {String relatedToType = 'general', String relatedToId = ''}) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool isPinned = false;
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: 'Add Note',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          children: [
            TextField(controller: titleCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Title (optional)', labelText: 'Note Title')),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: CrmTheme.inputDecoration(hintText: 'Write your notes or internal comments here...', labelText: 'Note Content *'),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pin this note to the top', style: TextStyle(fontSize: 13)),
              value: isPinned,
              activeColor: CrmTheme.primaryColor,
              onChanged: (v) => setState(() => isPinned = v!),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (contentCtrl.text.trim().isEmpty) return;
                          setState(() => isSaving = true);
                          final ok = await CrmApiService.createNote({
                            'title': titleCtrl.text.trim(),
                            'content': contentCtrl.text.trim(),
                            'isPinned': isPinned,
                            'relatedToType': relatedToType,
                            if (relatedToId.isNotEmpty) 'relatedToId': relatedToId,
                          });
                          if (ctx.mounted) Navigator.of(ctx).pop(ok);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.primaryColor, foregroundColor: Colors.white),
                  child: const Text('Save Note'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 8. COMPOSE EMAIL DIALOG ====================
  static Future<bool?> showComposeEmailDialog(BuildContext context, {String recipientEmail = '', String recipientName = ''}) {
    final toCtrl = TextEditingController(text: recipientEmail);
    final subjectCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool isSending = false;

    return _showDialog<bool>(
      context: context,
      title: 'Compose Email',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          children: [
            TextField(
              controller: toCtrl,
              decoration: CrmTheme.inputDecoration(hintText: 'recipient@example.com', labelText: 'To *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subjectCtrl,
              decoration: CrmTheme.inputDecoration(hintText: 'Subject line', labelText: 'Subject *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              maxLines: 6,
              decoration: CrmTheme.inputDecoration(hintText: 'Write message...', labelText: 'Message Body *'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: isSending
                      ? null
                      : () async {
                          if (toCtrl.text.trim().isEmpty || subjectCtrl.text.trim().isEmpty) return;
                          setState(() => isSending = true);
                          final result = await CrmApiService.sendEmail({
                            'toEmail': toCtrl.text.trim(),
                            'toName': recipientName,
                            'subject': subjectCtrl.text.trim(),
                            'bodyText': bodyCtrl.text.trim(),
                          });
                          if (ctx.mounted) {
                            if (result['success'] == true) {
                              Get.snackbar('Success', 'Email sent successfully via SMTP!', backgroundColor: CrmTheme.emeraldSoft);
                              Navigator.of(ctx).pop(true);
                            } else {
                              setState(() => isSending = false);
                              Get.snackbar('Error', result['message'] ?? 'Failed to send', backgroundColor: CrmTheme.roseSoft);
                            }
                          }
                        },
                  icon: const Icon(Icons.send, size: 16),
                  label: isSending ? const Text('Sending...') : const Text('Send Email'),
                  style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.primaryColor, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 9. PRODUCT DIALOG ====================
  static Future<bool?> showProductDialog(BuildContext context, {CrmProduct? product}) {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    final priceCtrl = TextEditingController(text: product != null ? product.unitPrice.toStringAsFixed(2) : '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    String type = product?.type ?? 'service';
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: product == null ? 'New Product / Service' : 'Edit Product / Service',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          children: [
            TextField(controller: nameCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Name *', labelText: 'Item Name *')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: skuCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Auto if blank', labelText: 'SKU'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: CrmTheme.inputDecoration(hintText: '0.00', labelText: 'Unit Price (\$) *'))),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              decoration: CrmTheme.inputDecoration(hintText: 'Type', labelText: 'Item Type'),
              items: const [
                DropdownMenuItem(value: 'service', child: Text('Service')),
                DropdownMenuItem(value: 'product', child: Text('Product')),
              ],
              onChanged: (v) => setState(() => type = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, decoration: CrmTheme.inputDecoration(hintText: 'Description or specifications', labelText: 'Description')),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                          setState(() => isSaving = true);
                          final payload = {
                            'name': nameCtrl.text.trim(),
                            if (skuCtrl.text.trim().isNotEmpty) 'sku': skuCtrl.text.trim(),
                            'unitPrice': double.tryParse(priceCtrl.text.trim()) ?? 0,
                            'type': type,
                            'description': descCtrl.text.trim(),
                          };
                          bool ok = false;
                          if (product == null) {
                            ok = await CrmApiService.createProduct(payload);
                          } else {
                            ok = await CrmApiService.updateProduct(product.id, payload);
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop(ok);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.primaryColor, foregroundColor: Colors.white),
                  child: Text(product == null ? 'Save Item' : 'Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 10. CASE / SUPPORT DIALOG ====================
  static Future<bool?> showCaseDialog(BuildContext context, {CrmCase? crmCase}) {
    final titleCtrl = TextEditingController(text: crmCase?.title ?? '');
    final descCtrl = TextEditingController(text: crmCase?.description ?? '');
    String priority = crmCase?.priority ?? 'medium';
    String type = crmCase?.type ?? 'problem';
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: crmCase == null ? 'Create Support Case' : 'Edit Support Case',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          children: [
            TextField(controller: titleCtrl, decoration: CrmTheme.inputDecoration(hintText: 'Subject or issue *', labelText: 'Case Title *')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: priority,
                    decoration: CrmTheme.inputDecoration(hintText: 'Priority', labelText: 'Priority'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'critical', child: Text('Critical')),
                    ],
                    onChanged: (v) => setState(() => priority = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: type,
                    decoration: CrmTheme.inputDecoration(hintText: 'Type', labelText: 'Issue Type'),
                    items: const [
                      DropdownMenuItem(value: 'problem', child: Text('Problem')),
                      DropdownMenuItem(value: 'question', child: Text('Question')),
                      DropdownMenuItem(value: 'incident', child: Text('Incident')),
                      DropdownMenuItem(value: 'feature_request', child: Text('Feature Request')),
                      DropdownMenuItem(value: 'billing', child: Text('Billing')),
                    ],
                    onChanged: (v) => setState(() => type = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 4, decoration: CrmTheme.inputDecoration(hintText: 'Provide detailed information about the customer request...', labelText: 'Description')),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (titleCtrl.text.trim().isEmpty) return;
                          setState(() => isSaving = true);
                          final ok = await CrmApiService.createCase({
                            'title': titleCtrl.text.trim(),
                            'priority': priority,
                            'type': type,
                            'description': descCtrl.text.trim(),
                          });
                          if (ctx.mounted) Navigator.of(ctx).pop(ok);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.primaryColor, foregroundColor: Colors.white),
                  child: const Text('Submit Case'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 11. QUOTATION DIALOG ====================
  static Future<bool?> showQuotationDialog(BuildContext context, {List<CrmProduct> availableProducts = const []}) {
    final titleCtrl = TextEditingController();
    final items = <Map<String, dynamic>>[
      {'name': 'Professional Consulting Service', 'quantity': 1, 'unitPrice': 1500.0, 'discount': 0.0, 'taxRate': 5.0}
    ];
    bool isSaving = false;

    return _showDialog<bool>(
      context: context,
      title: 'New Quotation / Proposal',
      maxWidth: 640,
      content: StatefulBuilder(
        builder: (ctx, setState) {
          double subtotal = 0;
          double totalDisc = 0;
          double totalTax = 0;
          for (var item in items) {
            final base = (item['quantity'] as num) * (item['unitPrice'] as num);
            final disc = (base * (item['discount'] as num)) / 100;
            final tax = ((base - disc) * (item['taxRate'] as num)) / 100;
            subtotal += base;
            totalDisc += disc;
            totalTax += tax;
          }
          final grandTotal = subtotal - totalDisc + totalTax;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: CrmTheme.inputDecoration(hintText: 'e.g. Website Redesign Proposal', labelText: 'Proposal Title *'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Line Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        items.add({'name': 'Item #${items.length + 1}', 'quantity': 1, 'unitPrice': 500.0, 'discount': 0.0, 'taxRate': 0.0});
                      });
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              ...items.asMap().entries.map((entry) {
                final idx = entry.key;
                final it = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CrmTheme.borderLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: it['name'].toString(),
                              decoration: const InputDecoration(labelText: 'Description', isDense: true),
                              onChanged: (v) => it['name'] = v,
                            ),
                          ),
                          if (items.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: CrmTheme.rose),
                              onPressed: () => setState(() => items.removeAt(idx)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: it['quantity'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Qty', isDense: true),
                              onChanged: (v) => setState(() => it['quantity'] = int.tryParse(v) ?? 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: it['unitPrice'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Price (\$)', isDense: true),
                              onChanged: (v) => setState(() => it['unitPrice'] = double.tryParse(v) ?? 0),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: it['discount'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Disc %', isDense: true),
                              onChanged: (v) => setState(() => it['discount'] = double.tryParse(v) ?? 0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CrmTheme.bgLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CrmTheme.border),
                ),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Subtotal:', style: TextStyle(fontSize: 13, color: CrmTheme.textSecondary)),
                      Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Discounts:', style: TextStyle(fontSize: 13, color: CrmTheme.textSecondary)),
                      Text('-\$${totalDisc.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, color: CrmTheme.rose)),
                    ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Taxes:', style: TextStyle(fontSize: 13, color: CrmTheme.textSecondary)),
                      Text('+\$${totalTax.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                    const Divider(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Grand Total:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text('\$${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CrmTheme.primaryColor)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (titleCtrl.text.trim().isEmpty) return;
                            setState(() => isSaving = true);
                            final ok = await CrmApiService.createQuotation({
                              'title': titleCtrl.text.trim(),
                              'items': items,
                            });
                            if (ctx.mounted) Navigator.of(ctx).pop(ok);
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.primaryColor, foregroundColor: Colors.white),
                    child: const Text('Create Quotation'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
