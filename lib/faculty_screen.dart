// lib/screens/faculty_screen.dart
import 'faculty_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

import 'models/faculty_model.dart';
// faculty_detail_screen.dart and add_edit_faculty_screen.dart will be used via Navigator.
class FacultyScreen extends StatefulWidget {
  const FacultyScreen({super.key});

  @override
  State<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends State<FacultyScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser; // Get current user
  String? _currentUserRole; // To store the role of the current user
  // Initialize this future in initState to manage role fetching state
  late Future<String?> _userRoleFuture;
  Faculty? _myFacultyProfile; // To store the current user's faculty profile if it exists

  final Color _hogwartsBlue = const Color(0xFF0E1A40);
  final Color _gryffindorRed = const Color(0xFF740001);
  final Color _goldAccent = const Color(0xFFD3A625);
  final Color _parchmentBackground = const Color(0xFFF0EAD6);
  final Color _darkText = const Color(0xFF333333);
  final Color _lightCardBackground = const Color(0xFFF5F5DC);
  final Color _agedParchment = const Color(0xFFC8AD7F);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _userRoleFuture = _fetchCurrentUserRole(); // Initialize the future here
    _fetchMyFacultyProfile(); // Fetch profile on init
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<String?> _fetchCurrentUserRole() async {
    if (_currentUser == null) {
      // print('No current user for role fetching.'); // Debug
      return null; // No logged-in user
    }
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (mounted && userDoc.exists) {
        String? role = userDoc['role'] as String?;
        setState(() {
          _currentUserRole = role;
        });
        return role;
      }
      return null;
    } catch (e) {
      print('Error fetching user role: $e'); // Debugging print
      setState(() {
        _currentUserRole = null; // Fallback if error
      });
      return null;
    }
  }

  // Fetch current user's faculty profile (if they are faculty/admin and have one)
  Future<void> _fetchMyFacultyProfile() async {
    if (_currentUser == null) {
      setState(() {
        _myFacultyProfile = null; // No user logged in
      });
      return;
    }
    try {
      // Query for faculty profile linked to current user's ID
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('facultyProfiles') // Corrected collection name
          .where('userId', isEqualTo: _currentUser!.uid)
          .limit(1) // A user should only have one faculty profile
          .get();

      if (mounted) {
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _myFacultyProfile = Faculty.fromFirestore(querySnapshot.docs.first);
          });
        } else {
          setState(() {
            _myFacultyProfile = null; // No profile found for this user
          });
        }
      }
    } catch (e) {
      print("Error fetching my faculty profile: $e"); // Debugging print
      if (mounted) {
        setState(() {
          _myFacultyProfile = null; // Ensure null on error
        });
      }
    }
  }

  // This delete function will work with the Firestore collection
  Future<void> _deleteFaculty(String facultyId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _lightCardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Confirm Dismissal', style: TextStyle(color: _hogwartsBlue, fontFamily: 'HarryPotterFont')), // Themed title
          content: Text('Are you sure you want to dismiss this faculty record?', style: TextStyle(color: _darkText)), // Themed content
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: _gryffindorRed)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hogwartsBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Dismiss'), // Themed button
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _firestore.collection('facultyProfiles').doc(facultyId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Faculty record dismissed!', style: TextStyle(color: Colors.white)), // Themed success
              backgroundColor: _goldAccent,
            ),
          );
        }
      } catch (e) {
        print('Error dismissing faculty: $e'); // Debugging print
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to dismiss faculty: $e', style: TextStyle(color: Colors.white)), // Themed error
              backgroundColor: _gryffindorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the current user is authorized to manage faculty profiles
    bool canManageFacultyProfiles = _currentUserRole == 'faculty' || _currentUserRole == 'admin';

    return Scaffold(
      backgroundColor: _parchmentBackground,
      appBar: AppBar(
        title: const Text(
          'Hogwarts Professors',
          style: TextStyle(color: Colors.white, fontFamily: 'HarryPotterFont'),
        ),
        backgroundColor: _hogwartsBlue,
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, department, or role...', // Updated hint
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: _goldAccent),
                filled: true,
                fillColor: _hogwartsBlue.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _goldAccent, width: 1.5),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: _goldAccent,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('facultyProfiles').orderBy('name').snapshots(), // Corrected collection name
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _goldAccent));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading professors: ${snapshot.error}',
                    style: TextStyle(color: _gryffindorRed)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Display message to add profile if user can and no profiles exist
            if (canManageFacultyProfiles && _myFacultyProfile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_1, size: 80, color: _agedParchment),
                      const SizedBox(height: 20),
                      Text(
                        'No professor profiles found. Tap the "+" button to add your profile or a new one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: _darkText.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              );
            }
            // If no profiles exist and user is not faculty/admin
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 80, color: _agedParchment),
                    const SizedBox(height: 20),
                    Text(
                      'No professors registered yet!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: _darkText.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            );
          }

          List<Faculty> allFaculty = snapshot.data!.docs
              .map((doc) => Faculty.fromFirestore(doc)) 
              .toList();

          final filteredFaculty = allFaculty.where((faculty) {
            final query = _searchQuery.toLowerCase();
            return faculty.name.toLowerCase().contains(query) ||
                faculty.department.toLowerCase().contains(query) ||
                faculty.role.toLowerCase().contains(query) || 
                (faculty.bio?.toLowerCase().contains(query) ?? false) || // search bio
                (faculty.contactEmail?.toLowerCase().contains(query) ?? false) || // search contactEmail
                (faculty.yearsAtUniversity?.toLowerCase().contains(query) ?? false); //search yearsAtUniversity
          }).toList();

          if (filteredFaculty.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: _agedParchment),
                    const SizedBox(height: 20),
                    Text(
                      'No matching faculty found for "$_searchQuery". Try a different spell!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18, color: _darkText.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredFaculty.length,
            itemBuilder: (context, index) {
              final faculty = filteredFaculty[index];
              // Check if this card belongs to the current logged-in user
              bool isMyProfile = (_currentUser != null && faculty.userId == _currentUser!.uid);
              // Admin can edit any profile
              bool canEditAny = _currentUserRole == 'admin';

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isMyProfile ? _gryffindorRed : _goldAccent.withOpacity(0.5), width: 1.5), // Highlight user's own card
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: _lightCardBackground,
                child: InkWell(
                  // Only allow tap to edit if it's their profile OR if they are admin
                  onTap: (isMyProfile || canEditAny)
                      ? () {
                          Navigator.pushNamed(context, '/add_edit_faculty', arguments: faculty)
                              .then((_) => _fetchMyFacultyProfile()); // Refresh profile after edit
                        }
                      : () {
                          // For students/others, tap to view details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FacultyDetailScreen(faculty: faculty),
                            ),
                          );
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: _hogwartsBlue.withOpacity(0.1),
                              backgroundImage: (faculty.profileImageUrl != null && faculty.profileImageUrl!.isNotEmpty)
                                  ? NetworkImage(faculty.profileImageUrl!) as ImageProvider<Object>
                                  : null,
                              child: (faculty.profileImageUrl == null || faculty.profileImageUrl!.isEmpty)
                                  ? Icon(Icons.person, size: 30, color: _hogwartsBlue)
                                  : null,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    faculty.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _hogwartsBlue,
                                      fontFamily: 'HarryPotterFont',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${faculty.role}, ${faculty.department}', // Combined role and department
                                    style: TextStyle(fontSize: 15, color: _darkText.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                            ),
                            // Show Edit/Delete only if it's their profile OR if they are admin
                            if (isMyProfile || canEditAny)
                              IconButton(
                                icon: Icon(Icons.edit, color: _gryffindorRed),
                                onPressed: () async {
                                  // Add confirmation for Admin trying to edit someone else's profile
                                  if (!isMyProfile && canEditAny) { // Admin editing someone else
                                    bool? confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          backgroundColor: _lightCardBackground,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: Text('Ministry Oversight', style: TextStyle(color: _hogwartsBlue, fontFamily: 'HarryPotterFont')),
                                          content: Text('As an Admin, you are about to edit another professor\'s profile. Are you sure you want to proceed?', style: TextStyle(color: _darkText)),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.of(dialogContext).pop(false),
                                              child: Text('Cancel', style: TextStyle(color: _hogwartsBlue)),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(dialogContext).pop(true),
                                              style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: _gryffindorRed),
                                              child: const Text('Proceed', style: TextStyle(fontFamily: 'HarryPotterFont')),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirm != true) return;
                                  }
                                  Navigator.pushNamed(context, '/add_edit_faculty', arguments: faculty)
                                      .then((_) => _fetchMyFacultyProfile()); // Refresh profile after edit
                                },
                                tooltip: 'Edit Professor Profile',
                              ),
                          ],
                        ),
                        if (faculty.yearsAtUniversity != null && faculty.yearsAtUniversity!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.hourglass_empty, size: 16, color: _goldAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Years at Hogwarts: ${faculty.yearsAtUniversity}',
                                  style: TextStyle(fontSize: 14, color: _darkText.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                        if (faculty.bio != null && faculty.bio!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              faculty.bio!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: _darkText.withOpacity(0.6)),
                            ),
                          ),
                        if (faculty.contactEmail != null && faculty.contactEmail!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.mail, size: 16, color: _goldAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Owl Post: ${faculty.contactEmail}',
                                  style: TextStyle(fontSize: 14, color: _darkText.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<String?>(
        future: _userRoleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return FloatingActionButton(
              onPressed: null,
              backgroundColor: _goldAccent.withOpacity(0.5),
              foregroundColor: Colors.white,
              child: const Icon(Icons.hourglass_empty),
            );
          }
          final String? userRole = snapshot.data;
          bool canManageFaculty = userRole == 'faculty' || userRole == 'admin';

          if (!canManageFaculty) {
            return const SizedBox.shrink(); // Completely hide if not permitted
          }

          // Show FAB based on whether the current user has a profile or not
          return FloatingActionButton(
            onPressed: () {
              if (_myFacultyProfile != null) {
                // User has a profile, navigate to edit it
                Navigator.pushNamed(context, '/add_edit_faculty', arguments: _myFacultyProfile)
                    .then((_) => _fetchMyFacultyProfile()); // Refresh after edit
              } else {
                // User does not have a profile, navigate to create a new one
                Navigator.pushNamed(context, '/add_edit_faculty')
                    .then((_) => _fetchMyFacultyProfile()); // Refresh after creation
              }
            },
            backgroundColor: _goldAccent,
            foregroundColor: Colors.white,
            child: _myFacultyProfile != null ? const Icon(Icons.edit) : const Icon(Icons.add), // Change icon based on state
            tooltip: _myFacultyProfile != null ? ' My Professor Profile' : 'Add My Professor Profile', // Themed tooltip
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}