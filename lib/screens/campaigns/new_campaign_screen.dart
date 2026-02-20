import 'package:flutter/material.dart';
import 'upload_contacts_screen.dart'; // Connects to the Upload Screen
import 'draft_detail_screen.dart';   // Connects to your Draft Detail Screen

class NewCampaignScreen extends StatelessWidget {
  const NewCampaignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // --- 1. Custom 3D-style Illustration ---
            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF3E8FF), 
                          const Color(0xFFEBE4FF).withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -0.2,
                    child: const Icon(
                      Icons.campaign_rounded,
                      size: 80,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildFloatingIcon(Icons.mail_outline, Colors.pinkAccent),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    child: _buildFloatingIcon(Icons.email_outlined, Colors.blue),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 30,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. Title & Subtitle ---
            const Text(
              'New Campaign',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select a data source to launch your\nmarketing automation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // --- 3. Upload Excel Button (The Logic Fix) ---
            _buildOptionCard(
              context: context,
              title: 'Upload Excel',
              subtitle: 'Import contacts from file',
              icon: Icons.upload_file_rounded,
              isPrimary: true,
              onTap: () {
                // FIXED: Navigates to the full screen upload page instead of dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadContactsScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            // --- 4. Start from Scratch Button ---
            _buildOptionCard(
              context: context,
              title: 'Start from Scratch',
              subtitle: 'Create empty workbook',
              icon: Icons.add_rounded,
              isPrimary: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DraftDetailScreen(isNewDraft: true),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // --- 5. Info Box ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_rounded, color: Color(0xFF0284C7), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'File Requirements',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C4A6E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Color(0xFF0C4A6E), fontSize: 13, height: 1.4),
                            children: [
                              TextSpan(text: 'Ensure your file includes '),
                              TextSpan(
                                text: 'name', 
                                style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'email', 
                                style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' columns.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                )
              : null,
          color: isPrimary ? null : Colors.white,
          border: isPrimary ? null : Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: isPrimary ? const Color(0xFF8B5CF6).withOpacity(0.3) : Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withOpacity(0.2) : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : const Color(0xFF7C3AED),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isPrimary ? Colors.white.withOpacity(0.8) : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isPrimary ? Colors.white : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}