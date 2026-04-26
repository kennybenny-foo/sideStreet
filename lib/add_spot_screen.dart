import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'content_filter.dart';

class AddSpotScreen extends StatefulWidget {
  const AddSpotScreen({super.key});

  @override
  State<AddSpotScreen> createState() => _AddSpotScreenState();
}

class _AddSpotScreenState extends State<AddSpotScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _specialController = TextEditingController();
  final TextEditingController _vibeController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedCategory;
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _placeNameController.dispose();
    _locationController.dispose();
    _specialController.dispose();
    _vibeController.dispose();
    super.dispose();
  }

  Widget _buildRequiredLabel(String text) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.comfortaa(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2F2A25),
          ),
        ),
        Text(
          ' *',
          style: GoogleFonts.comfortaa(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionalLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.comfortaa(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2F2A25),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.comfortaa(
        fontSize: 13,
        color: Colors.grey[600],
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      errorStyle: GoogleFonts.comfortaa(
        fontSize: 11,
        color: Colors.red,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String> _uploadImage(String userId) async {
    final file = _selectedImage!;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = FirebaseStorage.instance
        .ref()
        .child('spot_images')
        .child(userId)
        .child(fileName);

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState!.validate();

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a photo before submitting.'),
        ),
      );
      return;
    }

    if (!isValid) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to add a spot.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final imageUrl = await _uploadImage(user.uid);

      await FirebaseFirestore.instance.collection('spots').add({
        'title': _placeNameController.text.trim(),
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'description': _specialController.text.trim(),
        'vibe': _vibeController.text.trim(),
        'imageUrl': imageUrl,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _placeNameController.clear();
      _locationController.clear();
      _specialController.clear();
      _vibeController.clear();

      setState(() {
        _selectedCategory = null;
        _selectedImage = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Spot submitted successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit spot: $e'),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share a hidden gem',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F2A25),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Add a lesser-known place worth discovering.',
                style: GoogleFonts.comfortaa(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              _buildRequiredLabel('Place Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _placeNameController,
                validator: (value) {
                  return ContentFilter.validateCleanText(
                    value,
                    emptyMessage: 'Place name is required.',
                    blockedMessage: 'Place name contains inappropriate language.',
                  );
                },
                decoration: _inputDecoration('Enter the name of the spot'),
              ),

              const SizedBox(height: 20),

              _buildRequiredLabel('Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: GoogleFonts.comfortaa(
                    fontSize: 11,
                    color: Colors.red,
                  ),
                ),
                hint: Text(
                  'Select a category',
                  style: GoogleFonts.comfortaa(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Coffee', child: Text('Coffee')),
                  DropdownMenuItem(value: 'Food', child: Text('Food')),
                  DropdownMenuItem(value: 'Nature', child: Text('Nature')),
                  DropdownMenuItem(value: 'Views', child: Text('Views')),
                  DropdownMenuItem(value: 'Shops', child: Text('Shops')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required.';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              _buildRequiredLabel('Location'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                validator: (value) {
                  return ContentFilter.validateCleanText(
                    value,
                    emptyMessage: 'Location is required.',
                    blockedMessage: 'Location contains inappropriate language.',
                  );
                },
                decoration: _inputDecoration(
                  'Enter city, neighborhood, or area',
                ),
              ),

              const SizedBox(height: 20),

              _buildRequiredLabel('Why is it special?'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specialController,
                maxLines: 5,
                validator: (value) {
                  return ContentFilter.validateCleanText(
                    value,
                    emptyMessage: 'Please describe why this spot is special.',
                    blockedMessage: 'Description contains inappropriate language.',
                  );
                },
                decoration: _inputDecoration(
                  'Describe what makes this place worth visiting',
                ),
              ),

              const SizedBox(height: 20),

              _buildOptionalLabel('Vibe'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _vibeController,
                validator: (value) {
                  return ContentFilter.validateOptionalCleanText(
                    value,
                    blockedMessage: 'Vibe contains inappropriate language.',
                  );
                },
                decoration: _inputDecoration(
                  'Quiet, cozy, scenic, lively, artsy...',
                ),
              ),

              const SizedBox(height: 20),

              _buildRequiredLabel('Add a Photo'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedImage != null
                          ? const Color(0xFF5E6F52)
                          : const Color(0xFFD8CCBC),
                      width: 1.5,
                    ),
                  ),
                  child: _selectedImage != null
                      ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 160,
                          width: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Photo selected',
                        style: GoogleFonts.comfortaa(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F2A25),
                        ),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        size: 36,
                        color: Color(0xFF5E6F52),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Upload a photo',
                        style: GoogleFonts.comfortaa(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F2A25),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap here to choose an image',
                        style: GoogleFonts.comfortaa(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E6F52),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: GoogleFonts.comfortaa(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Spot'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}