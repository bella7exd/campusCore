// lib/models/event.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final String time;
  final String location;
  final String organizer;
  final String contactInfo;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.contactInfo,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No Description',
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] ?? 'N/A',
      location: data['location'] ?? 'Online',
      organizer: data['organizer'] ?? 'College Connect',
      contactInfo: data['contactInfo'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      'time': time,
      'location': location,
      'organizer': organizer,
      'contactInfo': contactInfo, // Add this line
    };
  }
}