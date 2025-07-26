// lib/screen/add_edit_goal_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'goal_model.dart'; 
import 'package:intl/intl.dart'; // Required for date formatting 

class AddEditGoalScreen extends StatefulWidget {
  final Goal? goal; // Optional: If a Goal object is passed, it means we are editing an existing goal.

  const AddEditGoalScreen({super.key, this.goal});

  @override
  _AddEditGoalScreenState createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey to validate the form
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 
  final Color _hogwartsBlue = const Color(0xFF0E1A40);
  final Color _gryffindorRed = const Color(0xFF740001);
  final Color _goldAccent = const Color(0xFFD3A625); 
  final Color _parchmentBackground = const Color(0xFFF0EAD6);
  final Color _darkText = const Color(0xFF333333); 
  final Color _lightCardBackground = const Color(0xFFF5F5DC); 

  // Text editing controllers for goal title and description
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDueDate; // Stores the selected due date
  String _selectedStatus = 'pending'; // Stores the selected status, defaults to 'pending'
  bool _isSaving = false; // State to indicate if data is currently being saved
  String? _statusMessage; // Message to display to the user about save status

  @override
  void initState() {
    super.initState();
    // Initialize controllers and state variables with existing goal data if in edit mode.
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');
    _selectedDueDate = widget.goal?.dueDate;
    _selectedStatus = widget.goal?.status ?? 'pending';
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks when the widget is removed from the tree.
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to open a date picker dialog and allow the user to select a due date.
  Future<void> _pickDueDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _hogwartsBlue, // Themed primary color for date picker
              onPrimary: Colors.white,
              onSurface: _darkText, // Themed text color for date picker
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _gryffindorRed), 
            ),
            dialogTheme: DialogTheme( 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: _parchmentBackground, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  // Create/Update: Function to save the goal data to Firestore.
  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showSnackBar('You must be logged in to manage your magical tasks.', Colors.red); // Themed message
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    try {
      Goal goalToSave = Goal(
        userId: currentUser.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
        status: _selectedStatus,
      );

      if (widget.goal == null) {
        // Create operation
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('goals')
            .add(goalToSave.toFirestore());
        _showSnackBar('Marauder\'s Map Task added successfully!', _gryffindorRed); // Themed message
      } else {
        
        goalToSave.id = widget.goal!.id;
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('goals')
            .doc(goalToSave.id)
            .update(goalToSave.toFirestore());
        _showSnackBar('Marauder\'s Map Task updated successfully!', _gryffindorRed); // Themed message
      }
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving goal: $e');
      _showSnackBar('Failed to save Marauder\'s Map Task. Please try again.', Colors.red); // Themed message
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Helper method to show a SnackBar message.
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.goal == null ? 'Add New Marauder\'s Task' : 'Edit Marauder\'s Task', // Themed title
          style: const TextStyle(color: Colors.white, fontFamily: 'HarryPotterFont'), // Apply custom font
        ),
        backgroundColor: _hogwartsBlue, // Themed app bar color
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: _parchmentBackground, // Themed card background
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title (e.g., Brew Polyjuice Potion)', // Themed label
                          labelStyle: TextStyle(color: _darkText),
                          prefixIcon: Icon(Icons.star, color: _goldAccent), // Themed icon (star for importance)
                          border: const OutlineInputBorder(), // Standard border
                          focusedBorder: OutlineInputBorder( // Themed focused border
                            borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                          ),
                        ),
                        style: TextStyle(color: _darkText),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title for your magical event.'; // Themed validation
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Event Details (Optional)', // Themed label
                          labelStyle: TextStyle(color: _darkText),
                          prefixIcon: Icon(Icons.description, color: _goldAccent), // Themed icon
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder( // Themed focused border
                            borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                          ),
                        ),
                        style: TextStyle(color: _darkText),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickDueDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: _selectedDueDate == null
                                  ? 'Prophecy Completion Date (Optional)' // Themed label
                                  : 'Due by: ${DateFormat('MMM d, yyyy').format(_selectedDueDate!)}', // Themed display
                              labelStyle: TextStyle(color: _darkText),
                              prefixIcon: Icon(Icons.calendar_today, color: _goldAccent), // Themed icon
                              suffixIcon: Icon(Icons.arrow_drop_down, color: _darkText),
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder( // Themed focused border
                                borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                              ),
                            ),
                            style: TextStyle(color: _darkText),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Enchantment Status', // Themed label
                          labelStyle: TextStyle(color: _darkText),
                          prefixIcon: Icon(Icons.info_outline, color: _goldAccent), // Themed icon
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder( // Themed focused border
                            borderSide: BorderSide(color: _hogwartsBlue, width: 2),
                          ),
                        ),
                        style: TextStyle(color: _darkText), // Text in dropdown
                        items: <String>['pending', 'in_progress', 'completed', 'overdue'] // Including 'overdue'
                            .map<DropdownMenuItem<String>>((String value) {
                          String displayValue;
                          switch (value) {
                            case 'pending':
                              displayValue = 'Awaiting Spell'; // Themed status
                              break;
                            case 'in_progress':
                              displayValue = 'Casting in Progress'; // Themed status
                              break;
                            case 'completed':
                              displayValue = 'Spell Cast!'; // Themed status
                              break;
                            case 'overdue':
                              displayValue = 'Overdue Incantation'; // Themed status
                              break;
                            default:
                              displayValue = value;
                          }
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(displayValue),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      _isSaving
                          ? Center(child: CircularProgressIndicator(color: _goldAccent)) // Themed progress indicator
                          : ElevatedButton(
                              onPressed: _saveGoal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gryffindorRed, // Themed button color
                                foregroundColor: Colors.white, // Text color
                                minimumSize: const Size(double.infinity, 50), // Full width button
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners
                                elevation: 5, // Shadow
                              ),
                              child: Text(
                                widget.goal == null ? 'Add Magical Task' : 'Update Magical Task', // Themed button text
                                style: const TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'HarryPotterFont'), // Apply custom font
                              ),
                            ),
                      if (_statusMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              color: _statusMessage!.contains('Error') ? Colors.red.shade700 : _gryffindorRed, // Themed status message color
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
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