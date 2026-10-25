// lib/widgets/crm/crm_badge.dart
import 'package:flutter/material.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmBadge extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final IconData? icon;

  const CrmBadge({
    Key? key,
    required this.text,
    required this.textColor,
    required this.bgColor,
    this.icon,
  }) : super(key: key);

  factory CrmBadge.status(String status) {
    Color tc = CrmTheme.textSecondary;
    Color bc = CrmTheme.borderLight;
    final s = status.toLowerCase();

    if (['qualified', 'converted', 'active', 'completed', 'resolved', 'closed_won', 'accepted'].contains(s)) {
      tc = CrmTheme.emerald;
      bc = CrmTheme.emeraldSoft;
    } else if (['new', 'open', 'scheduled', 'in_progress', 'draft'].contains(s)) {
      tc = CrmTheme.sky;
      bc = CrmTheme.skySoft;
    } else if (['proposal_sent', 'negotiation', 'contacted', 'waiting_customer'].contains(s)) {
      tc = CrmTheme.amber;
      bc = CrmTheme.amberSoft;
    } else if (['lost', 'unqualified', 'cancelled', 'inactive', 'closed_lost', 'rejected', 'expired'].contains(s)) {
      tc = CrmTheme.rose;
      bc = CrmTheme.roseSoft;
    }

    String label = status.replaceAll('_', ' ').toUpperCase();
    return CrmBadge(text: label, textColor: tc, bgColor: bc);
  }

  factory CrmBadge.priority(String priority) {
    Color tc = CrmTheme.textSecondary;
    Color bc = CrmTheme.borderLight;
    final p = priority.toLowerCase();

    if (['urgent', 'critical'].contains(p)) {
      tc = CrmTheme.rose;
      bc = CrmTheme.roseSoft;
    } else if (p == 'high') {
      tc = CrmTheme.amber;
      bc = CrmTheme.amberSoft;
    } else if (p == 'medium') {
      tc = CrmTheme.sky;
      bc = CrmTheme.skySoft;
    } else {
      tc = CrmTheme.textSecondary;
      bc = CrmTheme.borderLight;
    }

    return CrmBadge(text: priority.toUpperCase(), textColor: tc, bgColor: bc);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
