import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/campaign_provider.dart';
import '../../widgets/custom_button.dart';
import 'upload_excel_dialog.dart';
import 'draft_detail_screen.dart';

class NewCampaignScreen extends StatelessWidget {
  const NewCampaignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Campaign'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              const Text(
                'Create New Campaign',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose how you want to create your campaign',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'Upload Excel File',
                icon: Icons.upload_file,
                onPressed: () => _showUploadDialog(context),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Create Blank Workbook',
                icon: Icons.add_circle_outline,
                backgroundColor: Colors.grey[300],
                textColor: Colors.black87,
                onPressed: () => _createBlankWorkbook(context),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Excel files must contain "name" and "email" columns',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const UploadExcelDialog(),
    );
  }

  void _createBlankWorkbook(BuildContext context) {
    // Navigate to draft creation with manual entry
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DraftDetailScreen(isNewDraft: true),
      ),
    );
  }
}
