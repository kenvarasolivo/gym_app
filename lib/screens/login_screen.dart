import 'package:flutter/material.dart';
import 'package:gym_app/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './body_map_screen.dart';
import '../core/constants.dart';
import 'dart:ui';

// ------------------- LOGIN SCREEN -------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _heroImage =
      'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=1000&auto=format&fit=crop';

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hidePassword = true;

  final AuthService _auth = AuthService(Supabase.instance.client);

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = await _auth.signIn(
        username: _usernameCtrl.text,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BodyMapScreen(
            userId: profile['id'].toString(),
            isVerified: (profile['verified'] as bool?) ?? false,
            username: profile['username']?.toString() ?? '',
          ),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loginAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BodyMapScreen(
          userId: 'guest',
          isVerified: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed hero image
          Image.network(
            _heroImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) =>
                const ColoredBox(color: kBackgroundColor),
          ),

          // Dark gradient so the content stays readable over the photo
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
                            const SizedBox(height: 24),

                            // Brand pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(20),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withAlpha(30)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.fitness_center,
                                      color: kPrimaryColor, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    "GYM MACHINE GUIDE",
                                    style: TextStyle(
                                      color: Colors.grey[200],
                                      fontSize: 11,
                                      letterSpacing: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Headline
                            const Text(
                              "Volume up your\nbody goals",
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
                              "Master every machine. Train smarter, not harder.",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Frosted-glass form card
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
                                              ? 'Please enter your username'
                                              : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildField(
                                      controller: _passwordCtrl,
                                      hint: 'Password',
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
                                      validator: (v) =>
                                          (v == null || v.isEmpty)
                                              ? 'Please enter your password'
                                              : null,
                                    ),
                                    const SizedBox(height: 18),

                                    // Login button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimaryColor,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
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
                                                "LOGIN",
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

                            // Sign up + Guest
                            Center(
                              child: Column(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterScreen()),
                                      );
                                    },
                                    child: RichText(
                                      text: const TextSpan(
                                        text: "Don't have an account? ",
                                        style: TextStyle(color: Colors.grey),
                                        children: [
                                          TextSpan(
                                            text: "Sign Up",
                                            style: TextStyle(
                                              color: kPrimaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading ? null : _loginAsGuest,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey[400],
                                    ),
                                    child: const Text(
                                      "Continue as Guest",
                                      style: TextStyle(
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
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

// Frosted-glass container used for the login form.
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

// ------------------- AUTH SERVICE -------------------

class AuthService {
  final SupabaseClient _client;
  AuthService(this._client);

  Map<String, dynamic>? _currentProfile;
  Map<String, dynamic>? get currentProfile => _currentProfile;

  Future<Map<String, dynamic>> signIn({
    required String username,
    required String password,
  }) async {
    final row = await _client
        .from('profiles')
        .select('id, username, verified, created_at, password')
        .eq('username', username.trim())
        .maybeSingle();

    if (row == null) {
      throw const AuthException('User not found');
    }

    final dbPassword = (row['password'] ?? '').toString();
    if (dbPassword != password) {
      throw const AuthException('Wrong password');
    }

    _currentProfile = {
      'id': row['id'],
      'username': row['username'],
      'verified': row['verified'],
      'created_at': row['created_at'],
    };

    return _currentProfile!;
  }

  Future<void> signUp({
    required String username,
    required String password,
  }) async {
    // Check if username already exists
    final existing = await _client
        .from('profiles')
        .select('username')
        .eq('username', username.trim())
        .maybeSingle();

    if (existing != null) {
      throw const AuthException('Username already taken');
    }

    // Insert new profile
    await _client.from('profiles').insert({
      'username': username.trim(),
      'password': password, 
      'verified': false,    
    });
  }

  Future<void> signOut() async {
    _currentProfile = null;
  }
}
