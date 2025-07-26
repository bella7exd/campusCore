// lib/screens/add_edit_faculty_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'models/faculty_model.dart'; 
import 'cloudinary_service.dart'; 

class AddEditFacultyScreen extends StatefulWidget {
  final Faculty? faculty; // Optional: for editing existing faculty

  const AddEditFacultyScreen({super.key, this.faculty});

  @override
  State<AddEditFacultyScreen> createState() => _AddEditFacultyScreenState();
}

class _AddEditFacultyScreenState extends State<AddEditFacultyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _yearsAtUniversityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService(); 

  User? _currentUser;
  String? _currentUserRole; // To check if current user is admin
  bool _isLoading = false;
  File? _pickedImage;
  String? _profileImageUrl; // Current image URL from Firestore or after upload

  final Color _hogwartsBlue = const Color(0xFF0E1A40);
  final Color _gryffindorRed = const Color(0xFF740001);
  final Color _goldAccent = const Color(0xFFD3A625);
  final Color _parchmentBackground = const Color(0xFFF0EAD6);
  final Color _darkText = const Color(0xFF333333);
  final Color _lightCardBackground = const Color(0xFFF5F5DC);
  final Color _agedParchment = const Color(0xFFC8AD7F);

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchCurrentUserRole(); // Fetching role to determine edit permissions

    if (widget.faculty != null) {
      _nameController.text = widget.faculty!.name;
      _departmentController.text = widget.faculty!.department;
      _roleController.text = widget.faculty!.role;
      _yearsAtUniversityController.text = widget.faculty!.yearsAtUniversity ?? '';
      _bioController.text = widget.faculty!.bio ?? '';
      _contactEmailController.text = widget.faculty!.contactEmail ?? '';
      _profileImageUrl = widget.faculty!.profileImageUrl;
    }
  }

  Future<void> _fetchCurrentUserRole() async {
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _currentUserRole = userData['role'] as String?;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _roleController.dispose();
    _yearsAtUniversityController.dispose();
    _bioController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _lightCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose Professor Portrait', // Themed title
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _hogwartsBlue, fontFamily: 'HarryPotterFont'),
                ),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: _hogwartsBlue),
                title: Text('Gallary', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: _hogwartsBlue),
                title: Text('Camera', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageSource(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        _profileImageUrl = null; // Clear old network URL to show new local image
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_pickedImage == null || _currentUser == null) return null;

    try {
      _showSnackBar('Engraving professor portrait...', _goldAccent);
      String? uploadedUrl = await _cloudinaryService.uploadImage(_pickedImage!);
      if (!mounted) return null;

      if (uploadedUrl != null) {
        _showSnackBar('Professor portrait engraved successfully!', _gryffindorRed);
        return uploadedUrl;
      } else {
        _showSnackBar('Failed to engrave professor portrait to Cloudinary.', _gryffindorRed);
        return null;
      }
    } catch (e) {
      print('Cloudinary Upload Error: $e');
      _showSnackBar('Magical interference during upload: $e', _gryffindorRed);
      return null;
    }
  }

  Future<void> _saveFacultyProfile() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill in all required fields.', _gryffindorRed);
      return;
    }

    if (_currentUser == null) {
      _showSnackBar('You must be logged in to save a professor profile.', _gryffindorRed);
      return;
    }

    // Check if the current user is authorized to add/edit faculty profiles
    if (_currentUserRole != 'faculty' && _currentUserRole != 'admin') {
      _showSnackBar('Only Hogwarts Faculty or Ministry Officials can manage professor profiles.', _gryffindorRed);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? finalProfileImageUrl = _profileImageUrl;

    try {
      if (_pickedImage != null) {
        finalProfileImageUrl = await _uploadProfileImage();
        if (finalProfileImageUrl == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      Faculty facultyToSave = Faculty(
        id: widget.faculty?.id, // Keep existing ID if editing
        name: _nameController.text.trim(),
        department: _departmentController.text.trim(),
        role: _roleController.text.trim(),
        yearsAtUniversity: _yearsAtUniversityController.text.trim(),
        bio: _bioController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        profileImageUrl: finalProfileImageUrl,
        userId: widget.faculty?.userId ?? _currentUser!.uid, // Set userId if new, keep existing if editing
      );

      if (widget.faculty == null) {
        // Add new faculty profile
        await _firestore.collection('facultyProfiles').add(facultyToSave.toFirestore());
        _showSnackBar('Professor profile added successfully!', _gryffindorRed);
      } else {
        // Update existing faculty profile
        await _firestore.collection('facultyProfiles').doc(facultyToSave.id).update(facultyToSave.toFirestore());
        _showSnackBar('Professor profile updated successfully!', _gryffindorRed);
      }

      if (mounted) {
        Navigator.of(context).pop(); // Go back to faculty list
      }
    } catch (e) {
      print('Error saving professor profile: $e');
      _showSnackBar('Failed to save professor profile: $e', _gryffindorRed);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if fields should be read-only based on user role and ownership
    bool canEdit = widget.faculty == null // New profile, so editable
        || (_currentUser != null && (widget.faculty!.userId == _currentUser!.uid || _currentUserRole == 'admin')); // User is owner OR admin

    return Scaffold(
      backgroundColor: _parchmentBackground,
      appBar: AppBar(
        title: Text(widget.faculty == null ? 'Add New Professor' : 'Professor Profile', style: TextStyle(fontFamily: 'HarryPotterFont', color: Colors.white)),
        backgroundColor: _hogwartsBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _goldAccent))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: _agedParchment.withOpacity(0.5),
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!) as ImageProvider<Object>
                                : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                    ? NetworkImage(_profileImageUrl!) as ImageProvider<Object>
                                    : null),
                            child: (_pickedImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                                ? Icon(Icons.person, size: 80, color: _hogwartsBlue.withOpacity(0.7))
                                : null,
                          ),
                          if (canEdit) // Only show camera icon if editable
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _goldAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextFormField(
                      controller: _nameController,
                      labelText: 'Professor Name',
                      icon: Icons.person_outline,
                      readOnly: !canEdit,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the professor\'s name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _departmentController,
                      labelText: 'Department (e.g., Charms, Potions)',
                      icon: Icons.category,
                      readOnly: !canEdit,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the department.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _roleController,
                      labelText: 'Role (e.g., Head of House, Professor)',
                      icon: Icons.badge,
                      readOnly: !canEdit,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the role.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _yearsAtUniversityController,
                      labelText: 'Years at Hogwarts (e.g., "15+ years")',
                      icon: Icons.hourglass_empty,
                      readOnly: !canEdit,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _bioController,
                      labelText: 'Professor\'s Bio/Specialty',
                      icon: Icons.info_outline,
                      hintText: 'e.g., Expert in ancient runic magic...',
                      maxLines: 3,
                      readOnly: !canEdit,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _contactEmailController,
                      labelText: 'Owl Post Contact',
                      icon: Icons.mail_outline,
                      hintText: 'e.g., professor@hogwarts.ac.uk',
                      keyboardType: TextInputType.emailAddress,
                      readOnly: !canEdit,
                    ),
                    const SizedBox(height: 30),
                    if (canEdit) // Only show save button if editable
                      ElevatedButton(
                        onPressed: _saveFacultyProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gryffindorRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(widget.faculty == null ? 'Add Professor' : 'Update Profile', style: TextStyle(fontSize: 18, fontFamily: 'HarryPotterFont')),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: _goldAccent),
      ),
      validator: validator,
      style: TextStyle(color: _darkText),
    );
  }
}