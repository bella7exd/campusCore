// lib/models/faculty_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; 

class Faculty {
  String? id; // Document ID from Firestore
  String name;
  String department;
  String role;
  String? yearsAtUniversity;
  String? bio; // Optional bio for faculty
  String? contactEmail; // Optional contact email
  String? profileImageUrl; // Optional profile image URL
  String? userId; // Link to the Firebase User ID who created/owns this profile
  String? linkedIn; // NEW: Optional LinkedIn profile URL

  Faculty({
    this.id,
    required this.name,
    required this.department,
    required this.role,
    this.yearsAtUniversity,
    this.bio,
    this.contactEmail,
    this.profileImageUrl,
    this.userId, // Initialize userId
    this.linkedIn, // NEW: Initialize linkedIn
  });

  // Factory constructor to create a Faculty object from a Firestore DocumentSnapshot.
  factory Faculty.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Faculty(
      id: doc.id,
      name: data['name'] ?? 'Unknown Professor',
      department: data['department'] ?? 'Unknown Department',
      role: data['role'] ?? 'Lecturer',
      yearsAtUniversity: data['yearsAtUniversity'],
      bio: data['bio'],
      contactEmail: data['contactEmail'],
      profileImageUrl: data['profileImageUrl'],
      userId: data['userId'], // Retrieve userId
      linkedIn: data['linkedIn'], // NEW: Retrieve linkedIn from Firestore
    );
  }

  // Converts a Faculty object into a Map suitable for writing to Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'department': department,
      'role': role,
      'yearsAtUniversity': yearsAtUniversity,
      'bio': bio,
      'contactEmail': contactEmail,
      'profileImageUrl': profileImageUrl,
      'userId': userId, // Save userId
      'linkedIn': linkedIn, // NEW: Save linkedIn to Firestore
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(), 
    };
  }
}