import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'models/event.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  // Harry Potter themed colors
  final Color _hogwartsBlue = const Color(0xFF0E1A40); // Dark, rich blue
  final Color _gryffindorRed = const Color(0xFF740001); // Deep red
  final Color _goldAccent = const Color(0xFFD3A625); // Gold
  final Color _parchmentBackground = const Color(0xFFF0EAD6); // Light parchment for background
  final Color _darkText = const Color(0xFF333333); // Dark readable text
  final Color _agedParchment = const Color(0xFFC8AD7F); // Slightly darker parchment for placeholders
  final Color _lightCardBackground = const Color(0xFFF5F5DC); // Lighter card background for readability

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserRole; // To store the role of the current user

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserRole();
  }

  Future<void> _fetchCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _currentUserRole = null;
      });
      return;
    }
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (mounted && userDoc.exists) {
        setState(() {
          _currentUserRole = userDoc['role'];
        });
      }
    } catch (e) {
      // print('Error fetching user role for event details: $e'); // Avoid print in production
      setState(() {
        _currentUserRole = null;
      });
    }
  }

  // Helper to check if the current user has permission to manage events
  bool _canManageEvents() {
    return _currentUserRole == 'faculty' || _currentUserRole == 'admin';
  }

  // Method to show confirmation dialog and delete event
  Future<void> _confirmAndDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: _lightCardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Banish This Prophecy?', style: TextStyle(color: _hogwartsBlue, fontFamily: 'HarryPotterFont')),
          content: Text('Are you sure you want to banish "${widget.event.title}" forever? This cannot be undone.', style: TextStyle(color: _darkText)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancel', style: TextStyle(color: _hogwartsBlue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: _gryffindorRed),
              child: const Text('Banish!'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _firestore.collection('events').doc(widget.event.id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Prophecy "${widget.event.title}" vanished successfully!', style: TextStyle(color: Colors.white))),
          );
          Navigator.of(context).pop(); // Pop back to the events list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to banish prophecy: $e', style: TextStyle(color: Colors.white))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _parchmentBackground,
      appBar: AppBar(
        title: Text(
          widget.event.title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'HarryPotterFont',
          ),
        ),
        backgroundColor: _hogwartsBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_canManageEvents()) // Conditionally show buttons
            IconButton(
              icon: const Icon(Icons.auto_delete_outlined),
              onPressed: () => _confirmAndDelete(context),
              tooltip: 'Banish Prophecy',
            ),
          if (_canManageEvents()) // Conditionally show buttons
            IconButton(
              icon: const Icon(Icons.auto_fix_high),
              onPressed: () {
                Navigator.pushNamed(context, '/add_event', arguments: widget.event);
              },
              tooltip: 'Edit Prophecy',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.event.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.event.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 400,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 10, // Adjusted height as it was very small (10)
                      color: _agedParchment,
                      child: Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: _darkText.withAlpha((255 * 0.7).round())),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.event.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _hogwartsBlue,
                fontFamily: 'HarryPotterFont',
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.calendar_month, 'Prophecy Date: ${DateFormat('EEEE, MMM d, yyyy').format(widget.event.date)}'),
            _buildInfoRow(Icons.access_time, 'Time of Gathering: ${widget.event.time}'),
            _buildInfoRow(Icons.location_on, 'Location in Hogwarts: ${widget.event.location}'),
            _buildInfoRow(Icons.person, 'Announced by: ${widget.event.organizer}'),
            _buildInfoRow(Icons.mail_outline, 'Owl Post Contact: ${widget.event.contactInfo}'),
            const SizedBox(height: 20),
            Text(
              'Enchantment Details:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _hogwartsBlue,
                fontFamily: 'HarryPotterFont',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.event.description,
              style: TextStyle(fontSize: 16, color: _darkText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: _goldAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: _darkText),
            ),
          ),
        ],
      ),
    );
  }
}
