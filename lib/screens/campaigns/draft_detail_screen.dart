import 'package:email_automation_app/widgets/custom_text_feild.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/utils/validators.dart';
import '../../providers/campaign_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

class DraftDetailScreen extends StatefulWidget {
  final String? draftId;
  final bool isNewDraft;

  const DraftDetailScreen({
    Key? key,
    this.draftId,
    this.isNewDraft = false,
  }) : super(key: key);

  @override
  State<DraftDetailScreen> createState() => _DraftDetailScreenState();
}

class _DraftDetailScreenState extends State<DraftDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _campaignNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.draftId != null) {
      _loadDraft();
    } else {
      _isEditing = true;
    }
  }

  Future<void> _loadDraft() async {
    final campaignProvider = context.read<CampaignProvider>();
    await campaignProvider.fetchDraftById(widget.draftId!);

    if (campaignProvider.selectedDraft != null) {
      _campaignNameController.text = campaignProvider.selectedDraft!.campaignName;
      _subjectController.text = campaignProvider.selectedDraft!.emailSubject;
      _bodyController.text = campaignProvider.selectedDraft!.emailContent;
    }
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewDraft ? 'New Draft' : 'Draft Details'),
        actions: [
          if (!_isEditing && !widget.isNewDraft)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: Consumer<CampaignProvider>(
        builder: (context, campaignProvider, _) {
          final draft = campaignProvider.selectedDraft;

          if (campaignProvider.isLoading && draft == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return LoadingOverlay(
            isLoading: campaignProvider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campaign Info Card
                    if (draft != null && !widget.isNewDraft) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Campaign Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _InfoRow(
                                label: 'Recipients',
                                value: '${draft.totalRecipients} people',
                                icon: Icons.people_outline,
                              ),
                              _InfoRow(
                                label: 'Status',
                                value: draft.status.toUpperCase(),
                                icon: Icons.flag_outlined,
                              ),
                              _InfoRow(
                                label: 'Created',
                                value: DateFormat('MMM dd, yyyy - hh:mm a').format(draft.createdAt),
                                icon: Icons.calendar_today_outlined,
                              ),
                              if (draft.excelFileName != null)
                                _InfoRow(
                                  label: 'Excel File',
                                  value: draft.excelFileName!,
                                  icon: Icons.description_outlined,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Campaign Details Form
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Campaign Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _campaignNameController,
                              label: 'Campaign Name',
                              hint: 'Enter campaign name',
                              validator: Validators.validateCampaignName,
                              enabled: _isEditing,
                              prefixIcon: const Icon(Icons.campaign_outlined),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _subjectController,
                              label: 'Email Subject',
                              hint: 'Enter email subject',
                              validator: Validators.validateSubject,
                              enabled: _isEditing,
                              prefixIcon: const Icon(Icons.subject_outlined),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _bodyController,
                              label: 'Email Body',
                              hint: 'Enter email content (HTML supported)',
                              validator: Validators.validateBody,
                              enabled: _isEditing,
                              maxLines: 10,
                              prefixIcon: const Icon(Icons.text_fields),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recipients Preview
                    if (draft != null && draft.recipients.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recipients Preview',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Chip(
                                    label: Text('${draft.recipients.length}'),
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                constraints: const BoxConstraints(maxHeight: 300),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: draft.recipients.take(10).length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final recipient = draft.recipients[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        child: Text(
                                          recipient.name.substring(0, 1).toUpperCase(),
                                        ),
                                      ),
                                      title: Text(recipient.name),
                                      subtitle: Text(recipient.email),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(recipient.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          recipient.status,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getStatusColor(recipient.status),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (draft.recipients.length > 10) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '+ ${draft.recipients.length - 10} more recipients',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action Buttons
                    if (_isEditing) ...[
                      CustomButton(
                        text: widget.isNewDraft ? 'Create Draft' : 'Save Changes',
                        icon: Icons.save,
                        onPressed: _saveDraft,
                      ),
                      if (!widget.isNewDraft) ...[
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Cancel',
                          backgroundColor: Colors.grey[300],
                          textColor: Colors.black87,
                          onPressed: () {
                            setState(() => _isEditing = false);
                            _loadDraft();
                          },
                        ),
                      ],
                    ] else if (draft != null) ...[
                      CustomButton(
                        text: 'Send Campaign',
                        icon: Icons.send,
                        onPressed: () => _confirmSend(draft.id),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Delete Draft',
                        icon: Icons.delete_outline,
                        backgroundColor: Colors.red,
                        onPressed: () => _confirmDelete(draft.id),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'sent':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;

    final campaignProvider = context.read<CampaignProvider>();
    
    bool success;
    if (widget.isNewDraft) {
      success = await campaignProvider.createDraft(
        campaignName: _campaignNameController.text.trim(),
        recipients: [], // Empty for now, can be added manually
        emailSubject: _subjectController.text.trim(),
        emailContent: _bodyController.text.trim(),
      );
    } else {
      success = await campaignProvider.updateDraft(
        draftId: widget.draftId!,
        campaignName: _campaignNameController.text.trim(),
        emailSubject: _subjectController.text.trim(),
        emailContent: _bodyController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      if (widget.isNewDraft) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(campaignProvider.errorMessage ?? 'Failed to save draft'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmSend(String draftId) async {
    final campaignProvider = context.read<CampaignProvider>();
    final draft = campaignProvider.selectedDraft;

    if (draft == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Campaign'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to send this campaign?'),
            const SizedBox(height: 16),
            Text('📧 Recipients: ${draft.totalRecipients}'),
            Text('📨 Subject: ${draft.emailSubject}'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Now'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await campaignProvider.sendCampaign(draftId);
      
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(campaignProvider.errorMessage ?? 'Failed to send campaign'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(String draftId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft'),
        content: const Text('Are you sure you want to delete this draft? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<CampaignProvider>().deleteDraft(draftId);
      
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
