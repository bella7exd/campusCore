// lib/models/academic_resources.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicResource {
  final String id;
  final String title;
  final String? content; // For announcements
  final String? fileUrl; // For syllabus, notes, timetable files
  final String? description;
  final String? category; // e.g., 'Syllabus', 'Notes', 'Timetable', 'Announcement'
  final String? course; // e.g., 'BCA', 'BBA', 'BA(Eco)'
  final String? semester; // e.g., '1st Semester', '2nd Semester'
  final DateTime publishedDate;
  final String? publishedBy; // For announcements

  AcademicResource({
    required this.id,
    required this.title,
    this.content,
    this.fileUrl,
    this.description,
    this.category,
    this.course,
    this.semester,
    required this.publishedDate,
    this.publishedBy,
  });

  factory AcademicResource.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AcademicResource(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      content: data['content'],
      fileUrl: data['fileUrl'],
      description: data['description'],
      category: data['category'],
      course: data['course'],
      semester: data['semester'],
      publishedDate: (data['date'] as Timestamp? ?? data['publishedDate'] as Timestamp? ?? Timestamp.now()).toDate(),
      publishedBy: data['publishedBy'],
    );
  }
}