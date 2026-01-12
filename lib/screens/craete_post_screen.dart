import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';

class CreatePostScreen extends StatefulWidget {
  final String userId; // uuid string
  final VoidCallback onBackToMap;

  const CreatePostScreen({
    super.key,
    required this.userId,
    required this.onBackToMap,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _musclegroup = 'Chest';
  String _difficulty = 'easy';
  bool _loading = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await supabase.from('posts').insert({
        'user_id': widget.userId,     // uuid as string is ok
        'musclegroup': _musclegroup,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'difficulty': _difficulty,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created ✅')),
      );

      widget.onBackToMap(); // go back to map tab
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: widget.onBackToMap,
        ),
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _musclegroup,
                items: const [
                  DropdownMenuItem(value: 'Chest', child: Text('Chest')),
                  DropdownMenuItem(value: 'Biceps', child: Text('Biceps')),
                  DropdownMenuItem(value: 'Abs', child: Text('Abs')),
                  DropdownMenuItem(value: 'Quads', child: Text('Quads')),
                  DropdownMenuItem(value: 'Upper back', child: Text('Upper back')),
                  DropdownMenuItem(value: 'Lats', child: Text('Lats')),
                ],
                onChanged: (v) => setState(() => _musclegroup = v!),
                decoration: const InputDecoration(labelText: 'Muscle Group'),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _difficulty,
                items: const [
                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                ],
                onChanged: (v) => setState(() => _difficulty = v!),
                decoration: const InputDecoration(labelText: 'Difficulty'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createPost,
                  child: _loading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
