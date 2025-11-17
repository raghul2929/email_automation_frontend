import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/campaign_provider.dart';
import '../../widgets/custom_button.dart';
import 'draft_detail_screen.dart';

class UploadExcelDialog extends StatefulWidget {
  const UploadExcelDialog({Key? key}) : super(key: key);

  @override
  State<UploadExcelDialog> createState() => _UploadExcelDialogState();
}

class _UploadExcelDialogState extends State<UploadExcelDialog> {
  String? _selectedFileName;
  String? _selectedFilePath;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Excel File'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.description, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected File:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _selectedFileName!,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedFileName = null;
                        _selectedFilePath = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickFile,
            icon: const Icon(Icons.folder_open),
            label: Text(_selectedFileName == null ? 'Choose File' : 'Choose Different File'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Supported: ${AppConstants.allowedFileExtensions.join(", ")}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_selectedFilePath != null && !_isUploading) ? _uploadFile : null,
          child: _isUploading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Upload'),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedFileExtensions,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _selectedFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFilePath == null) return;

    setState(() => _isUploading = true);

    final campaignProvider = context.read<CampaignProvider>();
    final success = await campaignProvider.uploadExcel(_selectedFilePath!);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excel uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to draft detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DraftDetailScreen(
            draftId: campaignProvider.selectedDraft?.id,
          ),
        ),
      );
    } else {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(campaignProvider.errorMessage ?? 'Upload failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
