import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Utils/colors.dart';

class EmployerActiveProjectScreen extends StatefulWidget {
  const EmployerActiveProjectScreen({Key? key}) : super(key: key);

  @override
  State<EmployerActiveProjectScreen> createState() => _EmployerActiveProjectScreenState();
}

class _EmployerActiveProjectScreenState extends State<EmployerActiveProjectScreen> {
  final EmployerProjectsController controller = Get.put(EmployerProjectsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Projects',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No projects yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.projects.length,
          itemBuilder: (context, index) {
            final project = controller.projects[index];
            return _buildProjectCard(project);
          },
        );
      }),
    );
  }

  Widget _buildProjectCard(EmployerProject project) {
    final status = project.Status;
    final milestones = project.milestones;
    
    // Status color
    Color statusColor;
    switch (status) {
      case 'IN_PROGRESS':
        statusColor = Colors.green;
        break;
      case 'AWAITING_FUNDING':
        statusColor = Colors.orange;
        break;
      case 'COMPLETED':
        statusColor = Colors.teal;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            status == 'IN_PROGRESS' ? Icons.play_arrow : Icons.folder,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          project.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              project.displayBudget,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
        children: [
          if (milestones.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No milestones added yet'),
            )
          else
            ...milestones.map((milestone) => _buildMilestoneTile(milestone)).toList(),
        ],
      ),
    );
  }

  Widget _buildMilestoneTile(Milestone milestone) {
    final status = milestone.status;
    
    Color statusColor;
    switch (status) {
      case 'FUNDED':
        statusColor = Colors.blue;
        break;
      case 'SUBMITTED':
        statusColor = Colors.orange;
        break;
      case 'APPROVED':
      case 'RELEASED':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                status == 'APPROVED' || status == 'RELEASED' ? Icons.check : Icons.circle,
                color: statusColor,
                size: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getMilestoneStatusText(status),
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${milestone.amount}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'AWAITING_FUNDING':
        return 'Awaiting';
      case 'COMPLETED':
        return 'Completed';
      default:
        return status;
    }
  }

  String _getMilestoneStatusText(String status) {
    switch (status) {
      case 'FUNDED':
        return 'Funded';
      case 'SUBMITTED':
        return 'Submitted';
      case 'APPROVED':
        return 'Approved';
      case 'RELEASED':
        return 'Completed';
      default:
        return 'Pending';
    }
  }
}