// lib/widgets/crm/crm_header.dart
import 'package:flutter/material.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final VoidCallback? onRefresh;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final Widget? trailing;

  const CrmHeader({
    Key? key,
    required this.title,
    this.subtitle = '',
    this.icon,
    this.onRefresh,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;

          final titleSection = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CrmTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: CrmTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: CrmTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CrmTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );

          final actionsSection = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) trailing!,
              if (onRefresh != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onRefresh,
                  tooltip: 'Refresh data',
                  icon: const Icon(Icons.refresh, size: 20, color: CrmTheme.textSecondary),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: CrmTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon ?? Icons.add, size: 18),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CrmTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleSection,
                const SizedBox(height: 12),
                actionsSection,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleSection,
              actionsSection,
            ],
          );
        },
      ),
    );
  }
}
