// lib/user_profile_screen.dart
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; 
import 'cloudinary_service.dart';
import 'models/alumni_model.dart';
import 'models/faculty_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService(); // Instance of your Cloudinary service

  // General user profile controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _majorController = TextEditingController(); // This is general specialization/house
  final TextEditingController _linkedInController = TextEditingController(); // General LinkedIn controller

  // Alumni specific controllers (align with alumni_model.dart fields)
  final TextEditingController _alumniGraduationYearController = TextEditingController();
  final TextEditingController _alumniOccupationController = TextEditingController(); 
  final TextEditingController _alumniContributionController = TextEditingController(); 

  // Faculty specific controllers (align with faculty_model.dart fields)
  final TextEditingController _facultyDepartmentController = TextEditingController();
  final TextEditingController _facultyRoleController = TextEditingController(); 
  final TextEditingController _facultyYearsAtUniversityController = TextEditingController(); 
  final TextEditingController _facultyContactEmailController = TextEditingController();


  String? _currentProfileImageUrl; 
  File? _pickedImage; 
  String? _selectedBatch; 
  String _userRole = 'student'; 
  bool _isLoading = false;

  final Color _hogwartsBlue = const Color(0xFF0E1A40); 
  final Color _gryffindorRed = const Color(0xFF740001); 
  final Color _goldAccent = const Color(0xFFD3A625); 
  final Color _parchmentBackground = const Color(0xFFF0EAD6); 
  final Color _darkText = const Color(0xFF333333); 
  final Color _lightCardBackground = const Color(0xFFF5F5DC); 
  final Color _agedParchment = const Color(0xFFC8AD7F);

  // Generate a list of batch years (e.g., from 5 years ago to 5 years in the future)
  List<String> _generateBatchYears() {
    final int currentYear = DateTime.now().year;
    List<String> batches = [];
    // Start from, for example, 10 years ago to 5 years from now
    for (int startYear = currentYear - 10; startYear <= currentYear + 5; startYear++) {
      int endYear = startYear + 3; // 3-year gap for the batch
      batches.add('$startYear - $endYear');
    }
    return batches;
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = currentUser?.email ?? 'N/A'; 
    _fetchUserProfileAndRole();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _majorController.dispose();
    _linkedInController.dispose();
    _alumniGraduationYearController.dispose();
    _alumniOccupationController.dispose(); 
    _alumniContributionController.dispose(); 
    _facultyDepartmentController.dispose();
    _facultyRoleController.dispose(); 
    _facultyYearsAtUniversityController.dispose(); 
    _facultyContactEmailController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfileAndRole() async {
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!mounted) return; // Ensure widget is still mounted after async call

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _majorController.text = data['major'] ?? '';
        _linkedInController.text = data['linkedIn'] ?? '';

        String? batchFromDb = data['batch'];
        List<String> availableBatches = _generateBatchYears();
        if (batchFromDb != null && availableBatches.contains(batchFromDb)) {
          _selectedBatch = batchFromDb;
        } else {
          _selectedBatch = null;
        }

        _currentProfileImageUrl = data['profileImageUrl'];
        _userRole = data['role'] ?? 'student'; // Fetch user role

        // Fetch and populate Alumni/Faculty specific data based on role
        if (_userRole == 'alumni') {
          // Corrected collection name to 'alumniProfiles'
          DocumentSnapshot alumniDoc = await _firestore.collection('alumniProfiles').doc(currentUser!.uid).get();
          if (alumniDoc.exists) {
            final alumniData = alumniDoc.data() as Map<String, dynamic>;
            _alumniGraduationYearController.text = alumniData['graduationYear']?.toString() ?? ''; // Convert int to string
            _alumniOccupationController.text = alumniData['occupation'] ?? ''; // Corrected field name
            _alumniContributionController.text = alumniData['contribution'] ?? ''; // Corrected field name
          }
        } else if (_userRole == 'faculty') {
          // Corrected collection name to 'facultyProfiles'
          DocumentSnapshot facultyDoc = await _firestore.collection('facultyProfiles').doc(currentUser!.uid).get();
          if (facultyDoc.exists) {
            final facultyData = facultyDoc.data() as Map<String, dynamic>;
            _facultyDepartmentController.text = facultyData['department'] ?? '';
            _facultyRoleController.text = facultyData['role'] ?? ''; // Corrected field name
            _facultyYearsAtUniversityController.text = facultyData['yearsAtUniversity'] ?? ''; // Corrected field name
            _facultyContactEmailController.text = facultyData['contactEmail'] ?? '';
          }
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      _showSnackBar('Failed to fetch profile data: $e', _gryffindorRed);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                  'Choose Profile Scroll',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _hogwartsBlue, fontFamily: 'HarryPotterFont'),
                ),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: _hogwartsBlue),
                title: Text('Photo Library (Pensieve)', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: _hogwartsBlue),
                title: Text('Camera (Daily Prophet Photographer)', style: TextStyle(color: _darkText)),
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
        _currentProfileImageUrl = null;
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_pickedImage == null || currentUser == null) return null;

    setState(() {
      _isLoading = true;
    });

    try {
      _showSnackBar('Engraving profile scroll to Cloudinary...', _goldAccent);
      String? uploadedUrl = await _cloudinaryService.uploadImage(_pickedImage!);
      if (!mounted) return null;

      if (uploadedUrl != null) {
        _showSnackBar('Profile scroll engraved successfully!', _gryffindorRed);
        return uploadedUrl;
      } else {
        _showSnackBar('Failed to engrave profile scroll to Cloudinary.', _gryffindorRed);
        return null;
      }
    } catch (e) {
      print('Cloudinary Upload Error: $e');
      _showSnackBar('Magical interference during upload: $e', _gryffindorRed);
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill in required fields.', _gryffindorRed);
      return;
    }

    if (currentUser == null) {
      _showSnackBar('No wizard logged in to update profile.', _gryffindorRed);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? finalProfileImageUrl = _currentProfileImageUrl;

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

      if (currentUser!.displayName != _nameController.text && _nameController.text.isNotEmpty) {
        await currentUser!.updateDisplayName(_nameController.text);
      }

      // Update general user document
      await _firestore.collection('users').doc(currentUser!.uid).set(
        {
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'major': _majorController.text.trim(),
          'batch': _selectedBatch,
          'linkedIn': _linkedInController.text.trim().isEmpty ? null : _linkedInController.text.trim(),
          'profileImageUrl': finalProfileImageUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
          'role': _userRole, // Ensure role is saved consistently
        },
        SetOptions(merge: true),
      );

      // Save Alumni/Faculty specific collections based on role
      if (_userRole == 'alumni') {
        final alumniData = Alumni(
          id: currentUser!.uid, // Use user's UID as alumni document ID
          name: _nameController.text.trim(),
          // Corrected mapping for Alumni fields
          // Ensure these match your alumni_model.dart exactly
          graduationYear: int.tryParse(_alumniGraduationYearController.text.trim()) ?? 0, // Convert to int
          degreeMajor: _majorController.text.trim(), // Use general major field for degreeMajor
          occupation: _alumniOccupationController.text.trim(), // Corrected
          company: '', // Assuming company is not captured directly here, add a controller if needed
          location: '', // Assuming location is not captured directly here, add a controller if needed
          contribution: _alumniContributionController.text.trim(), // Corrected
          linkedIn: _linkedInController.text.trim().isEmpty ? null : _linkedInController.text.trim(),
          profileImageUrl: finalProfileImageUrl,
        );
        await _firestore.collection('alumniProfiles').doc(currentUser!.uid).set(alumniData.toFirestore()); // Corrected collection name
      } else if (_userRole == 'faculty') {
        final facultyData = Faculty(
          id: currentUser!.uid, // Use user's UID as faculty document ID
          name: _nameController.text.trim(),
          // Corrected mapping for Faculty fields
          // Ensure these match your faculty_model.dart exactly
          department: _facultyDepartmentController.text.trim(),
          role: _facultyRoleController.text.trim(), // Corrected
          yearsAtUniversity: _facultyYearsAtUniversityController.text.trim(), // Corrected
          bio: _bioController.text.trim(), // Use general bio for faculty bio
          contactEmail: _facultyContactEmailController.text.trim(),
          linkedIn: _linkedInController.text.trim().isEmpty ? null : _linkedInController.text.trim(),
          profileImageUrl: finalProfileImageUrl,
        );
        await _firestore.collection('facultyProfiles').doc(currentUser!.uid).set(facultyData.toFirestore()); // Corrected collection name
      }

      if (!mounted) return;

      _showSnackBar('Wizard profile updated successfully!', _gryffindorRed);
      Navigator.pop(context, {'profileUpdated': true});
    } catch (e) {
      print('Error saving wizard profile: $e');
      _showSnackBar('Failed to update wizard profile: $e', _gryffindorRed);
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
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: _parchmentBackground,
      appBar: AppBar(
        title: const Text('My Wizard Profile', style: TextStyle(fontFamily: 'HarryPotterFont')),
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
                                : (_currentProfileImageUrl != null && _currentProfileImageUrl!.isNotEmpty
                                    ? NetworkImage(_currentProfileImageUrl!)
                                    : null),
                            child: (_pickedImage == null && (_currentProfileImageUrl == null || _currentProfileImageUrl!.isEmpty))
                                ? Icon(
                                    Icons.person,
                                    size: 80,
                                    color: _hogwartsBlue.withOpacity(0.7),
                                  )
                                : null,
                          ),
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
                      labelText: 'Wizard Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your wizard name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _emailController,
                      labelText: 'Owl Post Address',
                      icon: Icons.email,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _bioController,
                      labelText: 'About My Magical Journey',
                      icon: Icons.info_outline,
                      hintText: 'Tell us a bit about your adventures in the wizarding world...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _majorController,
                      labelText: 'Hogwarts House / Specialization',
                      icon: Icons.school_outlined,
                      hintText: 'e.g., Gryffindor, Potions Master, Magizoologist',
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _linkedInController,
                      labelText: 'Daily Prophet Link (LinkedIn/Social)',
                      icon: Icons.link,
                      hintText: 'e.g., https://prophet.com/yourprofile',
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.isAbsolute || !uri.hasScheme || !uri.hasAuthority) {
                            return 'Please enter a valid URL (e.g., https://...).';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      value: _selectedBatch,
                      decoration: InputDecoration(
                        labelText: 'Batch',
                        prefixIcon: Icon(Icons.calendar_today, color: _goldAccent),
                      ),
                      hint: const Text('Select your batch'),
                      items: _generateBatchYears().map((String batch) {
                        return DropdownMenuItem<String>(
                          value: batch,
                          child: Text(batch, style: TextStyle(color: onSurfaceColor)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBatch = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your batch.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Conditional fields based on user role
                    if (_userRole == 'alumni') ...[
                      Text('Alumni Specific Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _hogwartsBlue, fontFamily: 'HarryPotterFont')),
                      const SizedBox(height: 15),
                      _buildTextFormField(
                        controller: _alumniGraduationYearController,
                        labelText: 'Graduation Year',
                        hintText: 'e.g., 1998',
                        icon: Icons.school,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter graduation year';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _alumniOccupationController,
                        labelText: 'Current Occupation',
                        hintText: 'e.g., Head Auror',
                        icon: Icons.work,
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _alumniContributionController, 
                        labelText: 'Achievements / Contributions',
                        hintText: 'e.g., Defeated Lord Voldemort, Co-Founder of Dumbledore\'s Army',
                        icon: Icons.star,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),
                    ] else if (_userRole == 'faculty') ...[
                      Text('Faculty Specific Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _hogwartsBlue, fontFamily: 'HarryPotterFont')),
                      const SizedBox(height: 15),
                      _buildTextFormField(
                        controller: _facultyDepartmentController,
                        labelText: 'Department',
                        hintText: 'e.g., Transfiguration',
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _facultyRoleController, 
                        labelText: 'Role',
                        hintText: 'e.g., Head of House, Professor',
                        icon: Icons.badge, 
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _facultyYearsAtUniversityController, 
                        labelText: 'Years at Hogwarts', 
                        hintText: 'e.g., 15+ years',
                        icon: Icons.hourglass_empty,
                        maxLines: 1, 
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _facultyContactEmailController,
                        labelText: 'Contact Email',
                        hintText: 'e.g., mcgonagall@hogwarts.ac.uk',
                        icon: Icons.mail,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                    ],

                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: _goldAccent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _gryffindorRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: const Text('Save Profile Scroll', style: TextStyle(fontSize: 18, fontFamily: 'HarryPotterFont')),
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