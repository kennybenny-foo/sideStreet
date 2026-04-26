import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'content_filter.dart';

class EditSpotScreen extends StatefulWidget {
  final String spotId;
  final String title;
  final String category;
  final String description;
  final String location;
  final String vibe;

  const EditSpotScreen({
    super.key,
    required this.spotId,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.vibe,
  });

  @override
  State<EditSpotScreen> createState() => _EditSpotScreenState();
}

class _EditSpotScreenState extends State<EditSpotScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _vibeController;

  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _locationController = TextEditingController(text: widget.location);
    _descriptionController = TextEditingController(text: widget.description);
    _vibeController = TextEditingController(text: widget.vibe);
    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _vibeController.dispose();
    super.dispose();
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

  Widget _buildLabel(String text, {bool required = false}) {
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
        if (required)
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('spots')
          .doc(widget.spotId)
          .update({
        'title': _titleController.text.trim(),
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'vibe': _vibeController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spot updated successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update spot: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      appBar: AppBar(
        title: Text(
          'Edit Spot',
          style: GoogleFonts.comfortaa(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F2A25),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE9E1D3),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF2F2A25),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Place Name', required: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    return ContentFilter.validateCleanText(
                      value,
                      emptyMessage: 'Place name is required.',
                      blockedMessage:
                      'Place name contains inappropriate language.',
                    );
                  },
                  decoration: _inputDecoration('Enter the name of the spot'),
                ),
                const SizedBox(height: 20),
                _buildLabel('Category', required: true),
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
                _buildLabel('Location', required: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  validator: (value) {
                    return ContentFilter.validateCleanText(
                      value,
                      emptyMessage: 'Location is required.',
                      blockedMessage:
                      'Location contains inappropriate language.',
                    );
                  },
                  decoration: _inputDecoration(
                    'Enter city, neighborhood, or area',
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('Why is it special?', required: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  validator: (value) {
                    return ContentFilter.validateCleanText(
                      value,
                      emptyMessage: 'Description is required.',
                      blockedMessage:
                      'Description contains inappropriate language.',
                    );
                  },
                  decoration: _inputDecoration(
                    'Describe what makes this place worth visiting',
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('Vibe'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _vibeController,
                  validator: (value) {
                    return ContentFilter.validateOptionalCleanText(
                      value,
                      blockedMessage:
                      'Vibe contains inappropriate language.',
                    );
                  },
                  decoration: _inputDecoration(
                    'Quiet, cozy, scenic, lively, artsy...',
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
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
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}