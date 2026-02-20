import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart'; // Robust Excel decoder
import 'package:csv/csv.dart';
import 'draft_detail_screen.dart'; // Importing your screen

class UploadContactsScreen extends StatefulWidget {
  const UploadContactsScreen({Key? key}) : super(key: key);

  @override
  State<UploadContactsScreen> createState() => _UploadContactsScreenState();
}

class _UploadContactsScreenState extends State<UploadContactsScreen> {
  PlatformFile? _selectedFile;
  final List<PlatformFile> _recentFiles = [];
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      await FilePicker.platform.clearTemporaryFiles();
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          // Add to recent files (avoid duplicates)
          if (!_recentFiles.any((f) => f.name == _selectedFile!.name)) {
            _recentFiles.insert(0, _selectedFile!);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _handleContinue() async {
    if (_selectedFile == null || _selectedFile!.path == null) return;

    setState(() => _isLoading = true);

    try {
      List<Map<String, String>> extractedContacts = [];
      final file = File(_selectedFile!.path!);
      final extension = _selectedFile!.extension?.toLowerCase();

      // --- 1. PARSE CSV ---
      if (extension == 'csv') {
        final input = await file.readAsString();
        List<List<dynamic>> rows = const CsvToListConverter().convert(input);

        // Start at index 1 to skip header
        for (int i = 1; i < rows.length; i++) {
          var row = rows[i];
          if (row.isEmpty) continue;
          
          String name = row.isNotEmpty ? row[0].toString() : '';
          String email = row.length > 1 ? row[1].toString() : '';

          if (email.contains('@')) {
            extractedContacts.add({'name': name, 'email': email});
          }
        }
      } 
      // --- 2. PARSE EXCEL (ROBUST METHOD) ---
      else {
        final bytes = await file.readAsBytes();
        
        // spreadsheet_decoder handles all styling without crashing
        var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
        
        // Loop through all tables (sheets)
        for (var table in decoder.tables.keys) {
          // Loop through rows in that table
          for (var row in decoder.tables[table]!.rows) {
            // Skip empty rows
            if (row.isEmpty) continue;
            
            // Basic logic: Col 0 = Name, Col 1 = Email
            String name = row.isNotEmpty ? row[0].toString() : '';
            String email = row.length > 1 ? row[1].toString() : '';

            // Filter out headers/invalid rows
            if (email.contains('@') && name.toLowerCase() != 'name') {
               extractedContacts.add({'name': name, 'email': email});
            }
          }
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (extractedContacts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid contacts found! Check file format.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // --- 3. NAVIGATE TO DRAFT DETAIL SCREEN ---
        // passing the extracted data directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DraftDetailScreen(
              isNewDraft: true,
              importedContacts: extractedContacts,
              importedFileName: _selectedFile!.name, 
            ),
          ),
        );
      }

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reading file: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Upload Contacts', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- DROP ZONE ---
                  GestureDetector(
                    onTap: _pickFile,
                    child: CustomPaint(
                      painter: DashedBorderPainter(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_upload_rounded, color: Color(0xFF7C3AED), size: 40),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFile != null ? _selectedFile!.name : 'Upload Excel or CSV',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFile != null ? 'Tap to change file' : 'Tap to browse files',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text('Recent Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  
                  if (_recentFiles.isEmpty)
                    const Text("No files selected yet.", style: TextStyle(color: Colors.grey))
                  else
                    ..._recentFiles.map((file) => _buildFileItem(file)),
                ],
              ),
            ),
          ),

          // --- CONTINUE BUTTON ---
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                // Only enable if file selected and not loading
                onPressed: (_selectedFile != null && !_isLoading) ? _handleContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  disabledBackgroundColor: const Color(0xFFE9D5FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    bool isSelected = _selectedFile?.name == file.name;
    return ListTile(
      onTap: () => setState(() => _selectedFile = file),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.table_chart, color: Color(0xFF7C3AED)),
      ),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF7C3AED)) : null,
      selected: isSelected,
      tileColor: isSelected ? Colors.white : null,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD8B4FE)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(20)));
    final dashPath = Path();
    double dashWidth = 8.0, dashSpace = 5.0, distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(pathMetric.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint); 
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}