import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'goal_model.dart'; 

class GoalTaskManagerScreen extends StatefulWidget {
  const GoalTaskManagerScreen({super.key});

  @override
  _GoalTaskManagerScreenState createState() => _GoalTaskManagerScreenState();
}

class _GoalTaskManagerScreenState extends State<GoalTaskManagerScreen> {
  // Firebase instances for authentication and Firestore database
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser; // Holds the currently authenticated user

  final Color _hogwartsBlue = const Color(0xFF0E1A40); 
  final Color _gryffindorRed = const Color(0xFF740001);
  final Color _goldAccent = const Color(0xFFD3A625); 
  final Color _parchmentBackground = const Color(0xFFF0EAD6); 
  final Color _darkText = const Color(0xFF333333); 
  final Color _lightCardBackground = const Color(0xFFF5F5DC);
  final Color _agedParchment = const Color(0xFFC8AD7F); 

  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // State to hold the current search query

  // State for the selected status filter
  String _selectedStatusFilter = 'all'; // Default to show all goals

  final List<String> _statusOptions = [
    'all',
    'pending',
    'in_progress',
    'completed',
    'overdue'
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Get the current user when the screen initializes
    if (_currentUser == null) {
      // If no user is logged in, navigate them back to the login screen.
      // `addPostFrameCallback` ensures this navigation happens after the widget tree is built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }

    // Add listener to the search controller to update the filter
    _searchController.addListener(_onSearchChanged);
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

  // Delete: Function to delete a goal from Firestore
  // This function now only performs the deletion and shows a snackbar,
  // as the confirmation dialog is handled by the `confirmDismiss` callback.
  Future<void> _performDeleteGoal(String goalId) async {
    if (_currentUser == null) return; // Ensure a user is logged in before attempting to delete

    try {
      // Access the 'goals' sub-collection under the current user's document and delete the specific goal.
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('goals')
          .doc(goalId)
          .delete();
      _showSnackBar('Marauder\'s Map Task banished successfully!', _gryffindorRed); // Show success message
    } catch (e) {
      // Catch and print any errors during deletion
      print('Error banishing task: $e');
      _showSnackBar('Failed to banish task. Please try again.', _gryffindorRed); // Show error message
    }
  }

  // Helper method to show a SnackBar message (e.g., success or error notifications)
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2), // How long the snackbar is visible
        behavior: SnackBarBehavior.floating, // Makes the snackbar float above content
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners for snackbar
        margin: const EdgeInsets.all(10), // Margin around the snackbar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no user is logged in, display a simple message and return early
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Marauder\'s Map Tasks', style: TextStyle(fontFamily: 'HarryPotterFont'))), // Themed title
        body: Center(child: Text('Please log in to manage your magical tasks.', style: TextStyle(color: _darkText))), // Themed message
      );
    }

    return Scaffold(
      backgroundColor: _parchmentBackground, // Themed background
      appBar: AppBar(
        title: Text('Marauder\'s Map Tasks', style: const TextStyle(color: Colors.white, fontFamily: 'HarryPotterFont')), // Themed title
        backgroundColor: _hogwartsBlue, // Themed app bar color
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight * 2), // Increased height for both search and filter
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by task name or spell...', // Themed hint
                    hintStyle: TextStyle(color: Colors.white70),
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
                  cursorColor: _goldAccent,
                ),
                const SizedBox(height: 10), // Spacing between search and filter
                DropdownButtonFormField<String>(
                  value: _selectedStatusFilter,
                  decoration: InputDecoration(
                    hintText: 'Filter by enchantment status', // Themed hint
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.filter_list, color: _goldAccent), // Themed icon
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
                  dropdownColor: _hogwartsBlue.withOpacity(0.9), // Themed dropdown background
                  style: const TextStyle(color: Colors.white),
                  items: _statusOptions.map((String value) {
                    String displayValue;
                    switch (value) {
                      case 'all': displayValue = 'All Tasks'; break;
                      case 'pending': displayValue = 'Awaiting Spell'; break;
                      case 'in_progress': displayValue = 'Casting in Progress'; break;
                      case 'completed': displayValue = 'Spell Cast'; break;
                      case 'overdue': displayValue = 'Overdue Incantation'; break;
                      default: displayValue = value;
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(displayValue, style: const TextStyle(fontFamily: 'HarryPotterFont')), // Themed font
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatusFilter = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('goals')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _goldAccent)); // Themed loading indicator
          }
          if (snapshot.hasError) {
            print('Error fetching goals: ${snapshot.error}');
            return Center(child: Text('Error loading tasks: ${snapshot.error}', style: TextStyle(color: _gryffindorRed))); // Themed error text
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 80, color: _agedParchment), // Themed icon
                    const SizedBox(height: 20),
                    Text(
                      'No Marauder\'s Map tasks yet! Tap the + button to add your first magical mission.', // Themed text
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: _darkText.withOpacity(0.8)), // Themed text
                    ),
                  ],
                ),
              ),
            );
          }

          List<Goal> goals = snapshot.data!.docs.map((doc) => Goal.fromFirestore(doc)).toList();

          final filteredGoals = goals.where((goal) {
            final query = _searchQuery.toLowerCase();
            final matchesSearch = goal.title.toLowerCase().contains(query) ||
                                  goal.description.toLowerCase().contains(query);

            if (goal.status != 'completed' &&
                goal.dueDate != null &&
                goal.dueDate!.isBefore(DateTime.now())) {
              goal.status = 'overdue';
            }

            final matchesFilter = _selectedStatusFilter == 'all' ||
                                  goal.status == _selectedStatusFilter;

            return matchesSearch && matchesFilter;
          }).toList();

          if (filteredGoals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: _agedParchment), // Themed icon
                    const SizedBox(height: 20),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No matching magical tasks found for "$_searchQuery" with status "${_selectedStatusFilter.replaceAll('_', ' ')}".' // Themed text
                          : 'No magical tasks found with status "${_selectedStatusFilter.replaceAll('_', ' ')}".', // Themed text
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: _darkText.withOpacity(0.8)), // Themed text
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredGoals.length,
            itemBuilder: (context, index) {
              Goal goal = filteredGoals[index];

              return Dismissible(
                key: Key(goal.id!),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: _gryffindorRed, // Themed delete background
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 30), // Themed icon
                ),
                confirmDismiss: (direction) async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: _lightCardBackground, // Themed dialog background
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Banish This Task?', style: TextStyle(color: _hogwartsBlue, fontFamily: 'HarryPotterFont')), // Themed title
                        content: Text('Are you sure you want to banish this Marauder\'s Map task forever? This cannot be undone.', style: TextStyle(color: _darkText)), // Themed content
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel', style: TextStyle(color: _hogwartsBlue)), // Themed button
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: _gryffindorRed, foregroundColor: Colors.white), // Themed delete button
                            child: const Text('Banish!', style: TextStyle(fontFamily: 'HarryPotterFont')), // Themed button
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    await _performDeleteGoal(goal.id!);
                    return true;
                  }
                  return false;
                },
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: _goldAccent.withOpacity(0.5), width: 1), // Golden border
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: _lightCardBackground, // Themed card background
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/add_edit_goal',
                        arguments: goal,
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
                              Icon(goal.statusIcon, color: goal.statusColor, size: 28), // Larger, themed icon
                              const SizedBox(width: 15), // More spacing
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _hogwartsBlue, // Themed text color
                                    fontFamily: 'HarryPotterFont', // Custom font
                                    decoration: goal.status == 'completed' ? TextDecoration.lineThrough : null,
                                    decorationColor: _darkText.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // More padding
                                decoration: BoxDecoration(
                                  color: goal.statusColor.withOpacity(0.2), // Light background for the badge
                                  borderRadius: BorderRadius.circular(10), // More rounded
                                ),
                                child: Text(
                                  _getThemedStatusText(goal.status), // Themed status text
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: goal.statusColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10), // More spacing
                          if (goal.description.isNotEmpty)
                            Text(
                              goal.description,
                              style: TextStyle(fontSize: 15, color: _darkText.withOpacity(0.8)), // Themed text
                            ),
                          if (goal.dueDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0), // More padding
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: _goldAccent), // Themed icon
                                  const SizedBox(width: 10), // More spacing
                                  Text(
                                    'Prophecy Due: ${goal.dueDate!.toLocal().toString().split(' ')[0]}', // Themed label
                                    style: TextStyle(fontSize: 15, color: _darkText.withOpacity(0.8)), // Themed text
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_edit_goal');
        },
        backgroundColor: _goldAccent, // Themed FAB color
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // More rounded FAB
        child: const Icon(Icons.add, size: 30), // Larger icon
      ),
    );
  }

  String _getThemedStatusText(String status) {
    switch (status) {
      case 'pending': return 'AWAITING SPELL';
      case 'in_progress': return 'CASTING IN PROGRESS';
      case 'completed': return 'SPELL CAST!';
      case 'overdue': return 'OVERDUE INCANTATION';
      default: return status.replaceAll('_', ' ').toUpperCase();
    }
  }
}