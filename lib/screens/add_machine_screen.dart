import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMachineScreen extends StatefulWidget {
  final String? userId; 
  final Map<String, dynamic>? machineData; 

  const AddMachineScreen({super.key, this.userId, this.machineData}); 

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconUrlController = TextEditingController(); // NEW: For Icon Link
  final _videoUrlController = TextEditingController(); // NEW: For Video Link
  
  // Dropdown Data
  String? _selectedMuscleGroup;
  final List<String> _muscleGroups = ['Chest', 'Side Shoulder', 'Front Shoulder', 'Biceps', 'Arms', 'Quads', 'Abs', 'Shins', 'Neck', 'Rear Shoulder', 'Triceps', 'Lower Back', 'Traps', 'Middle Back', 'Lats', 'Glutes', 'Hamstrings', 'Calves'];

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers if machineData exists
    if (widget.machineData != null) {
      _nameController.text = widget.machineData!['name'] ?? '';
      _selectedMuscleGroup = widget.machineData!['musclegroup'];
      _iconUrlController.text = widget.machineData!['icon'] ?? '';
      
      // Note: You may need to fetch the description/video from 'machine_detail' 
      // if it wasn't passed in the map.
      _fetchExtraDetails();
    }
  }

  Future<void> _fetchExtraDetails() async {
    try {
      final detail = await _supabase
          .from('machine_detail')
          .select('description, video')
          .eq('machine_id', widget.machineData!['id'])
          .maybeSingle();

      if (detail != null && mounted) {
        setState(() {
          _descriptionController.text = detail['description'] ?? '';
          _videoUrlController.text = detail['video'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error fetching details: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // SUBMIT FORM
  // ---------------------------------------------------------------------------
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMuscleGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a muscle group")));
      return;
    }

    setState(() => _isLoading = true);

    final isEditing = widget.machineData != null;

    try {
      if(isEditing){
        final machineId = widget.machineData!['id'];
        // UPDATE Table 1: machine_list
        await _supabase.from('machine_list').update({
          'name': _nameController.text,
          'musclegroup': _selectedMuscleGroup,
          'icon': _iconUrlController.text,
        }).eq('id', widget.machineData!['id']);

        // UPDATE Table 2: machine_detail
        await _supabase.from('machine_detail').update({
          'description': _descriptionController.text,
          'video': _videoUrlController.text,
        }).eq('machine_id', machineId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Machine Updated!")));
          Navigator.pop(context);
        }
        
      } else{
        // STEP 1: Insert into 'machine_list'
        final List<dynamic> listData = await _supabase.from('machine_list').insert({
          'name': _nameController.text,
          'musclegroup': _selectedMuscleGroup,
          'icon': _iconUrlController.text, // Takes the text link directly
          'creator_id': widget.userId, 
        }).select();

        final newMachineId = listData[0]['id']; 

        // STEP 2: Insert into 'machine_detail'
        await _supabase.from('machine_detail').insert({
          'machine_id': newMachineId, 
          'description': _descriptionController.text,
          'video': _videoUrlController.text, // Takes the text link directly
          'creator_id': widget.userId,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Machine Created Successfully!")));
          Navigator.pop(context); // Go back to list
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Create New Machine"),
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. NAME ---
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Machine Name"),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              // --- 2. MUSCLE GROUP DROPDOWN ---
              DropdownButtonFormField<String>(
                initialValue: _selectedMuscleGroup,
                dropdownColor: const Color(0xFF1C1C1E),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Muscle Group"),
                items: _muscleGroups.map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                onChanged: (val) => setState(() => _selectedMuscleGroup = val),
              ),
              const SizedBox(height: 15),

              // --- 3. DESCRIPTION ---
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: _inputDecoration("Description"),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              // --- 4. ICON URL (LINK) ---
              TextFormField(
                controller: _iconUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Icon Image URL (e.g. https://...)"),
                keyboardType: TextInputType.url,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (!val.startsWith('http')) return 'Must be a valid link';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- 5. VIDEO URL (LINK) ---
              TextFormField(
                controller: _videoUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Video URL (e.g. YouTube/MP4 link)"),
                keyboardType: TextInputType.url,
                 // Optional: Remove validator if video is not mandatory
                validator: (val) { 
                  if (val != null && val.isNotEmpty && !val.startsWith('http')) {
                    return 'Must be a valid link';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 40),

              // --- 6. SUBMIT BUTTON ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0FD3E),
                    foregroundColor: Colors.black,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text("CREATE MACHINE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1C1C1E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), 
        borderSide: const BorderSide(color: Color(0xFFD0FD3E), width: 1)
      ),
    );
  }
}