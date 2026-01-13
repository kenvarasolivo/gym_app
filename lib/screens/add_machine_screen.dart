import 'dart:io'; 
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';

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
  

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconUrlController = TextEditingController(); 
  final _videoUrlController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _setsRepsController = TextEditingController();
  
  // CHANGED: Use XFile instead of File for cross-platform support
  XFile? _imageFile; 
  XFile? _videoFile;
  final _picker = ImagePicker();

  String? _selectedMuscleGroup;
  String? _selectedDifficulty;

  final List<String> _muscleGroups = ['Chest', 'Side Shoulder', 'Front Shoulder', 'Biceps', 'Arms', 'Quads', 'Abs', 'Shins', 'Neck', 'Rear Shoulder', 'Triceps', 'Lower Back', 'Traps', 'Middle Back', 'Lats', 'Glutes', 'Hamstrings', 'Calves'];
  final List<String> _difficultyLevels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    if (widget.machineData != null) {
      _nameController.text = widget.machineData!['name'] ?? '';
      _selectedMuscleGroup = widget.machineData!['musclegroup'];
      _iconUrlController.text = widget.machineData!['icon'] ?? '';
      _fetchExtraDetails();
    }
  }

  Future<void> _fetchExtraDetails() async {
    try {
      final detail = await _supabase
          .from('machine_detail')
          .select('description, video, instructions, difficulty, sets_reps')
          .eq('machine_id', widget.machineData!['id'])
          .maybeSingle();

      if (detail != null && mounted) {
        setState(() {
          _descriptionController.text = detail['description'] ?? '';
          _videoUrlController.text = detail['video'] ?? '';
          _instructionsController.text = detail['instructions'] ?? '';
          _setsRepsController.text = detail['sets_reps'] ?? '';
          _selectedDifficulty = detail['difficulty'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching details: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // IMAGE PICKER FUNCTIONS
  // ---------------------------------------------------------------------------
  
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 80, 
      );
      
      if (pickedFile != null) {
        setState(() {
          // Store directly as XFile
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      final fileExt = _imageFile!.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'icons/$fileName'; 

      // Upload Logic differs for Web vs Mobile
      if (kIsWeb) {
        // WEB UPLOAD: Use bytes
        final bytes = await _imageFile!.readAsBytes();
        await _supabase.storage.from('machine_images').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
        );
      } else {
        // MOBILE UPLOAD: Use File object
        await _supabase.storage.from('machine_images').upload(
          filePath,
          File(_imageFile!.path),
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
      }

      final imageUrl = _supabase.storage.from('machine_images').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      }
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // VIDEO PICKER FUNCTIONS
  // ---------------------------------------------------------------------------

  Future<void> _pickVideo() async {
  try {
    final pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5), // Optional limit
    );
    
    if (pickedFile != null) {
      setState(() {
        _videoFile = pickedFile;
        _videoUrlController.text = pickedFile.name; // Show filename in the text field
      });
    }
  } catch (e) {
    debugPrint("Error picking video: $e");
  }
}

Future<String?> _uploadVideo() async {
  if (_videoFile == null) return null;

  try {
    final fileExt = _videoFile!.name.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'videos/$fileName'; // Upload to video folder

    if (kIsWeb) {
      final bytes = await _videoFile!.readAsBytes();
      await _supabase.storage.from('machine_images').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(contentType: 'video/mp4', upsert: false),
      );
    } else {
      await _supabase.storage.from('machine_images').upload(
        filePath,
        File(_videoFile!.path),
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
    }

    return _supabase.storage.from('machine_images').getPublicUrl(filePath);
  } catch (e) {
    debugPrint("Error uploading video: $e");
    return null;
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

    if (_imageFile == null && _iconUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an image for the machine")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String finalIconUrl = _iconUrlController.text;
      
      if (_imageFile != null) {
        final uploadedUrl = await _uploadImage();
        if (uploadedUrl != null) {
          finalIconUrl = uploadedUrl;
        } else {
          throw "Image upload failed"; 
        }
      }

      String finalVideoUrl = _videoUrlController.text;
      if (_videoFile != null) {
        final uploadedVideoUrl = await _uploadVideo();
        if (uploadedVideoUrl != null) {
          finalVideoUrl = uploadedVideoUrl;
        } else {
          throw "Video upload failed";
        }
      }
      final isEditing = widget.machineData != null;

      if(isEditing){
        final machineId = widget.machineData!['id'];
        
        await _supabase.from('machine_list').update({
          'name': _nameController.text,
          'musclegroup': _selectedMuscleGroup,
          'icon': finalIconUrl, 
        }).eq('id', widget.machineData!['id']);

        await _supabase.from('machine_detail').update({
          'description': _descriptionController.text,
          'video': finalVideoUrl,
          'instructions': _instructionsController.text,
          'difficulty': _selectedDifficulty,
          'sets_reps': _setsRepsController.text,
        }).eq('machine_id', machineId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Machine Updated!")));
          Navigator.pop(context);
        }
        
      } else{
        final List<dynamic> listData = await _supabase.from('machine_list').insert({
          'name': _nameController.text,
          'musclegroup': _selectedMuscleGroup,
          'icon': finalIconUrl, 
          'creator_id': widget.userId, 
        }).select();

        final newMachineId = listData[0]['id']; 

        await _supabase.from('machine_detail').insert({
          'machine_id': newMachineId, 
          'description': _descriptionController.text,
          'video': finalVideoUrl,
          'creator_id': widget.userId,
          'instructions': _instructionsController.text,
          'difficulty': _selectedDifficulty,
          'sets_reps': _setsRepsController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Machine Created Successfully!")));
          Navigator.pop(context); 
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
        title: Text(widget.machineData == null ? "Create New Machine" : "Edit Machine"),
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
              
              // --- 1. IMAGE PICKER (Web Compatible) ---
              const Text("Machine Image", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _imageFile != null
                        ? (kIsWeb 
                            // WEB: Use Image.network with path (Image.file not supported)
                            ? Image.network(_imageFile!.path, fit: BoxFit.cover) 
                            // MOBILE: Use Image.file
                            : Image.file(File(_imageFile!.path), fit: BoxFit.cover))
                        : (_iconUrlController.text.isNotEmpty)
                            ? Image.network( 
                                _iconUrlController.text, 
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => const Icon(Icons.broken_image, color: Colors.grey),
                              )
                            : Column( 
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo, size: 40, color: Color(0xFFD0FD3E)),
                                  SizedBox(height: 10),
                                  Text("Tap to upload image", style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ... REST OF YOUR FORM (Name, Description, etc.) ...
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Machine Name"),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _selectedMuscleGroup,
                dropdownColor: const Color(0xFF1C1C1E),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Muscle Group"),
                items: _muscleGroups.map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                onChanged: (val) => setState(() => _selectedMuscleGroup = val),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: _inputDecoration("Description"),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _instructionsController,
                style: const TextStyle(color: Colors.white),
                maxLines: 6,
                decoration: _inputDecoration("Step-by-step Instructions"),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      dropdownColor: const Color(0xFF1C1C1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Difficulty"),
                      items: _difficultyLevels.map((level) {
                        return DropdownMenuItem(value: level, child: Text(level));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedDifficulty = val),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: _setsRepsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Sets & Reps (e.g. 3x12)"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // --- 2. VIDEO PICKER (Web Compatible) ---
              const Text("Machine Video", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _videoUrlController,
                readOnly: true, // Prevent manual typing
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Pick Video File").copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.video_library, color: kPrimaryColor),
                    onPressed: _pickVideo,
                  ),
                ),
                onTap: _pickVideo, // Allow tapping the whole field to pick
              ),
              // TextFormField(
              //   controller: _videoUrlController,
              //   style: const TextStyle(color: Colors.white),
              //   decoration: _inputDecoration("Video URL (YouTube/MP4)"),
              //   keyboardType: TextInputType.url,
              // ),
              
              const SizedBox(height: 40),

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
                    : Text(widget.machineData == null ? "CREATE MACHINE" : "UPDATE MACHINE", 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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