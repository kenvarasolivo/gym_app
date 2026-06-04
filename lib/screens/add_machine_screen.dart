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
  
  XFile? _imageFile; 
  XFile? _videoFile;
  final _picker = ImagePicker();

  String? _selectedMuscleGroup;
  String? _selectedDifficulty;

  final List<String> _muscleGroups = ['Chest', 'Side Shoulders', 'Front Shoulders', 'Biceps', 'Arms', 'Quads', 'Abs', 'Shins', 'Neck', 'Rear Shoulders', 'Triceps', 'Lower Back', 'Traps', 'Middle Back', 'Lats', 'Glutes', 'Hamstrings', 'Calves'];
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

      if (kIsWeb) {
        final bytes = await _imageFile!.readAsBytes();
        await _supabase.storage.from('machine_images').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
        );
      } else {
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
        maxDuration: const Duration(minutes: 5), 
      );
      
      if (pickedFile != null) {
        setState(() {
          _videoFile = pickedFile;
          _videoUrlController.text = pickedFile.name; 
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
      final filePath = 'videos/$fileName'; 

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
      //Handle Image Upload
      String finalIconUrl = _iconUrlController.text;
      if (_imageFile != null) {
        final uploadedUrl = await _uploadImage();
        if (uploadedUrl != null) {
          finalIconUrl = uploadedUrl;
        } else {
          throw "Image upload failed"; 
        }
      }

      // Handle Video (File or YouTube link)
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
    final isEditing = widget.machineData != null;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? "EDIT MACHINE" : "CREATE MACHINE",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // --- IMAGE PICKER ---
              _label("MACHINE IMAGE"),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _imageFile != null
                        ? (kIsWeb
                            ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                            : Image.file(File(_imageFile!.path), fit: BoxFit.cover))
                        : (_iconUrlController.text.isNotEmpty)
                            ? Image.network(
                                _iconUrlController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => const Icon(Icons.broken_image, color: kMutedText),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor.withAlpha(25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add_a_photo_outlined,
                                        size: 28, color: kPrimaryColor),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text("Tap to upload image",
                                      style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- TEXT FIELDS ---
              _label("DETAILS"),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Machine Name"),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _selectedMuscleGroup,
                dropdownColor: kCardColor,
                borderRadius: BorderRadius.circular(14),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Muscle Group"),
                items: _muscleGroups.map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                onChanged: (val) => setState(() => _selectedMuscleGroup = val),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: _inputDecoration("Description"),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _instructionsController,
                style: const TextStyle(color: Colors.white),
                maxLines: 6,
                decoration: _inputDecoration("Step-by-step Instructions"),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDifficulty,
                      dropdownColor: kCardColor,
                      borderRadius: BorderRadius.circular(14),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Difficulty"),
                      items: _difficultyLevels.map((level) {
                        return DropdownMenuItem(value: level, child: Text(level));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedDifficulty = val),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _setsRepsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Sets & Reps"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- VIDEO INPUT ---
              _label("MACHINE VIDEO"),
              const SizedBox(height: 10),
              TextFormField(
                controller: _videoUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Video URL or pick a file").copyWith(
                  hintText: "https://youtube.com/...",
                  hintStyle: const TextStyle(color: kMutedText),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.upload_file, color: kPrimaryColor),
                    tooltip: "Pick Video File",
                    onPressed: _pickVideo,
                  ),
                ),
                onChanged: (value) {
                  if (_videoFile != null) {
                    setState(() {
                      _videoFile = null;
                    });
                  }
                },
              ),

              const SizedBox(height: 32),

              // --- SUBMIT BUTTON ---
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : Text(isEditing ? "UPDATE MACHINE" : "CREATE MACHINE",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: kSectionLabel);

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kMutedText),
      filled: true,
      fillColor: kCardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
      ),
    );
  }
}