import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String _heroImage =
      'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?q=80&w=1000&auto=format&fit=crop';

  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final auth = AuthService(Supabase.instance.client);
      await auth.signUp(
        username: _usernameCtrl.text,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _heroImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) =>
                const ColoredBox(color: kBackgroundColor),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kBackgroundColor.withAlpha(120),
                  kBackgroundColor.withAlpha(200),
                  kBackgroundColor,
                ],
                stops: const [0.0, 0.45, 0.85],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: kPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // Back button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white, size: 20),
                              ),
                            ),

                            const Spacer(),

                            const Text(
                              "Create your\naccount",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Join and start tracking your gym journey.",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 28),

                            _GlassCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildField(
                                      controller: _usernameCtrl,
                                      hint: 'Username',
                                      icon: Icons.person_outline,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Enter a username'
                                              : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildField(
                                      controller: _passwordCtrl,
                                      hint: 'Password (6+ characters)',
                                      icon: Icons.lock_outline,
                                      obscure: _hidePassword,
                                      suffix: IconButton(
                                        onPressed: () => setState(
                                            () => _hidePassword = !_hidePassword),
                                        icon: Icon(
                                          _hidePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.length < 6)
                                          ? 'Password must be 6+ characters'
                                          : null,
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _handleRegister,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimaryColor,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.black,
                                                ),
                                              )
                                            : const Text(
                                                "REGISTER",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: RichText(
                                  text: const TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(color: Colors.grey),
                                    children: [
                                      TextSpan(
                                        text: "Login",
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white.withAlpha(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        suffixIcon: suffix,
      ),
      validator: validator,
    );
  }
}

// Frosted-glass container, matching the login screen.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: child,
        ),
      ),
    );
  }
}
