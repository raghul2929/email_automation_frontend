import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart'; 
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/main_dashboard.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedProfession;

  // Colors
  final Color _accentPurple = const Color(0xFF5D5FEF);
  final Color _bgGradientTop = const Color(0xFFEFE9FF);
  final Color _bgGradientBottom = const Color(0xFFFDFBFF);

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _emailController.text = authProvider.firebaseUser?.email ?? '';
    _nameController.text = authProvider.firebaseUser?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _accentPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Complete Registration',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgGradientTop, _bgGradientBottom],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          // FIX STARTS HERE: LayoutBuilder gets the screen height
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // FIX: ConstrainedBox forces the content to be AT LEAST screen height
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  // FIX: IntrinsicHeight allows Spacer/Expanded to work inside ScrollView
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            
                            // --- Header ---
                            const Text(
                              'Hello! 👋',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Please complete your profile details to\nfinalize your account setup.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: 32),
          
                            // --- Form Card ---
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    validator: Validators.validateName,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                    decoration: _buildInputDecoration(
                                      label: 'Full Name',
                                      icon: Icons.person_outline_rounded,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _emailController,
                                    enabled: false,
                                    style: TextStyle(color: Colors.grey[800]),
                                    decoration: _buildInputDecoration(
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                      suffixIcon: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF00C853),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  DropdownButtonFormField<String>(
                                    value: _selectedProfession,
                                    validator: Validators.validateProfession,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _buildInputDecoration(
                                      label: 'Select Profession',
                                      icon: Icons.work_outline_rounded,
                                    ),
                                    items: (AppConstants.professions as List<String>)
                                        .map((profession) {
                                      return DropdownMenuItem(
                                        value: profession,
                                        child: Text(profession),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedProfession = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
          
                            const SizedBox(height: 40),
          
                            // --- Button ---
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return ElevatedButton(
                                    onPressed: authProvider.isLoading 
                                        ? null 
                                        : _handleRegistration,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _accentPurple,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: _accentPurple.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                'Continue',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward_rounded, size: 20),
                                            ],
                                          ),
                                  );
                                },
                              ),
                            ),
          
                            // --- Spacer & Footer ---
                            // This spacer now works because of IntrinsicHeight + ConstrainedBox
                            const Spacer(),
          
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Center(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'By continuing, you agree to our ',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: _accentPurple,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.registerUser(
      name: _nameController.text.trim(),
      profession: _selectedProfession!,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainDashboard()),
        (route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    }
  }
}