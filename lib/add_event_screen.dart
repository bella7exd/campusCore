// lib/screens/add_event_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:intl/intl.dart';
import '/models/event.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event; // Optional: for editing existing events

  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isLoading = false;
  String? _currentUserRole; // To store the role of the current user

  // Harry Potter themed colors
  final Color _hogwartsBlue = const Color(0xFF0E1A40); // Dark, rich blue
  final Color _gryffindorRed = const Color(0xFF740001); // Deep red
  final Color _goldAccent = const Color(0xFFD3A625); // Gold
  final Color _parchmentBackground = const Color(0xFFF0EAD6); // Light parchment
  final Color _darkText = const Color(0xFF333333); // Dark readable text
  final Color _lightParchment = const Color(0xFFF5F5DC); // Lighter card background

  @override
  void initState() {
    super.initState();
    _checkUserPermissions(); // Check permissions on init

    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _imageUrlController.text = widget.event!.imageUrl;
      _locationController.text = widget.event!.location;
      _organizerController.text = widget.event!.organizer;
      _contactInfoController.text = widget.event!.contactInfo;
      _selectedDate = widget.event!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.date);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _checkUserPermissions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        // Not logged in, redirect to login
        Navigator.of(context).pushReplacementNamed('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to manage events.')),
        );
      }
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted && userDoc.exists) {
        setState(() {
          _currentUserRole = userDoc['role'];
        });
        if (!(_currentUserRole == 'faculty' || _currentUserRole == 'admin')) {
          if (mounted) {
            // User does not have permission, redirect
            Navigator.of(context).pop(); // Pop this screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You do not have permission to manage events.')),
            );
          }
        }
      } else {
        if (mounted) {
          // User document not found, redirect (shouldn't happen if auth is working)
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not verify your magical role.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Error fetching role, redirect
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking permissions: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _gryffindorRed,
              onPrimary: Colors.white,
              onSurface: _darkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _hogwartsBlue),
            ),
            dialogTheme: DialogThemeData( // Corrected from DialogThemeData
              backgroundColor: _lightParchment,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _gryffindorRed,
              onPrimary: Colors.white,
              onSurface: _darkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _hogwartsBlue),
            ),
            dialogTheme: DialogThemeData( // Corrected from DialogThemeData
              backgroundColor: _lightParchment,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final DateTime eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newEvent = Event(
        id: widget.event?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : 'https://via.placeholder.com/150',
        date: eventDateTime,
        time: DateFormat('h:mm a').format(eventDateTime),
        location: _locationController.text,
        organizer: _organizerController.text,
        contactInfo: _contactInfoController.text,
      );

      try {
        if (widget.event == null) {
          await FirebaseFirestore.instance.collection('events').add(newEvent.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Daily Prophet entry posted successfully!')),
          );
        } else {
          await FirebaseFirestore.instance.collection('events').doc(widget.event!.id).update(newEvent.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Daily Prophet entry updated!')),
          );
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post entry: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator or permission denied message until role is fetched
    if (_currentUserRole == null && FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
        backgroundColor: _parchmentBackground,
        appBar: AppBar(
          title: const Text('Verifying Permissions...', style: TextStyle(color: Colors.white, fontFamily: 'HarryPotterFont')),
          backgroundColor: _hogwartsBlue,
        ),
        body: Center(child: CircularProgressIndicator(color: _goldAccent)),
      );
    }

    // If user is not faculty or admin, show a message
    if (!(_currentUserRole == 'faculty' || _currentUserRole == 'admin')) {
      return Scaffold(
        backgroundColor: _parchmentBackground,
        appBar: AppBar(
          title: const Text('Access Denied', style: TextStyle(color: Colors.white, fontFamily: 'HarryPotterFont')),
          backgroundColor: _gryffindorRed,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: _darkText.withAlpha((255 * 0.4).round())),
                const SizedBox(height: 20),
                Text(
                  'Only Hogwarts Professors and Ministry Officials can manage prophecies.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: _darkText.withAlpha((255 * 0.6).round())),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hogwartsBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If user is authorized, build the form
    return Scaffold(
      backgroundColor: _parchmentBackground,
      appBar: AppBar(
        title: Text(
          widget.event == null ? 'Announce New Prophecy' : 'Edit Prophecy Details',
          style: const TextStyle(color: Colors.white, fontFamily: 'HarryPotterFont'),
        ),
        backgroundColor: _hogwartsBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _goldAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Prophecy Title (e.g., Triwizard Tournament)',
                        labelStyle: TextStyle(color: _darkText),
                        prefixIcon: Icon(Icons.book_online, color: _goldAccent),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                        ),
                      ),
                      style: TextStyle(color: _darkText),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a prophecy title.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Prophecy Details',
                        labelStyle: TextStyle(color: _darkText),
                        prefixIcon: Icon(Icons.description, color: _goldAccent),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                        ),
                      ),
                      style: TextStyle(color: _darkText),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe the prophecy.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Image Scroll URL (Optional)',
                        hintText: 'https://images.fandom.com/magical-creature.jpg',
                        labelStyle: TextStyle(color: _darkText),
                        prefixIcon: Icon(Icons.image, color: _goldAccent),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                        ),
                      ),
                      style: TextStyle(color: _darkText),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Prophecy Date',
                                labelStyle: TextStyle(color: _darkText),
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                                ),
                                prefixIcon: Icon(Icons.event, color: _goldAccent),
                              ),
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(_selectedDate),
                                style: TextStyle(color: _darkText),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Time of Gathering',
                                labelStyle: TextStyle(color: _darkText),
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                                ),
                                prefixIcon: Icon(Icons.access_time, color: _goldAccent),
                              ),
                              child: Text(
                                _selectedTime.format(context),
                                style: TextStyle(color: _darkText),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location (e.g., Great Hall, Forbidden Forest)',
                        labelStyle: TextStyle(color: _darkText),
                        prefixIcon: Icon(Icons.location_on, color: _goldAccent),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                        ),
                      ),
                      style: TextStyle(color: _darkText),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a magical location.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _organizerController,
                      decoration: InputDecoration(
                        labelText: 'Announced by (e.g., Headmaster, Ministry)',
                        labelStyle: TextStyle(color: _darkText),
                        prefixIcon: Icon(Icons.person, color: _goldAccent),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                        ),
                      ),
                      style: TextStyle(color: _darkText),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactInfoController,
                      decoration: InputDecoration(
                        labelText: 'Owl Post Contact Info (Optional)',
                        hintText: 'owl.post@hogwarts.ac.uk',
                        labelStyle: TextStyle(color: _darkText),
                        prefixIcon: Icon(Icons.mail, color: _goldAccent),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                        ),
                      ),
                      style: TextStyle(color: _darkText),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gryffindorRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 5,
                        ),
                        child: Text(
                          widget.event == null ? 'Post Prophecy' : 'Update Prophecy',
                          style: const TextStyle(fontSize: 18, fontFamily: 'HarryPotterFont'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
