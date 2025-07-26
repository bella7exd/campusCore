// lib/models/alumni_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for DocumentSnapshot and Timestamp

class Alumni {
  String? id; // Firestore document ID
  final String name;
  final int graduationYear;
  final String degreeMajor;
  final String occupation;
  final String company;
  final String? location; // Optional
  final String? contribution; // Optional
  final String? profileImageUrl; // NEW: Field for alumni profile picture URL
  final String? linkedIn; // NEW: Field for LinkedIn URL (or any social link)

  Alumni({
    this.id, // Make ID optional for new alumni before saving to Firestore
    required this.name,
    required this.graduationYear,
    required this.degreeMajor,
    required this.occupation,
    required this.company,
    this.location,
    this.contribution,
    this.profileImageUrl, // Initialize profileImageUrl
    this.linkedIn, // Initialize linkedIn
  });

  // Factory constructor to create an Alumni object from a Firestore DocumentSnapshot
  factory Alumni.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>; // Cast the data to a Map
    return Alumni(
      id: doc.id, // Get the document ID from Firestore
      name: data['name'] ?? 'Unknown Alumni',
      graduationYear: data['graduationYear'] ?? 0, // Default to 0 or handle as needed
      degreeMajor: data['degreeMajor'] ?? 'Undeclared',
      occupation: data['occupation'] ?? 'Unspecified',
      company: data['company'] ?? 'Self-Employed',
      location: data['location'],
      contribution: data['contribution'],
      profileImageUrl: data['profileImageUrl'], // Retrieve from Firestore
      linkedIn: data['linkedIn'], // Retrieve from Firestore
    );
  }

  // Converts an Alumni object into a Map suitable for writing to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'graduationYear': graduationYear,
      'degreeMajor': degreeMajor,
      'occupation': occupation,
      'company': company,
      'location': location,
      'contribution': contribution,
      'profileImageUrl': profileImageUrl, // Save to Firestore
      'linkedIn': linkedIn, // Save to Firestore
      'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
      'updatedAt': FieldValue.serverTimestamp(), // Add update timestamp
    };
  }
}