import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart'; // Assuming you have this package
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'models/event.dart';
import 'package:intl/intl.dart';

class CampusEventsScreen extends StatefulWidget {
  const CampusEventsScreen({super.key});

  @override
  State<CampusEventsScreen> createState() => _CampusEventsScreenState();
}

class _CampusEventsScreenState extends State<CampusEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDateFilter;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserRole; // To store the role of the current user

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchCurrentUserRole(); // Fetch the role when the screen initializes
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

  Future<void> _fetchCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _currentUserRole = null; // No logged-in user
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
      // print('Error fetching user role for events: $e'); // Avoid print in production
      setState(() {
        _currentUserRole = null; // Fallback if error
      });
    }
  }

  Future<void> _pickDateFilter(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateFilter) {
      setState(() {
        _selectedDateFilter = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateFilter = null;
    });
  }

  // Helper to check if the current user has permission to add/edit events
  bool _canManageEvents() {
    return _currentUserRole == 'faculty' || _currentUserRole == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campus Events',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0E1A40),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight * 2.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by event name...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFD3A625)),
                    filled: true,
                    fillColor: const Color(0xFF0E1A40),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDateFilter(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(
                              text: _selectedDateFilter == null
                                  ? ''
                                  : DateFormat('MMM d, yyyy').format(_selectedDateFilter!),
                            ),
                            decoration: InputDecoration(
                              labelText: _selectedDateFilter == null
                                  ? 'Filter by Date (Optional)'
                                  : 'Date: ${DateFormat('MMM d, yyyy').format(_selectedDateFilter!)}',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFD3A625)),
                              filled: true,
                              fillColor: const Color(0xFF0E1A40),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white, width: 1.5),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_selectedDateFilter != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: _clearDateFilter,
                        tooltip: 'Clear Date Filter',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('events').orderBy('date', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No upcoming events yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final events = snapshot.data!.docs.map((doc) => Event.fromFirestore(doc)).toList();

          final filteredEvents = events.where((event) {
            final query = _searchQuery.toLowerCase();
            final matchesSearch = event.title.toLowerCase().contains(query);

            final matchesDate = _selectedDateFilter == null ||
                                (event.date.year == _selectedDateFilter!.year &&
                                 event.date.month == _selectedDateFilter!.month &&
                                 event.date.day == _selectedDateFilter!.day);

            return matchesSearch && matchesDate;
          }).toList();

          if (filteredEvents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 20),
                    Text(
                      _searchQuery.isNotEmpty || _selectedDateFilter != null
                          ? 'No matching events found for your current filters.'
                          : 'No upcoming events yet!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: _buildEventCardFront(event),
                  back: _buildEventCardBack(context, event),
                ),
              );
            },
          );
        },
      ),
      // Conditionally show FloatingActionButton based on user role
      floatingActionButton: _canManageEvents()
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_event');
              },
              backgroundColor: const Color(0xFFD3A625), // Gold Accent
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null, // Hide FAB if user cannot manage events
    );
  }

  Widget _buildEventCardFront(Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            event.imageUrl,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy - h:mm a').format(event.date),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCardBack(BuildContext context, Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF0E1A40), // Dark blue background for back card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text on dark blue background
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Date: ${DateFormat('MMM d, yyyy').format(event.date)}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 5),
            Text(
              'Time: ${event.time}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 5),
            Text(
              'Location: ${event.location}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/event_detail',
                    arguments: event,
                  );
                },
                icon: const Icon(Icons.info_outline, color: Colors.white),
                label: const Text('View Details', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD3A625), // Gold Accent button
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
