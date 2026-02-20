import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'registration_screen.dart';
import '../dashboard/main_dashboard.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // specific purple color from the design
    final Color brandPurple = const Color(0xFF8B5CF6);
   
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: brandPurple,
                          borderRadius:
                              BorderRadius.circular(35), // Squircle shape
                          boxShadow: [
                            BoxShadow(
                              color: brandPurple.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      // Lightning Bolt Badge
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            color: brandPurple,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- TEXT SECTION ---
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 72, 72, 72),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 3), // Pushes the button to the bottom

              // --- GOOGLE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _handleGoogleSignIn(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. Google Logo (Using a PNG URL so Image.network works)
                      Image.asset(
                        'assets/google.png',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),

                      // 2. Button Text
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- FOOTER TEXT ---
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: TextStyle(color: const Color.fromARGB(255, 56, 56, 56), fontSize: 12),
                    children: [
                      TextSpan(
                        text: 'Terms',
                        style: TextStyle(
                          color: brandPurple,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' & '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: brandPurple,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    // Added a simple loading indicator dialog since we removed the full overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await authProvider.signInWithGoogle();

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainDashboard()),
      );
    } else if (authProvider.firebaseUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationScreen()),
      );
    }
  }
}
