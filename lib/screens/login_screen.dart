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
  final PageController _pageController = PageController(viewportFraction: 0.6);

  final List<String> _imageUrls = [
    'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600&auto=format&fit=crop',
  ];

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hidePassword = true;

  final AuthService _auth = AuthService(Supabase.instance.client);

  @override
  void dispose() {
    _pageController.dispose();
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
        
                      Text(
                        "GYM MACHINE GUIDE",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
        
                      const SizedBox(height: 10),
        
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          "VOLUME UP YOUR\nBODY GOALS",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
        
                      const SizedBox(height: 30),
        
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: kPadding),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Username',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.white.withAlpha(15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
        
                              const SizedBox(height: 12),
        
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _hidePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.white.withAlpha(15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _hidePassword = !_hidePassword),
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
        
                      const SizedBox(height: 60),
        
                      SizedBox(
                        height: 350, 
                        child: PageView.builder(
                          controller: _pageController,
                          scrollBehavior: const MaterialScrollBehavior().copyWith(
                            dragDevices: {
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.touch,
                              PointerDeviceKind.stylus,
                              PointerDeviceKind.unknown,
                            },
                          ),
                          itemCount: _imageUrls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(_imageUrls[index]),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(128),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
        
                      const Spacer(),
        
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: kPadding),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text(
                                        "LOGIN",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                  );
                                },
                                child: const Text("Don't have an account? Sign Up", style: TextStyle(color: kPrimaryColor)),
                            ),
        
                            const SizedBox(height: 15),
        
                            TextButton(
                              onPressed: _isLoading ? null : _loginAsGuest,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[400],
                              ),
                              child: const Text(
                                "Login as Guest",
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
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
