//lib/goal_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; 

class Goal {
  String? id; // The document ID from Firestore. Optional, as it's assigned after creation.
  final String userId; // The ID of the user who owns this goal.
  String title; // The title of the goal/task.
  String description; // A detailed description of the goal/task.
  DateTime? dueDate; // Optional due date for the goal.
  String status; // The current status of the goal (e.g., 'pending', 'in_progress', 'completed', 'overdue').

  // Constructor for the Goal class.
  Goal({
    this.id,
    required this.userId,
    required this.title,
    this.description = '', // Default empty description
    this.dueDate,
    this.status = 'pending', // Default status is 'pending'
  });

  // Factory constructor to create a Goal object from a Firestore DocumentSnapshot.
  // This is used when reading data from Firestore.
  factory Goal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>; // Cast the data to a Map
    return Goal(
      id: doc.id, // Assign the Firestore document ID to the Goal object's id property
      userId: data['userId'] ?? '', // Get userId, default to empty string if null
      title: data['title'] ?? 'No Task Title', // Get title, default if null. Themed.
      description: data['description'] ?? '', // Get description, default if null
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(), // Convert Firestore Timestamp to Dart DateTime
      status: data['status'] ?? 'pending', // Get status, default if null
    );
  }

  // Converts a Goal object into a Map suitable for writing to Firestore.
  // This is used when creating or updating data in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null, // Convert Dart DateTime to Firestore Timestamp
      'status': status,
      'createdAt': FieldValue.serverTimestamp(), // Automatically sets creation time using Firestore server timestamp
      'updatedAt': FieldValue.serverTimestamp(), // Automatically updates this field on every save
    };
  }

  static const Color _hogwartsBlue = Color(0xFF0E1A40); 
  static const Color _gryffindorRed = Color(0xFF740001); 
  static const Color _goldAccent = Color(0xFFD3A625); 
  static const Color _slytherinGreen = Color(0xFF1A472A); 
  static const Color _hufflepuffYellow = Color(0xFFECB30C); 

  // Getter to return a Color based on the goal's status for visual indication.
  Color get statusColor {
    switch (status) {
      case 'completed':
        return _slytherinGreen; // Deep green for spells cast successfully
      case 'in_progress':
        return _hogwartsBlue; // Hogwarts blue for tasks actively being worked on
      case 'overdue':
        return _gryffindorRed; // Gryffindor red for urgent or failed tasks
      case 'pending':
      default:
        return _hufflepuffYellow; // Hufflepuff yellow for tasks awaiting attention
    }
  }

  // Getter to return an IconData based on the goal's status for visual indication.
  IconData get statusIcon {
    switch (status) {
      case 'completed':
        return Icons.star; // A shining star for completed tasks
      case 'in_progress':
        return Icons.hourglass_empty; // Hourglass for tasks in progress
      case 'overdue':
        return Icons.warning_amber; // Warning icon for overdue tasks
      case 'pending':
      default:
        return Icons.assignment; // A scroll/assignment icon for pending tasks
    }
  }
}