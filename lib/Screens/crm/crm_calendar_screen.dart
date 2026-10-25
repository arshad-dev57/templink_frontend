// lib/Screens/crm/crm_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmCalendarScreen extends StatefulWidget {
  const CrmCalendarScreen({Key? key}) : super(key: key);

  @override
  State<CrmCalendarScreen> createState() => _CrmCalendarScreenState();
}

class _CrmCalendarScreenState extends State<CrmCalendarScreen> {
  bool _isLoading = true;
  List<CrmActivity> _events = [];
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final start = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final end = DateTime(_currentMonth.year, _currentMonth.month + 1, 0, 23, 59, 59);

    final events = await CrmApiService.getCalendarEvents(start: start, end: end);
    if (mounted) {
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Mon

    // Events on currently selected date
    final selectedEvents = _events.filterByDate(_selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmHeader(
            title: 'Calendar & Follow-ups',
            subtitle: 'Visualize upcoming customer meetings, task deadlines, and scheduled calls.',
            icon: Icons.calendar_month_outlined,
            onRefresh: _loadEvents,
            actionLabel: 'Schedule Event',
            actionIcon: Icons.add,
            onAction: () async {
              final ok = await CrmDialogs.showActivityDialog(context);
              if (ok == true) _loadEvents();
            },
          ),

          // Calendar Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: CrmTheme.cardDecoration,
            child: Column(
              children: [
                // Month Header Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getMonthName(_currentMonth.month) + ' ${_currentMonth.year}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CrmTheme.textPrimary),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                            });
                            _loadEvents();
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
                              _selectedDate = DateTime.now();
                            });
                            _loadEvents();
                          },
                          child: const Text('Today'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                            });
                            _loadEvents();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Days of week row
                Row(
                  children: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                const Divider(height: 20),

                // Calendar Grid
                _isLoading
                    ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: (firstWeekday - 1) + daysInMonth,
                        itemBuilder: (ctx, i) {
                          if (i < firstWeekday - 1) {
                            return const SizedBox.shrink();
                          }
                          final dayNum = i - (firstWeekday - 1) + 1;
                          final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                          final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
                          final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;
                          final dayEvents = _events.filterByDate(date);

                          return InkWell(
                            onTap: () => setState(() => _selectedDate = date),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSelected ? CrmTheme.primaryColor.withOpacity(0.12) : Colors.transparent,
                                border: isSelected ? Border.all(color: CrmTheme.primaryColor, width: 1.5) : (isToday ? Border.all(color: CrmTheme.sky) : null),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayNum.toString(),
                                    style: TextStyle(
                                      fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? CrmTheme.primaryColor : (isToday ? CrmTheme.sky : CrmTheme.textPrimary),
                                    ),
                                  ),
                                  if (dayEvents.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: dayEvents.take(3).map((e) {
                                        return Container(
                                          width: 5,
                                          height: 5,
                                          margin: const EdgeInsets.symmetric(horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: e.activityType == 'meeting' ? CrmTheme.emerald : (e.isOverdue ? CrmTheme.rose : CrmTheme.primaryColor),
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Events on selected day
          Container(
            padding: const EdgeInsets.all(20),
            decoration: CrmTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Events on ${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CrmTheme.textPrimary),
                ),
                const SizedBox(height: 14),
                if (selectedEvents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('No activities or meetings scheduled on this date.', style: TextStyle(color: CrmTheme.textMuted)),
                    ),
                  )
                else
                  ...selectedEvents.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CrmTheme.bgLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CrmTheme.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            e.activityType == 'meeting'
                                ? Icons.videocam
                                : (e.activityType == 'call' ? Icons.phone : Icons.task_alt),
                            color: CrmTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                if (e.description.isNotEmpty)
                                  Text(e.description, style: const TextStyle(fontSize: 12, color: CrmTheme.textSecondary)),
                              ],
                            ),
                          ),
                          CrmBadge.priority(e.priority),
                          const SizedBox(width: 8),
                          CrmBadge.status(e.status),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int m) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[m - 1];
  }
}

extension on List<CrmActivity> {
  List<CrmActivity> filterByDate(DateTime d) {
    return where((a) => a.dueDate.year == d.year && a.dueDate.month == d.month && a.dueDate.day == d.day).toList();
  }
}
