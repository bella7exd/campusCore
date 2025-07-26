
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'models/alumni_model.dart'; 

class AlumniScreen extends StatefulWidget {
  const AlumniScreen({super.key});

  @override
  State<AlumniScreen> createState() => _AlumniScreenState();
}

class _AlumniScreenState extends State<AlumniScreen> {
  User? _currentUser;
  String? _currentUserRole; // To store current user's role
  late Future<String?> _userRoleFuture; // Future to manage role fetching state

  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // State to hold the current search query


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
    _currentUser = FirebaseAuth.instance.currentUser;
    _userRoleFuture = _fetchCurrentUserRole();
    _searchController.addListener(_onSearchChanged); // Listen for search input changes
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
      return null;
    }
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _currentUserRole = userData['role'] as String?;
        });
        return userData['role'] as String?;
      }
      return null;
    } catch (e) {
      print("Error fetching user role for alumni screen: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canAddAlumni = _currentUserRole == 'alumni' || _currentUserRole == 'admin'; // Determine if FAB should be shown

    return Scaffold(
      backgroundColor: _parchmentBackground, // Themed screen background
      appBar: AppBar(
        title: const Text(
          'Order of the Phoenix Alumni', // Themed title
          style: TextStyle(color: Colors.white, fontFamily: 'HarryPotterFont'),
        ),
        backgroundColor: _hogwartsBlue, // Themed app bar color
        elevation: 4, // Increased elevation for a floating effect
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize( // Add a PreferredSize widget for the search bar
          preferredSize: const Size.fromHeight(kToolbarHeight + 10), // Height for the search bar
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, occupation, or year...', // Themed hint
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: _goldAccent), // Themed icon
                filled: true,
                fillColor: _hogwartsBlue.withOpacity(0.8), // Themed fill color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _goldAccent, width: 1.5), // Themed focused border
                ),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: _goldAccent, // Themed cursor color
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream to fetch all alumni profiles
        stream: FirebaseFirestore.instance.collection('alumniProfiles').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _goldAccent)); // Themed loading
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading alumni: ${snapshot.error}', style: TextStyle(color: _gryffindorRed)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group, size: 80, color: _agedParchment), // Themed icon
                    const SizedBox(height: 20),
                    Text(
                      'No alumni registered yet! Be the first to add one.', // Themed message
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: _darkText.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            );
          }

          List<Alumni> allAlumni = snapshot.data!.docs 
              .map((doc) => Alumni.fromFirestore(doc)) 
              .toList();

          final filteredAlumni = allAlumni.where((alumni) {
            final query = _searchQuery.toLowerCase();
            return alumni.name.toLowerCase().contains(query) ||
                alumni.occupation.toLowerCase().contains(query) ||
                (alumni.contribution?.toLowerCase().contains(query) ?? false) || 
                alumni.company.toLowerCase().contains(query) || 
                (alumni.location?.toLowerCase().contains(query) ?? false) || 
                alumni.degreeMajor.toLowerCase().contains(query) ||
                alumni.graduationYear.toString().toLowerCase().contains(query) || 
                (alumni.linkedIn?.toLowerCase().contains(query) ?? false); 
          }).toList();

          if (filteredAlumni.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: _agedParchment),
                    const SizedBox(height: 20),
                    Text(
                      'No alumni found matching "$_searchQuery".', // Themed message for no results
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: _darkText.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredAlumni.length,
            itemBuilder: (context, index) {
              final alumni = filteredAlumni[index];
      
              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: _goldAccent.withOpacity(0.5), width: 1),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: _lightCardBackground,
                child: InkWell(
                  onTap: () {
                    // Navigate to AlumniDetailScreen
                    Navigator.pushNamed(context, '/alumni_detail', arguments: alumni);
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
                              backgroundImage: (alumni.profileImageUrl != null && alumni.profileImageUrl!.isNotEmpty)
                                  ? NetworkImage(alumni.profileImageUrl!) as ImageProvider<Object>
                                  : null,
                              child: (alumni.profileImageUrl == null || alumni.profileImageUrl!.isEmpty)
                                  ? Icon(Icons.person, size: 30, color: _hogwartsBlue)
                                  : null,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alumni.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _hogwartsBlue,
                                      fontFamily: 'HarryPotterFont',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${alumni.occupation}, ${alumni.company}', // Display occupation and company
                                    style: TextStyle(fontSize: 15, color: _darkText.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (alumni.degreeMajor.isNotEmpty) // Display Degree/Major
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.book, size: 16, color: _goldAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Degree: ${alumni.degreeMajor}',
                                  style: TextStyle(fontSize: 14, color: _darkText.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                        if (alumni.graduationYear != null && alumni.graduationYear != 0) // Display Graduation Year
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: _goldAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Graduated: ${alumni.graduationYear}',
                                  style: TextStyle(fontSize: 14, color: _darkText.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                        if (alumni.location != null && alumni.location!.isNotEmpty) // Display Location
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: _goldAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Location: ${alumni.location}',
                                  style: TextStyle(fontSize: 14, color: _darkText.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                        if (alumni.contribution != null && alumni.contribution!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Contributions: ${alumni.contribution}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: _darkText.withOpacity(0.6)),
                            ),
                          ),
                        if (alumni.linkedIn != null && alumni.linkedIn!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.link, size: 16, color: _goldAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'LinkedIn',
                                  style: TextStyle(fontSize: 14, color: _darkText.withOpacity(0.7), decoration: TextDecoration.underline),
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
      // FAB for adding alumni profiles, visible only to alumni/admin (if you implement add functionality)
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
          bool canAddAlumni = userRole == 'alumni' || userRole == 'admin';
          return canAddAlumni
              ? FloatingActionButton(
                  onPressed: () {
                    // Navigate to add_edit_alumni screen 
                  
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Add Alumni Profile functionality not yet implemented.', style: TextStyle(color: Colors.white))),
                    );
                    // Navigator.pushNamed(context, '/add_edit_alumni');
                  },
                  backgroundColor: _goldAccent,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                  tooltip: 'Add New Alumni Profile',
                )
              : const SizedBox.shrink(); // Hide FAB if not permitted
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}