import 'package:email_automation_app/screens/campaigns/campaign_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/utils/validators.dart';
import '../../providers/campaign_provider.dart';
import '../../widgets/loading_overlay.dart';

class DraftDetailScreen extends StatefulWidget {
  final String? draftId;
  final bool isNewDraft;
  final List<Map<String, String>>? importedContacts;
  final String? importedFileName;

  const DraftDetailScreen({
    Key? key,
    this.draftId,
    this.isNewDraft = false,
    this.importedContacts,
    this.importedFileName,
  }) : super(key: key);

  @override
  State<DraftDetailScreen> createState() => _DraftDetailScreenState();
}

class _DraftDetailScreenState extends State<DraftDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _campaignNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  final Color _brandPurple = const Color(0xFF8B5CF6);
  final Color _bgLight = const Color(0xFFF8F9FD);
  final Color _textDark = const Color(0xFF1F2937);

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.draftId != null) {
      _loadDraft();
    } else {
      _isEditing = true;
      if (widget.importedContacts != null) {
        String fName = widget.importedFileName?.split('.').first ?? 'Campaign';
        _campaignNameController.text = "$fName - ${DateFormat('MMM dd').format(DateTime.now())}";
      }
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
      backgroundColor: _bgLight,
      body: Consumer<CampaignProvider>(
        builder: (context, campaignProvider, _) {
          final draft = campaignProvider.selectedDraft;
          
          final int recipientCount = draft?.recipients.length ?? widget.importedContacts?.length ?? 0;
          final String createdDate = draft != null
              ? DateFormat('MMM dd').format(draft.createdAt)
              : DateFormat('MMM dd').format(DateTime.now());

          final String displayFileName = draft?.excelFileName 
              ?? widget.importedFileName 
              ?? "Manual Entry";

          return LoadingOverlay(
            isLoading: campaignProvider.isLoading,
            child: Stack(
              children: [
                // Purple Header
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_brandPurple, const Color(0xFF7C3AED)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),

                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      // AppBar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.pop(context),
                            ),
                            const Text(
                              'Draft Details',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            _buildCircleButton(
                              icon: _isEditing ? Icons.close : Icons.edit,
                              onTap: () {
                                if (_isEditing) {
                                  setState(() => _isEditing = false);
                                  _loadDraft(); 
                                } else {
                                  setState(() => _isEditing = true);
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              draft?.status.toUpperCase() ?? 'READY',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildInfoCard(
                                  count: recipientCount,
                                  date: createdDate,
                                  fileName: displayFileName,
                                ),
                                const SizedBox(height: 20),
                                _buildContentDetailsCard(),
                                const SizedBox(height: 20),
                                _buildRecipientsCard(draft, widget.importedContacts),
                                const SizedBox(height: 140), // More space for double buttons
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- BOTTOM BUTTONS SECTION ---
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. SEND CAMPAIGN BUTTON (Primary)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleSendAction(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              shadowColor: _brandPurple.withOpacity(0.4),
                            ),
                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              'Send Campaign',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // 2. SAVE DRAFT BUTTON (Secondary)
                        if (widget.isNewDraft || _isEditing)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () => _handleSaveOnly(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.save_outlined, color: Colors.black87, size: 20),
                              label: const Text(
                                'Save as Draft',
                                style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),

                        // 3. DELETE BUTTON (Only for existing drafts)
                        if (!widget.isNewDraft && draft != null && !_isEditing) 
                          TextButton.icon(
                            onPressed: () => _confirmDelete(draft.id),
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            label: const Text('Delete Draft', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- LOGIC HANDLERS ---

  /// Handles "Save as Draft" - Saves to DB and exits
  Future<void> _handleSaveOnly() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Save logic
    String? newId = await _saveToDatabase();
    
    if (newId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved successfully!'), backgroundColor: Colors.green),
      );
      // Go back to dashboard
      if (widget.isNewDraft) {
        Navigator.pop(context); // Pop Detail
        Navigator.pop(context); // Pop Upload
      } else {
        setState(() => _isEditing = false);
      }
    }
  }

  /// Handles "Send Campaign" - Saves first (if new) then Sends
  Future<void> _handleSendAction() async {
    final campaignProvider = context.read<CampaignProvider>();
    String? targetDraftId = widget.draftId;

    // 1. If it's new or edited, save it first
    if (widget.isNewDraft || _isEditing) {
      if (!_formKey.currentState!.validate()) return;
      
      // Save and get the new ID
      targetDraftId = await _saveToDatabase(); 
      if (targetDraftId == null) return; // Save failed
    }

    if (!mounted) return;

    // 2. Confirm Sending
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Campaign'),
        content: const Text('Are you ready to send emails to all recipients?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: _brandPurple),
            child: const Text('Send Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // 3. Trigger Send API
    if (confirmed == true && targetDraftId != null) {
      final success = await campaignProvider.sendCampaign(targetDraftId);
      
      if (!mounted) return;
      
      // Calculate recipient count for the UI
      final draft = campaignProvider.selectedDraft;
      final int count = draft?.recipients.length ?? widget.importedContacts?.length ?? 0;

      if (success) {
        // --- NAVIGATE TO SUCCESS SCREEN ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CampaignStatusScreen(
              type: CampaignStatusType.success,
              recipientCount: count,
              onPrimaryAction: () {
                // Logic for "Back to Dashboard"
                // Assuming you want to pop back to the very beginning
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              onSecondaryAction: () {
                // Logic for "View Success List"
                // Implement your navigation here, for now we just pop
                Navigator.pop(context);
              },
            ),
          ),
        );
      } else {
        // --- NAVIGATE TO FAILURE SCREEN ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CampaignStatusScreen(
              type: CampaignStatusType.failure,
              recipientCount: count,
              onPrimaryAction: () {
                // Logic for "Try Again"
                // Just pop this screen so they are back on the Details page to click "Send" again
                Navigator.pop(context);
              },
              onSecondaryAction: () {
                // Logic for "View Draft List"
                Navigator.pop(context); // Close status screen
                Navigator.pop(context); // Close details screen (back to list)
              },
            ),
          ),
        );
      }
    }
  }
  // Common Save Function - Returns the ID of the saved draft
  Future<String?> _saveToDatabase() async {
    final campaignProvider = context.read<CampaignProvider>();
    bool success = false;
    
    // We need to fetch the drafts again to find the ID if it's new, 
    // or rely on the provider to set 'selectedDraft'
    
    if (widget.isNewDraft) {
      success = await campaignProvider.createDraft(
        campaignName: _campaignNameController.text.trim(),
        recipients: widget.importedContacts ?? [],
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

    if (success) {
      // If new, the provider usually refreshes the list. 
      // ideally createDraft should return the ID, but assuming void/bool return:
      // We grab the ID from the `selectedDraft` if the provider updated it, 
      // or we assume success allows us to proceed.
      // For this UI flow, let's assume the provider sets 'selectedDraft' on creation.
      return campaignProvider.selectedDraft?.id ?? widget.draftId; 
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(campaignProvider.errorMessage ?? 'Failed to save'), backgroundColor: Colors.red),
    );
    return null;
  }

  Future<void> _confirmDelete(String draftId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft'),
        content: const Text('Delete this draft permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await context.read<CampaignProvider>().deleteDraft(draftId);
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  // --- UI WIDGETS (Keep same as before) ---
  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildInfoCard({required int count, required String date, required String fileName}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(children: [Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.info_outline_rounded, color: _brandPurple, size: 20)), const SizedBox(width: 12), Text('Campaign Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark))]), const SizedBox(height: 20), Row(children: [Expanded(child: _buildInfoItem(icon: Icons.people_outline_rounded, label: 'RECIPIENTS', value: '$count users')), Container(width: 1, height: 40, color: Colors.grey[200]), Expanded(child: Padding(padding: const EdgeInsets.only(left: 16.0), child: _buildInfoItem(icon: Icons.calendar_today_rounded, label: 'CREATED', value: date)))]), const SizedBox(height: 20), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('SOURCE FILE', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, color: _textDark))])), Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle), child: const Icon(Icons.description_outlined, color: Color(0xFF16A34A), size: 18))]))]),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)), const SizedBox(height: 6), Row(children: [Icon(icon, size: 16, color: _brandPurple), const SizedBox(width: 6), Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: _textDark))])]);
  }

  Widget _buildContentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Content Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)), const SizedBox(height: 20), _buildStyledTextField(label: 'Campaign Name', controller: _campaignNameController, enabled: _isEditing, validator: Validators.validateCampaignName), const SizedBox(height: 16), _buildStyledTextField(label: 'Subject Line', controller: _subjectController, enabled: _isEditing, validator: Validators.validateSubject), const SizedBox(height: 16), _buildStyledTextField(label: 'Body Preview', controller: _bodyController, enabled: _isEditing, maxLines: 3, validator: Validators.validateBody)]),
    );
  }

  Widget _buildStyledTextField({required String label, required TextEditingController controller, bool enabled = false, int maxLines = 1, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 4, bottom: 6), child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500))), TextFormField(controller: controller, enabled: enabled, maxLines: maxLines, validator: validator, style: TextStyle(fontWeight: FontWeight.w600, color: _textDark, fontSize: 14), decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF9FAFB), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _brandPurple)), disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100))))]);
  }

  Widget _buildRecipientsCard(dynamic draft, List? importedContacts) {
    int total = draft?.recipients.length ?? importedContacts?.length ?? 0;
    int displayCount = total > 4 ? 4 : total;
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Recipients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(12)), child: Text('View All ($total)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _brandPurple)))]), const SizedBox(height: 20), ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: displayCount, separatorBuilder: (_, __) => const SizedBox(height: 16), itemBuilder: (context, index) { String name = '', email = ''; if (draft != null) { name = draft.recipients[index].name; email = draft.recipients[index].email; } else if (importedContacts != null) { name = importedContacts[index]['name'] ?? 'User'; email = importedContacts[index]['email'] ?? ''; } return Row(children: [CircleAvatar(radius: 20, backgroundColor: const Color(0xFFE0E7FF), child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: _textDark, fontSize: 14)), Text(email, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)), child: const Text('PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706))))]); })]),
    );
  }
} 