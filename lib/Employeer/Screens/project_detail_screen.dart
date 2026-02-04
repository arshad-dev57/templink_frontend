  import 'package:flutter/material.dart';
  import 'package:templink/Utils/colors.dart';

  class ProjectDetailsScreen extends StatelessWidget {
    const ProjectDetailsScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Project Details',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enterprise SaaS UI/UX\nOverhaul',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Posted 2 hours ago  •  UI/UX Design',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Budget, Duration, Level, Status
              _infoCard(
                icon: Icons.attach_money,
                iconColor: primary,
                label: 'BUDGET',
                value: '\$5k - \$10k',
              ),
              const SizedBox(height: 12),
              _infoCard(
                icon: Icons.access_time,
                iconColor: primary,
                label: 'DURATION',
                value: '3-6 months',
              ),
              const SizedBox(height: 12),
              _infoCard(
                icon: Icons.military_tech_outlined,
                iconColor: primary,
                label: 'LEVEL',
                value: 'Expert',
              ),
              const SizedBox(height: 12),
              _infoCard(
                icon: Icons.timeline,
                iconColor: Colors.orange,
                label: 'STATUS',
                value: 'Active',
              ),
              const SizedBox(height: 12),

              // Project Tags
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _tagChip('UI/UX'),
                    _tagChip('SaaS'),
                    _tagChip('B2B'),
                    _tagChip('Dashboard'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Project Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We are seeking a seasoned UI/UX Designer to lead the complete visual and functional redesign of our enterprise B2B SaaS platform. The platform currently manages complex supply chain logistics and requires a modern, intuitive interface that simplifies data-dense workflows.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The ideal candidate has a strong portfolio in complex dashboards, design systems, and user research. You will collaborate directly with our CTO and Product Lead to redefine the user journey from the ground up.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Deliverables
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deliverables',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _deliverableItem('Comprehensive UX Audit & Research Report'),
                    const SizedBox(height: 12),
                    _deliverableItem('Interactive High-Fidelity Figma Prototypes'),
                    const SizedBox(height: 12),
                    _deliverableItem('Atomic Design System & Component Library'),
                    const SizedBox(height: 12),
                    _deliverableItem('Usability Testing & Iteration Documentation'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Required Skills
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required Technical Skills',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        _skillChip('Figma'),
                        _skillChip('Design Systems'),
                        _skillChip('User Research'),
                        _skillChip('SaaS Architecture'),
                        _skillChip('Accessibility (WCAG)'),
                        _skillChip('Data Visualization'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Project Progress
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project Progress',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: 0.6, // 60% progress
                      backgroundColor: Colors.grey.shade200,
                      color: primary,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 4),
                    const Text('60% Complete', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Attachments
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attachments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _attachmentItem('Project Brief.pdf'),
                    const SizedBox(height: 8),
                    _attachmentItem('Reference Designs.zip'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Milestones
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Milestones',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _milestoneItem('UX Audit', 'Due Jan 30', true),
                    const SizedBox(height: 8),
                    _milestoneItem('High-Fidelity Prototypes', 'Due Feb 15', false),
                  ],
                ),
              ),
              const SizedBox(height: 12),


              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About the Client',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage('https://via.placeholder.com/48'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    'LogiStream Solutions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.verified, color: Colors.blue, size: 16),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < 4 ? Icons.star : Icons.star_half,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '4.9 of 12 reviews',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text('San Francisco, USA', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Spend', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(Icons.monetization_on, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text('\$200k+', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Activity on this Job
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity on this Job',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    _activityRow('Proposals', '5 to 10'),
                    const SizedBox(height: 12),
                    _activityRow('Interviewing', '2'),
                    const SizedBox(height: 12),
                    _activityRow('Invites Sent', '4'),
                    const SizedBox(height: 12),
                    _activityRow('Last viewed by client', '14 minutes ago'),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for bottom buttons
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: const Icon(Icons.favorite_border, color: Colors.black87, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Apply Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- Reusable Widgets ---

    Widget _infoCard({required IconData icon, required Color iconColor, required String label, required String value}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ],
        ),
      );
    }

    Widget _deliverableItem(String text) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5))),
        ],
      );
    }

    Widget _skillChip(String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.w500)),
      );
    }

    Widget _tagChip(String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500)),
      );
    }

    Widget _activityRow(String label, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
        ],
      );
    }

    Widget _attachmentItem(String filename) {
      return Row(
        children: [
          const Icon(Icons.attach_file, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(filename, style: const TextStyle(fontSize: 14, color: Colors.black87, decoration: TextDecoration.underline)),
          ),
          IconButton(icon: const Icon(Icons.download, size: 20, color: primary), onPressed: () {}),
        ],
      );
    }

    Widget _milestoneItem(String title, String date, bool completed) {
      return Row(
        children: [
          Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked, color: completed ? Colors.green : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      );
    }

    Widget _profileAvatar(String url) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      );
    }
  }
