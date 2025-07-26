import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

import 'academic.dart';
import 'event_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String _username = 'Loading...';
  User? _currentUser;
  int _selectedIndex = 0;
  String? _profileImageUrl;

  final Color _hogwartsBlue = const Color(0xFF0E1A40); 
  final Color _hogwartsBlueLight = const Color(0xFF2D3C80); 
  final Color _gryffindorRed = const Color(0xFF740001); 
  final Color _goldAccent = const Color(0xFFD3A625); 
  final Color _parchmentBackground = const Color(0xFFF0EAD6); 
  final Color _darkText = const Color(0xFF333333); 
  final Color _lightCardBackground = const Color(0xFFF5F5DC); 
  final Color _agedParchment = const Color(0xFFC8AD7F); 

  late final List<Widget> _widgetOptions;

  // Themed titles for the AppBar that will change based on the selected tab.
  final List<String> _appBarTitles = const [
    'Hogwarts - Great Hall', // Themed
    'Hogwarts Library & Scrolls', // Themed
    'The Daily Prophet', // Themed
  ];

  bool _profileUpdateHandled = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    _fetchUserData();
    _widgetOptions = <Widget>[
      _buildHomeContent(),
      const AcademicScreen(),
      const CampusEventsScreen(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_profileUpdateHandled) {
      _showProfileUpdateSuccess();
    }
  }

  void _showProfileUpdateSuccess() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map && args['profileUpdated'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your wizarding profile has been updated!'), // Themed message
          backgroundColor: _gryffindorRed, // Themed color
          duration: const Duration(seconds: 3),
        ),
      );
      _profileUpdateHandled = true;
    }
  }

  // Build the home content widget
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Welcome Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: _lightCardBackground, // Themed card background
              elevation: 8, // More prominent shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18), // More rounded corners
                side: BorderSide(color: _goldAccent.withOpacity(0.7), width: 1.5), // Golden border
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0), // More padding
                child: Row(
                  children: [
                    Icon(Icons.auto_fix_high, size: 45, color: _goldAccent), // Wand icon
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        'Greetings, $_username!', // Themed greeting
                        style: TextStyle(
                            fontSize: 26, // Larger font
                            fontWeight: FontWeight.bold,
                            color: _hogwartsBlue, // Themed text color
                            fontFamily: 'HarryPotterFont'), // Custom font
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // College Header Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(25), // More padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_hogwartsBlue, _hogwartsBlueLight], // Using the lighter custom color for gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hogwarts School of', // Themed
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'HarryPotterFont',
                    shadows: [
                      Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black38)
                    ]
                  ),
                ),
                const Text(
                  'Witchcraft and Wizardry', // Themed
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'HarryPotterFont',
                    shadows: [
                      Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black38)
                    ]
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Scottish Highlands, Great Britain', // Themed location
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'HarryPotterFont',
                  ),
                ),
              ],
            ),
          ),

          // College Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Hogwarts', // Themed
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _hogwartsBlue, // Themed text color
                    fontFamily: 'HarryPotterFont',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hogwarts School of Witchcraft and Wizardry is a magical academy where young witches and wizards are trained in the magical arts. Founded by Godric Gryffindor, Helga Hufflepuff, Rowena Ravenclaw, and Salazar Slytherin, it is renowned for its comprehensive magical education.', // Themed description
                  style: TextStyle(
                    fontSize: 16,
                    color: _darkText.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Contact Info
                Container(
                  padding: const EdgeInsets.all(20), // More padding
                  decoration: BoxDecoration(
                    color: _lightCardBackground, // Themed background
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _agedParchment, width: 1), // Aged parchment border
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Owl Post Service', // Themed
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _hogwartsBlue, // Themed text color
                          fontFamily: 'HarryPotterFont',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 20, color: _gryffindorRed), // Themed icon
                          const SizedBox(width: 10),
                          Text('📞 Floo Network: +44-XXXXXXXXXXX', style: TextStyle(color: _darkText)), // Themed contact
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.mail, size: 20, color: _gryffindorRed), // Themed icon
                          const SizedBox(width: 10),
                          Text('📧 Owl Post: info@hogwarts.ac.uk', style: TextStyle(color: _darkText)), // Themed contact
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Programs Section
                Text(
                  'Magical Disciplines Offered', // Themed
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _hogwartsBlue, // Themed text color
                    fontFamily: 'HarryPotterFont',
                  ),
                ),
                const SizedBox(height: 12),

                // Program Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20), // More padding
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: _lightCardBackground, // Themed background
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _agedParchment, width: 1), // Themed border
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Standard Curricula', // Themed
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _hogwartsBlue, // Themed text color
                                fontFamily: 'HarryPotterFont',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('• Charms\n• Potions\n• Transfiguration\n• Defence Against the Dark Arts\n• Herbology', // Themed subjects
                                style: TextStyle(color: _darkText.withOpacity(0.9)),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20), // More padding
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: _lightCardBackground, // Themed background
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _agedParchment, width: 1), // Themed border
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Advanced Studies', // Themed
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _hogwartsBlue, // Themed text color
                                fontFamily: 'HarryPotterFont',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('• Ancient Runes\n• Arithmancy\n• Care of Magical Creatures\n• Divination\n• Advanced Potions Theory', // Themed subjects
                                style: TextStyle(color: _darkText.withOpacity(0.9)),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Clubs Section
                Text(
                  'Hogwarts Student Societies', // Themed
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _hogwartsBlue, // Themed text color
                    fontFamily: 'HarryPotterFont',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Discover our vibrant magical societies and join a brotherhood!', // Themed description
                  style: TextStyle(
                    fontSize: 16,
                    color: _darkText.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Clubs Carousel
          const ClubCarousel(),

          const SizedBox(height: 40),

          // Quick Actions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Charms:', // Themed
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _hogwartsBlue, // Themed text color
                    fontFamily: 'HarryPotterFont',
                  ),
                ),
                const SizedBox(height: 16),

                // GridView for feature cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 18, // Increased spacing
                  mainAxisSpacing: 18, // Increased spacing
                  children: [
                    _buildFeatureCard(
                      context,
                      icon: Icons.map, // Marauder's Map icon
                      title: 'Marauder\'s Map Tasks', // Themed
                      onTap: () {
                        Navigator.of(context).pushNamed('/goals');
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.shield_outlined, // Order of the Phoenix shield
                      title: 'Order of the Phoenix Alumni', // Themed
                      onTap: () {
                        Navigator.of(context).pushNamed('/alumni');
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.school, // Hogwarts School icon
                      title: 'Hogwarts Professors', // Themed
                      onTap: () {
                        Navigator.of(context).pushNamed('/faculty');
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.lightbulb_outline, // Sorting Hat/Guidance
                      title: 'Sorting Hat\'s Wisdom', // Themed
                      onTap: () {
                        Navigator.of(context).pushNamed('/guidance');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper method to build a reusable feature card widget for the GridView
  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 8, // More prominent shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // Rounded corners
        side: BorderSide(color: _goldAccent.withOpacity(0.5), width: 1.5), // Golden border
      ),
      color: _lightCardBackground, // Themed card background
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: _goldAccent.withOpacity(0.3), // Gold splash effect
        highlightColor: _goldAccent.withOpacity(0.1), // Gold highlight
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 55, color: _gryffindorRed), // Themed icon color
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _hogwartsBlue, // Themed text color
                    fontFamily: 'HarryPotterFont'), // Custom font
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fetches the username from Firestore based on the current user's UID.
  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _username = data['name'] ?? _currentUser!.email ?? 'Fellow Wizard'; // Themed default
            _profileImageUrl = data['profileImageUrl'];
            _widgetOptions[0] = _buildHomeContent(); // Rebuild home content with updated data
          });
        } else {
          setState(() {
            _username = _currentUser!.email ?? 'New Student'; // Themed default
            _profileImageUrl = null;
            _widgetOptions[0] = _buildHomeContent();
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          _username = _currentUser!.email ?? 'Lost Soul'; // Themed error default
          _profileImageUrl = null;
          _widgetOptions[0] = _buildHomeContent();
        });
      }
    } else {
      setState(() {
        _username = 'Muggle Guest'; // Themed for non-logged-in
        _profileImageUrl = null;
        _widgetOptions[0] = _buildHomeContent();
      });
    }
  }

  // Handles taps on the BottomNavigationBar items.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper method to show a SnackBar message. (This is now largely handled by main.dart theme)
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
          _appBarTitles[_selectedIndex],
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: const [],
      ),
      drawer: Drawer(
        child: Container( // Apply themed background to the drawer
          color: _parchmentBackground,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(
                  _username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HarryPotterFont',
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text(
                  _currentUser?.email ?? 'No Owl Post Address',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: _goldAccent.withOpacity(0.2),
                  backgroundImage: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                      ? NetworkImage(_profileImageUrl!) as ImageProvider<Object>
                      : null,
                  child: (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: _goldAccent,
                        )
                      : null,
                ),
                decoration: BoxDecoration(
                  color: _hogwartsBlue,
                  gradient: LinearGradient(
                    colors: [_hogwartsBlue, _hogwartsBlueLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                ),
              ),
              ListTile(
                leading: Icon(Icons.castle, color: _gryffindorRed),
                title: Text('Great Hall', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(0);
                },
              ),
              ListTile(
                leading: Icon(Icons.portrait, color: _gryffindorRed),
                title: Text('My Wizard Profile', style: TextStyle(color: _darkText)),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.pushNamed(context, '/profile');
                  if (result != null && result is Map && result['profileUpdated'] == true) {
                    await _fetchUserData();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.map, color: _gryffindorRed),
                title: Text('Marauder\'s Map Tasks', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/goals');
                },
              ),
              ListTile( // Corrected from ListListTile
                leading: Icon(Icons.group_work, color: _gryffindorRed),
                title: Text('Order of the Phoenix Alumni', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/alumni');
                },
              ),
              ListTile(
                leading: Icon(Icons.person_pin_circle, color: _gryffindorRed),
                title: Text('Hogwarts Professors', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/faculty');
                },
              ),
              ListTile(
                leading: Icon(Icons.psychology, color: _gryffindorRed),
                title: Text('Sorting Hat\'s Wisdom', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/guidance');
                },
              ),
              const Divider(color: Colors.white38),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: _gryffindorRed),
                title: Text('Disapparate (Logout)', style: TextStyle(color: _darkText)),
                onTap: () async {
                  Navigator.pop(context);
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.castle),
            label: 'Great Hall',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Daily Prophet',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _gryffindorRed,
        unselectedItemColor: _hogwartsBlue.withOpacity(0.7),
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_event');
              },
              backgroundColor: _goldAccent,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// Club Carousel Widget
class ClubCarousel extends StatefulWidget {
  const ClubCarousel({super.key});

  @override
  State<ClubCarousel> createState() => _ClubCarouselState();
}

class _ClubCarouselState extends State<ClubCarousel> {
  final PageController pageController = PageController();
  int currentIndex = 0;

  // Harry Potter themed colors (consistent with main.dart)
  final Color _hogwartsBlue = const Color(0xFF0E1A40);
  final Color _gryffindorRed = const Color(0xFF740001);
  final Color _goldAccent = const Color(0xFFD3A625);
  final Color _darkText = const Color(0xFF333333);
  final Color _agedParchment = const Color(0xFFC8AD7F);

  // Themed Club Data
  final List<Map<String, String>> clubs = [
    {
      'name': 'Gringotts Goblins Club',
      'description': 'Exploring the intricacies of wizarding finance and economics.',
      'activities': '• Galleon Market Analysis\n• Investment Strategies\n• Guest Lectures from Gringotts Officials\n• Ethical Wizarding Commerce',
      'color': '8B4513',
    },
    {
      'name': 'Advanced Charms & Curses Society',
      'description': 'Mastering the most complex spells and understanding counter-magic.',
      'activities': '• Dueling Practice\n• Spell Creation Workshops\n• Defensive Charms Drills\n• Ancient Runes Application',
      'color': '4682B4',
    },
    {
      'name': 'S.P.E.W. (Society for the Promotion of Elfish Welfare)',
      'description': 'Championing the rights and welfare of all magical beings, especially House-Elves.',
      'activities': '• Awareness Campaigns\n• Advocacy for Creature Rights\n• Fundraising for Elf Freedom\n• Discussions on Magical Creature Ethics',
      'color': 'FF69B4',
    },
    {
      'name': 'Quidditch Fan Club',
      'description': 'Celebrating the world\'s most popular wizarding sport and its athletes.',
      'activities': '• Quidditch Game Screenings\n• Team Strategy Sessions\n• Broomstick Maintenance Workshops\n• Fantasy Quidditch Leagues',
      'color': 'B22222',
    },
    {
      'name': 'Hogwarts Legacy Preservation Society',
      'description': 'Dedicated to uncovering and preserving the ancient history and secrets of Hogwarts Castle.',
      'activities': '• Archival Research\n• Exploration of Hidden Passageways\n• Historical Debates\n• Artefact Identification',
      'color': '696969',
    },
    {
      'name': 'Frog Choir & Magical Arts Ensemble',
      'description': 'A harmonious blend of enchanting voices and magical musical performances.',
      'activities': '• Vocal Training\n• Instrument Practice (e.g., Lute, Harp)\n• Public Performances\n• Composition of Magical Melodies',
      'color': '8A2BE2',
    },
  ];

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: FlipCard(
                  club: clubs[index],
                  primaryColor: _getColorFromHex(clubs[index]['color']!),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            clubs.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: currentIndex == index ? 24 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? _goldAccent
                    : _agedParchment.withOpacity(0.7),
                borderRadius: BorderRadius.circular(5),
                boxShadow: currentIndex == index ? [
                  BoxShadow(
                    color: _goldAccent.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ] : [],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: currentIndex > 0 ? () {
                pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              } : null,
              icon: Icon(
                Icons.arrow_back_ios,
                size: 28,
                color: currentIndex > 0 ? _hogwartsBlue : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 25),
            Text(
              '${currentIndex + 1} of ${clubs.length} enchanted societies',
              style: TextStyle(
                color: _darkText.withOpacity(0.8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 25),
            IconButton(
              onPressed: currentIndex < clubs.length - 1 ? () {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              } : null,
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 28,
                color: currentIndex < clubs.length - 1 ? _hogwartsBlue : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Flip Card Widget
class FlipCard extends StatefulWidget {
  final Map<String, String> club;
  final Color primaryColor;

  const FlipCard({
    super.key,
    required this.club,
    required this.primaryColor,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  bool isFlipped = false;

  // Harry Potter themed colors (consistent with main.dart)
  final Color _hogwartsBlue = const Color(0xFF0E1A40);
  final Color _darkText = const Color(0xFF333333);
  final Color _lightCardBackground = const Color(0xFFF5F5DC);
  final Color _agedParchment = const Color(0xFFC8AD7F);

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOutBack,
    ));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void flipCard() {
    if (!isFlipped) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flipCard,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final isShowingFront = animation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(animation.value * 3.14159),
            child: Container(
              width: double.infinity,
              height: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: isShowingFront
                    ? _buildFrontCard()
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: _buildBackCard(),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.primaryColor,
            widget.primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 50,
                    spreadRadius: 20,
                  )
                ]
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // Club Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getClubIcon(widget.club['name']!),
                    size: 38,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),

                // Club Name
                Text(
                  widget.club['name']!,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'HarryPotterFont',
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Description
                Expanded(
                  child: Text(
                    widget.club['description']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),

                const SizedBox(height: 10),

                // Tap hint
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Tap to unravel secrets',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _lightCardBackground,
        border: Border.all(color: _agedParchment, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getClubIcon(widget.club['name']!),
                    size: 28,
                    color: widget.primaryColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    widget.club['name']!,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _hogwartsBlue,
                      fontFamily: 'HarryPotterFont',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Activities Header
            Text(
              'Enchanted Activities:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _darkText.withOpacity(0.9),
                fontFamily: 'HarryPotterFont',
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.club['activities']!,
                  style: TextStyle(
                    fontSize: 15,
                    color: _darkText,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Themed icons for clubs
  IconData _getClubIcon(String clubName) {
    switch (clubName) {
      case 'Economics Club':
        return Icons.currency_bitcoin;
      case 'Tekqbe Club':
        return Icons.auto_fix_high;
      case 'Gender Championship Club':
        return Icons.people_alt;
      case 'Sports Club':
        return Icons.sports_baseball;
      case 'Patriotic Club':
        return Icons.castle;
      case 'Cultural Club':
        return Icons.music_note;
      default:
        return Icons.group;
    }
  }
}