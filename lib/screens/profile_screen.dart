import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final bool isVerified;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.isVerified,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();
  String? _avatarUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchAvatar();
  }

  Future<void> _fetchAvatar() async {
    try {
      final row = await _supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', widget.userId)
          .maybeSingle();
      if (mounted) setState(() => _avatarUrl = row?['avatar_url']);
    } catch (_) {}
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _isUploading = true);
    try {
      final ext = picked.name.split('.').last.toLowerCase();
      final filePath = 'avatars/${widget.userId}.$ext';

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        await _supabase.storage.from('machine_images').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
      } else {
        await _supabase.storage.from('machine_images').upload(
          filePath,
          File(picked.path),
          fileOptions: const FileOptions(upsert: true),
        );
      }

      final url = _supabase.storage.from('machine_images').getPublicUrl(filePath);
      await _supabase.from('profiles').update({'avatar_url': url}).eq('id', widget.userId);
      if (mounted) setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 36, bottom: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kPrimaryColor.withAlpha(20),
                    kBackgroundColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimaryColor, width: 2.5),
                          color: kCardColor,
                        ),
                        child: ClipOval(
                          child: _isUploading
                              ? const Center(
                                  child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 2))
                              : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                  ? Image.network(
                                      _avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => _buildInitialAvatar(initial),
                                    )
                                  : _buildInitialAvatar(initial),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: _isUploading ? null : _pickAndUploadAvatar,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: kBackgroundColor, width: 2.5),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Username + verified icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (widget.isVerified) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified_rounded, color: kPrimaryColor, size: 24),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.isVerified
                          ? kPrimaryColor.withAlpha(30)
                          : Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: widget.isVerified ? kPrimaryColor.withAlpha(80) : Colors.white12,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isVerified ? Icons.shield_rounded : Icons.person_rounded,
                          size: 14,
                          color: widget.isVerified ? kPrimaryColor : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isVerified ? 'Verified Creator' : 'Member',
                          style: TextStyle(
                            color: widget.isVerified ? kPrimaryColor : Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Account Info ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACCOUNT INFO',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _infoCard(
                    icon: Icons.person_outline_rounded,
                    label: 'Username',
                    value: widget.username,
                  ),
                  const SizedBox(height: 10),
                  _infoCard(
                    icon: Icons.shield_outlined,
                    label: 'Account Status',
                    value: widget.isVerified ? 'Verified Creator' : 'Standard Member',
                    valueColor: widget.isVerified ? kPrimaryColor : Colors.white70,
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: kPrimaryColor,
          fontSize: 42,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
