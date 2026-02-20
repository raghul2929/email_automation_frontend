import 'package:flutter/material.dart';

enum CampaignStatusType { success, failure }

class CampaignStatusScreen extends StatelessWidget {
  final CampaignStatusType type;
  final int recipientCount;
  final VoidCallback onPrimaryAction; // Back to Dashboard / Try Again
  final VoidCallback onSecondaryAction; // View List

  const    CampaignStatusScreen({
    Key? key,
    required this.type,
    required this.recipientCount,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSuccess = type == CampaignStatusType.success;
    
    // Colors extracted from your image
    final Color bgDark = const Color(0xFF13111C); // Dark background
    final Color brandPurple = const Color(0xFF8B5CF6);
    final Color cardBg = const Color(0xFF2B293A);
    
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          isSuccess ? 'Success' : 'Delivery Failed',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              
              // 1. Illustration Area
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    // REPLACE WITH YOUR ASSET PATHS
                    image: AssetImage(isSuccess 
                        ? 'assets/images/success_plane.png' 
                        : 'assets/images/failed_plane.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                // Fallback Icon if you haven't added assets yet
                child: const Center(
                  child: Icon(Icons.send_rounded, size: 80, color: Colors.white24), 
                ),
              ),

              const SizedBox(height: 32),

              // 2. Title & Subtitle
              Text(
                isSuccess ? 'Campaign Sent\nSuccessfully!' : 'Campaign Failed to Send',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
                  children: [
                    TextSpan(
                      text: isSuccess 
                        ? 'Your emails are on their way to \n' 
                        : 'Something went wrong while \nprocessing your ',
                    ),
                    TextSpan(
                      text: '$recipientCount recipients.',
                      style: TextStyle(
                        color: brandPurple, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 3. Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSuccess ? const Color(0xFF2E4C3C) : const Color(0xFF4C2E2E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess ? Icons.rocket_launch : Icons.error_outline,
                        color: isSuccess ? const Color(0xFF4ADE80) : const Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSuccess ? 'Delivery Started' : 'Delivery Failed',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Just now',
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // 4. Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onPrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isSuccess ? 'Back to Dashboard' : 'Try Again',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: onSecondaryAction,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isSuccess ? 'View Success List' : 'View Draft List',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}