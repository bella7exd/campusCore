// lib/screens/academic_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'models/academic_resources.dart';

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  String? _selectedCategory;
  String? _selectedCourse;
  String? _selectedSemester;

  // Themed course names
  final List<String> _courses = ['Charms', 'Potions', 'Transfiguration', 'Herbology', 'Defence Against Dark Arts', 'Ancient Runes'];
  // Themed semester names
  final List<String> _semesters = [
    'First Year', 'Second Year', 'Third Year', 'Fourth Year',
    'Fifth Year', 'Sixth Year', 'Seventh Year', 'N.E.W.T. Level'
  ];

  // Harry Potter themed colors
  final Color _hogwartsBlue = const Color(0xFF0E1A40); // Dark, rich blue
  final Color _gryffindorRed = const Color(0xFF740001); // Deep red
  final Color _goldAccent = const Color(0xFFD3A625); // Gold
  final Color _parchmentBackground = const Color(0xFFF0EAD6); // Light parchment
  final Color _darkText = const Color(0xFF333333); // Dark readable text
  final Color _agedParchment = const Color(0xFFC8AD7F); // Slightly darker parchment

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not conjure the link to $url')), // Themed text
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open magical link: $e')), // Themed text
        );
      }
    }
  }

  void _resetSelection() {
    setState(() {
      _selectedCategory = null;
      _selectedCourse = null;
      _selectedSemester = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _parchmentBackground, // Themed background
      appBar: AppBar(
        title: Text(
          _selectedCategory == null
              ? 'Hogwarts Library & Scrolls' // Themed title
              : _selectedCategory!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'HarryPotterFont', // Apply custom font
          ),
        ),
        backgroundColor: _hogwartsBlue, // Themed app bar color
        elevation: 4.0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: _selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _resetSelection,
              )
            : null,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_selectedCategory == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Magical Categories', // Themed text
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _darkText, // Themed text color
                fontFamily: 'HarryPotterFont', // Apply custom font
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.2,
                children: [
                  _buildAcademicCategoryTile(
                    context,
                    title: 'Announcement', // Themed title
                    icon: Icons.newspaper, // Themed icon
                    color: _agedParchment, // Themed color
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Daily Prophet';
                      });
                    },
                  ),
                  _buildAcademicCategoryTile(
                    context,
                    title: 'Curriculum Scrolls', // Themed title
                    icon: Icons.menu_book, // Themed icon
                    color: _hogwartsBlue, // Themed color
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Curriculum Scrolls';
                      });
                    },
                  ),
                  _buildAcademicCategoryTile(
                    context,
                    title: 'Spell Notes', // Themed title
                    icon: Icons.auto_fix_high, // Themed icon (wand)
                    color: _gryffindorRed, // Themed color
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Spell Notes';
                      });
                    },
                  ),
                  _buildAcademicCategoryTile(
                    context,
                    title: 'Class Timetable', // Themed title
                    icon: Icons.access_time_filled, // Themed icon
                    color: _goldAccent, // Themed color
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Class Timetable';
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (_selectedCategory == 'Daily Prophet') { // Themed category name
      return _buildAnnouncementsList();
    } else {
      return _buildCourseSemesterAndDownloadableList();
    }
  }

  Widget _buildAcademicCategoryTile(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 48),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'HarryPotterFont', // Apply custom font
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseSemesterAndDownloadableList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white, 
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Magical Discipline:', // Themed text
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _hogwartsBlue, // Themed text color
                  fontFamily: 'HarryPotterFont', // Apply custom font
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _hogwartsBlue), // Themed border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _hogwartsBlue.withOpacity(0.5)), // Themed border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _hogwartsBlue, width: 2), // Themed border color
                  ),
                  labelText: 'Discipline', // Themed label
                  labelStyle: TextStyle(color: _darkText), // Themed label style
                  prefixIcon: Icon(Icons.school, color: _goldAccent), // Themed icon
                  filled: true,
                  fillColor: _parchmentBackground.withOpacity(0.5), // Themed fill color
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: Text(
                  'Choose your magical discipline', // Themed hint
                  style: TextStyle(color: _darkText.withOpacity(0.7)),
                ),
                items: _courses.map((String course) {
                  return DropdownMenuItem<String>(
                    value: course,
                    child: Text(course, style: TextStyle(color: _darkText)), // Themed text style
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCourse = newValue;
                    _selectedSemester = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Select Hogwarts Year:', // Themed text
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _hogwartsBlue, // Themed text color
                  fontFamily: 'HarryPotterFont', // Apply custom font
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _hogwartsBlue), // Themed border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _hogwartsBlue.withOpacity(0.5)), // Themed border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _hogwartsBlue, width: 2), // Themed border color
                  ),
                  labelText: 'Hogwarts Year', // Themed label
                  labelStyle: TextStyle(color: _darkText), // Themed label style
                  prefixIcon: Icon(Icons.calendar_today, color: _goldAccent), // Themed icon
                  filled: true,
                  fillColor: _parchmentBackground.withOpacity(0.5), // Themed fill color
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: Text(
                  'Choose your Hogwarts year', // Themed hint
                  style: TextStyle(color: _darkText.withOpacity(0.7)),
                ),
                items: _semesters.map((String semester) {
                  return DropdownMenuItem<String>(
                    value: semester,
                    child: Text(semester, style: TextStyle(color: _darkText)), // Themed text style
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSemester = newValue;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: (_selectedCourse != null && _selectedSemester != null)
              ? _buildDownloadableList(
                  _selectedCategory!,
                  _selectedCourse!,
                  _selectedSemester!,
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books, size: 60, color: _agedParchment), // Themed icon
                        const SizedBox(height: 20),
                        Text(
                          'Please select a magical discipline and Hogwarts year to view $_selectedCategory scrolls.', // Themed text
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: _darkText.withOpacity(0.8)), // Themed text color
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  /// Builds the list of downloadable academic resources (Curriculum Scrolls, Spell Notes, Class Timetable)
  /// filtered by category, course, and semester.
  Widget _buildDownloadableList(String category, String course, String semester) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('academic_resources')
          .where('category', isEqualTo: category)
          .where('course', isEqualTo: course)
          .where('semester', isEqualTo: semester)
          .orderBy('publishedDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _goldAccent)); // Themed progress indicator
        }
        if (snapshot.hasError) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: _gryffindorRed), // Themed error icon
                const SizedBox(height: 20),
                Text(
                  'Error loading magical resources: ${snapshot.error}', // Themed text
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: _gryffindorRed), // Themed text color
                ),
                const SizedBox(height: 10),
                Text(
                  'Please ensure your Owl Post connection is stable and Gringotts Vault rules/indexes are correctly set up.', // Themed text
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _darkText), // Themed text color
                ),
              ],
            ),
          ));
        }

        List<AcademicResource> resources = [];
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          resources = _generateDummyAcademicResources(category, course, semester);
          if (resources.isEmpty) {
             return Center(
               child: Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.search_off, size: 80, color: _agedParchment), // Themed icon
                     const SizedBox(height: 20),
                     Text(
                       'No $category available for $course ($semester) yet! Keep an eye on the notice board.', // Themed text
                       textAlign: TextAlign.center,
                       style: TextStyle(fontSize: 18, color: _darkText.withOpacity(0.8)), // Themed text color
                     ),
                   ],
                 ),
               ),
             );
           }
        } else {
          resources = snapshot.data!.docs.map((doc) => AcademicResource.fromFirestore(doc)).toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.white, // Keep cards white for content readability
              child: ListTile(
                leading: Icon(
                  _getThemedResourceIcon(category), // Dynamic themed icon
                  color: _hogwartsBlue, // Themed icon color
                  size: 30,
                ),
                title: Text(
                  resource.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'HarryPotterFont'), // Apply custom font
                ),
                subtitle: resource.description != null && resource.description!.isNotEmpty
                    ? Text(
                        resource.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _darkText.withOpacity(0.7)), // Themed text color
                      )
                    : null,
                trailing: (resource.fileUrl != null && resource.fileUrl!.isNotEmpty)
                    ? IconButton(
                        icon: Icon(Icons.download, color: _gryffindorRed), // Themed download icon
                        onPressed: () => _launchURL(resource.fileUrl!),
                      )
                    : null,
                onTap: (resource.fileUrl != null && resource.fileUrl!.isNotEmpty)
                    ? () => _launchURL(resource.fileUrl!)
                    : null,
              ),
            );
          },
        );
      }, 
    );
  }

  IconData _getThemedResourceIcon(String category) {
    switch (category) {
      case 'Curriculum Scrolls':
        return Icons.history_edu; // A scroll icon
      case 'Spell Notes':
        return Icons.auto_fix_high; // Wand icon
      case 'Class Timetable':
        return Icons.calendar_month; // Calendar icon
      default:
        return Icons.book; // Default book icon
    }
  }

  List<AcademicResource> _generateDummyAcademicResources(String category, String course, String semester) {
    List<AcademicResource> dummyResources = [];
    final now = DateTime.now();

    if (category == 'Curriculum Scrolls') { // Themed category name
      dummyResources.add(
        AcademicResource(
          id: 'dummy_syllabus_common_${course.replaceAll(' ', '_')}',
          category: category,
          course: course,
          semester: semester,
          title: '$course Curriculum for $semester', // Themed title
          description: 'Access the official parchment detailing the $course curriculum for your year.', // Themed description
          fileUrl: 'https://drive.google.com/file/d/1LkAzK3Tknke2U7DYZLoysU6am0tBG9rh/view?usp=sharing', // Placeholder PDF/Doc
          publishedDate: now.subtract(const Duration(days: 30)),
          publishedBy: 'Headmaster\'s Office', // Themed publisher
        ),
      );
    } else if (category == 'Spell Notes') { // Themed category name
      dummyResources.add(
        AcademicResource(
          id: 'dummy_notes_1_${course.replaceAll(' ', '_')}_${semester.replaceAll(' ', '_')}',
          category: category,
          course: course,
          semester: semester,
          title: 'Advanced $course Incantations - Unit 1', // Themed title
          description: 'Forbidden Forest field guide to advanced spellcasting concepts.', // Themed description
          fileUrl: 'https://www.geeksforgeeks.org/', // Placeholder link
          publishedDate: now.subtract(const Duration(days: 10)),
          publishedBy: 'Professor Flitwick', // Themed publisher
        ),
      );
      dummyResources.add(
        AcademicResource(
          id: 'dummy_notes_2_${course.replaceAll(' ', '_')}_${semester.replaceAll(' ', '_')}',
          category: category,
          course: course,
          semester: semester,
          title: 'Potions Master\'s Brewing Guide - Practical', // Themed title
          description: 'Additional resources for perfecting your potions.', // Themed description
          fileUrl: 'https://www.africau.edu/images/default/sample.pdf', // Placeholder PDF
          publishedDate: now.subtract(const Duration(days: 5)),
          publishedBy: 'Professor Snape', // Themed publisher
        ),
      );
    } else if (category == 'Class Timetable') { // Themed category name
      dummyResources.add(
        AcademicResource(
          id: 'dummy_timetable_1_${course.replaceAll(' ', '_')}_${semester.replaceAll(' ', '_')}',
          category: category,
          course: course,
          semester: semester,
          title: '$course $semester - Daily Class Schedule', // Themed title
          description: 'View the current enchanted class schedule (image).', // Themed description
          fileUrl: 'https://res.cloudinary.com/dfyzh6edo/image/upload/v1752918270/Screenshot_2025-07-19_151404_zkzzst.png',
          publishedDate: now.subtract(const Duration(days: 30)),
          publishedBy: 'Professor McGonagall', // Themed publisher
        ),
      );
      dummyResources.add(
        AcademicResource(
          id: 'dummy_timetable_2_${course.replaceAll(' ', '_')}_${semester.replaceAll(' ', '_')}',
          category: category,
          course: course,
          semester: semester,
          title: 'O.W.L. & N.E.W.T. Exam Schedule $semester', // Themed title
          description: 'Tentative examination dates and times (sample PDF).', // Themed description
          fileUrl: 'https://collection.cloudinary.com/dfyzh6edo/ce2f7f69ba3e7217860db6e913880611',
          publishedDate: now.subtract(const Duration(days: 15)),
          publishedBy: 'Magical Examinations Board', // Themed publisher
        ),
      );
    }

    return dummyResources;
  }

  Widget _buildAnnouncementsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading Daily Prophet entries: ${snapshot.error}')); // Themed text
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.newspaper, size: 80, color: _agedParchment), // Themed icon
                  const SizedBox(height: 20),
                  Text(
                    'No new Daily Prophet entries yet! Check back for breaking news.', // Themed text
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: _darkText.withOpacity(0.8)), // Themed text color
                  ),
                ],
              ),
            ),
          );
        }

        final announcements = snapshot.data!.docs.map((doc) => AcademicResource.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.white, // Keep cards white
              child: ListTile(
                leading: Icon(Icons.article, color: _gryffindorRed), // Themed icon
                title: Text(
                  announcement.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'HarryPotterFont'), // Apply custom font
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.content ?? 'No content available.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _darkText.withOpacity(0.7)), // Themed text color
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM d,yyyy').format(announcement.publishedDate)} by ${announcement.publishedBy ?? 'The Ministry'}', // Themed text
                      style: TextStyle(fontSize: 12, color: _darkText.withOpacity(0.5)), // Themed text color
                    ),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _parchmentBackground, // Themed dialog background
                      title: Text(announcement.title, style: TextStyle(color: _hogwartsBlue, fontFamily: 'HarryPotterFont')), // Themed title
                      content: SingleChildScrollView(
                        child: Text(announcement.content ?? 'No content available.', style: TextStyle(color: _darkText)), // Themed content
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Close Scroll', style: TextStyle(color: _gryffindorRed)), // Themed button
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}