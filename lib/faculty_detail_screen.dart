// lib/faculty_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/faculty_model.dart'; 

class FacultyDetailScreen extends StatelessWidget {
  final Faculty faculty; 

  const FacultyDetailScreen({super.key, required this.faculty});

 
  final Color _hogwartsBlue = const Color(0xFF0E1A40);
  final Color _gryffindorRed = const Color(0xFF740001);
  final Color _goldAccent = const Color(0xFFD3A625);
  final Color _darkText = const Color(0xFF333333);
  final Color _parchmentBackground = const Color(0xFFF0EAD6);
  final Color _lightCardBackground = const Color(0xFFF5F5DC);
  final Color _agedParchment = const Color(0xFFC8AD7F);

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $urlString';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the ImageProvider based on profileImageUrl
    ImageProvider<Object>? profileImageProvider;
    if (faculty.profileImageUrl != null && faculty.profileImageUrl!.isNotEmpty) {
      profileImageProvider = NetworkImage(faculty.profileImageUrl!);
    }

    return Scaffold(
      backgroundColor: _parchmentBackground,
      appBar: AppBar(
        title: Text(
          faculty.name,
          style: TextStyle(fontFamily: 'HarryPotterFont', color: _goldAccent),
        ),
        backgroundColor: _hogwartsBlue,
        iconTheme: IconThemeData(color: _goldAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image (if available)
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: _gryffindorRed.withOpacity(0.2), // Themed background
                  backgroundImage: profileImageProvider,
                  child: profileImageProvider == null
                      ? Icon(
                          Icons.person,
                          size: 80,
                          color: _gryffindorRed,
                        )
                      : null,
                ),
              ),
            ),

            // Details Cards
            _buildDetailCard(
              title: 'Department',
              value: faculty.department,
              icon: Icons.business,
            ),
            _buildDetailCard(
              title: 'Role', 
              value: faculty.role, 
              icon: Icons.badge,
            ),
            _buildDetailCard(
              title: 'Years at Hogwarts', 
              value: faculty.yearsAtUniversity ?? 'Not specified', 
              icon: Icons.hourglass_empty,
            ),
            if (faculty.bio != null && faculty.bio!.isNotEmpty) 
            
              _buildDetailCard(
                title: 'Bio',
                value: faculty.bio!,
                icon: Icons.info_outline,
              ),
            if (faculty.contactEmail != null && faculty.contactEmail!.isNotEmpty)
              _buildDetailCard(
                title: 'Owl Post Contact', // Themed contact
                value: faculty.contactEmail!,
                icon: Icons.mail,
              ),
            //  LinkedIn link is stored in faculty.linkedIn field in faculty_model.dart
            if (faculty.linkedIn != null && faculty.linkedIn!.isNotEmpty) // Check for 'linkedIn'
              _buildLinkedInCard(faculty.linkedIn!), // Pass 'linkedIn'
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required String title, required String value, required IconData icon}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: _lightCardBackground,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: _agedParchment, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _gryffindorRed, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _hogwartsBlue,
                      fontFamily: 'HarryPotterFont',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: _darkText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedInCard(String url) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: _lightCardBackground,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: _agedParchment, width: 1),
      ),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(Icons.link, color: _gryffindorRed, size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'LinkedIn Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _hogwartsBlue,
                    fontFamily: 'HarryPotterFont',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: _gryffindorRed, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}