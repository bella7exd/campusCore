import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentRoadmapScreen extends StatefulWidget {
  const StudentRoadmapScreen({super.key});

  @override
  _StudentRoadmapScreenState createState() => _StudentRoadmapScreenState();
}

class _StudentRoadmapScreenState extends State<StudentRoadmapScreen> {
  int selectedIndex = 0;


  final Color _hogwartsBlue = const Color(0xFF0E1A40); 
  final Color _gryffindorRed = const Color(0xFF740001); 
  final Color _goldAccent = const Color(0xFFD3A625); 
  final Color _parchmentBackground = const Color(0xFFF0EAD6); 
  final Color _darkText = const Color(0xFF333333); 
  final Color _lightCardBackground = const Color(0xFFF5F5DC); 
  final Color _agedParchment = const Color(0xFFC8AD7F); 

  // Roadmap data with timeline format
  final List<Map<String, dynamic>> roadmaps = [
    {
      'title': 'AUROR TRAINING PATH',
      'color': const Color(0xFF740001), 
      'goal': 'Master advanced defensive magic and join the Ministry of Magic as an Auror.',
      'timeline': [
        {
          'year': 'Year 1-3 (Hogwarts)',
          'subtitle': 'Foundation in Dark Arts Defence & Charms',
          'points': [
            'Excel in Defence Against the Dark Arts, Charms, Transfiguration',
            'Develop dueling prowess and strategic thinking',
            'Join Dumbledore\'s Army or similar defensive groups',
            'Study historical battles and Dark Wizards',
            'Cultivate bravery and quick reflexes'
          ]
        },
        {
          'year': 'Year 4-5 (Hogwarts)',
          'subtitle': 'Advanced Magical Combat & Investigation',
          'points': [
            'Intensive study of advanced spells and counter-curses',
            'Learn stealth, tracking, and forensic magic',
            'Seek mentorship from current Aurors (e.g., Alastor Moody)',
            'Undertake advanced practical magical challenges',
            'Refine non-verbal and wandless casting'
          ]
        },
        {
          'year': 'Post-Hogwarts (2-3 Years)',
          'subtitle': 'Auror Academy & Specialization',
          'points': [
            'Pass the rigorous Auror Academy entrance exams (e.g., NEWTs in DADA, Charms, Potions)',
            'Complete specialized training in covert operations, interrogation, and protection',
            'Master advanced Potions for truth serums and antidotes',
            'Participate in mock Dark Wizard hunts and investigations',
            'Build a network within the Ministry\'s Department of Magical Law Enforcement'
          ]
        }
      ]
    },
    {
      'title': 'MAGIZOOLOGIST PATH',
      'color': const Color(0xFF2E8B57), // Forest Green (nature/creatures)
      'goal': 'Explore, study, and protect magical creatures globally, contributing to magical conservation.',
      'timeline': [
        {
          'year': 'Year 1-3 (Hogwarts)',
          'subtitle': 'Foundations in Magical Creatures & Environments',
          'points': [
            'Excel in Care of Magical Creatures, Herbology, and Potions',
            'Learn to identify and understand various creature behaviors',
            'Volunteer at the Forbidden Forest animal rescue or Hagrid\'s hut',
            'Study ancient texts on beasts and their habitats',
            'Develop empathy and observation skills'
          ]
        },
        {
          'year': 'Year 4-5 (Hogwarts)',
          'subtitle': 'Advanced Creature Handling & Research',
          'points': [
            'Specialized study of rare and dangerous creatures',
            'Learn advanced healing spells for injured beasts',
            'Conduct independent research on creature ecosystems (e.g., Nifflers, Bowtruckles)',
            'Participate in creature census and monitoring expeditions',
            'Master non-verbal communication with animals'
          ]
        },
        {
          'year': 'Post-Hogwarts (Ongoing)',
          'subtitle': 'Global Expeditions & Conservation Efforts',
          'points': [
            'Join the Department for the Regulation and Control of Magical Creatures',
            'Travel to remote locations to discover new species',
            'Contribute to magical creature conservation initiatives',
            'Publish findings in "Fantastic Beasts and Where to Find Them" updates',
            'Work with Goblins or House-Elves on creature welfare projects'
          ]
        }
      ]
    },
    {
      'title': 'POTIONS MASTER PATH',
      'color': const Color(0xFF1A472A), // Slytherin Green (Potions)
      'goal': 'Become a master of brewing complex and powerful potions for various magical purposes.',
      'timeline': [
        {
          'year': 'Year 1-3 (Hogwarts)',
          'subtitle': 'Basic Potion Brewing & Ingredient Knowledge',
          'points': [
            'Master fundamental Potions recipes (e.g., Shrinking Solution, Forgetfulness Potion)',
            'Learn to identify and prepare rare magical ingredients',
            'Practice precision and patience in the Potions classroom',
            'Read "Advanced Potion-Making" (even if you just skim)',
            'Develop a keen sense of smell and observation'
          ]
        },
        {
          'year': 'Year 4-5 (Hogwarts)',
          'subtitle': 'Advanced Concoctions & Ingredient Sourcing',
          'points': [
            'Brew complex potions like Polyjuice Potion and Veritaserum',
            'Explore ethical considerations in potion use',
            'Visit apothecaries in Diagon Alley and Knockturn Alley for rare components',
            'Experiment with custom potion formulations',
            'Work safely with volatile ingredients'
          ]
        },
        {
          'year': 'Post-Hogwarts (Apprenticeship)',
          'subtitle': 'Mastery & Innovation in Potioneering',
          'points': [
            'Apprentice under a renowned Potions Master or at St. Mungo\'s',
            'Research new potion properties and applications',
            'Contribute to the development of new healing or defensive concoctions',
            'Become a licensed Potions Brewer for Gringotts or the Ministry',
            'Perfect your own unique potion creations'
          ]
        }
      ]
    }
  ];

  // Useful websites with proper URLs
  final List<Map<String, String>> websites = [
    {'name': 'Notion - Organize Your Studies', 'url': 'https://www.notion.so'},
    {'name': 'Roadmap.sh - Developer Roadmaps', 'url': 'https://roadmap.sh'},
  ];

  // Function to launch URLs
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('Could not launch $url');
      }
    } catch (e) {
      _showErrorDialog('Error launching URL: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _parchmentBackground, // Themed background
      appBar: AppBar(
        title: const Text('Sorting Hat\'s Wisdom'), // Themed title
        backgroundColor: roadmaps[selectedIndex]['color'], // Dynamic color based on selected path
        elevation: 4, // Added elevation
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        titleTextStyle: const TextStyle(
          fontFamily: 'HarryPotterFont', // Apply custom font to AppBar title
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            height: 70, // Slightly taller for better touch target
            decoration: BoxDecoration(
              color: _hogwartsBlue, // Dark blue tab background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Darker shadow
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)), // Rounded bottom
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: roadmaps.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Adjust margins
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Adjust padding
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? roadmaps[index]['color'] // Selected tab color
                          : _goldAccent.withOpacity(0.3), // Gold accent for unselected
                      borderRadius: BorderRadius.circular(25), // More rounded tabs
                      border: Border.all(
                        color: selectedIndex == index ? Colors.white : _goldAccent, // White/Gold border
                        width: selectedIndex == index ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        roadmaps[index]['title'],
                        style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.white
                              : _darkText, // Dark text on unselected tabs
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Slightly larger font
                          fontFamily: 'HarryPotterFont', // Apply custom font
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Roadmap content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20), // More padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Goal Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25), // More padding
                    decoration: BoxDecoration(
                      color: _lightCardBackground, // Parchment-like background
                      borderRadius: BorderRadius.circular(20), // More rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 8,
                          offset: const Offset(0, 5), // Deeper shadow
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          roadmaps[selectedIndex]['title'],
                          style: TextStyle(
                            fontSize: 26, // Larger title
                            fontWeight: FontWeight.bold,
                            color: roadmaps[selectedIndex]['color'], // Themed color
                            fontFamily: 'HarryPotterFont', // Apply custom font
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Your Magical Quest:', // Themed label
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _hogwartsBlue, // Themed color
                            fontFamily: 'HarryPotterFont', // Apply custom font
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          roadmaps[selectedIndex]['goal'],
                          style: TextStyle(
                            fontSize: 15,
                            color: _darkText, // Themed text color
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30), // More spacing

                  // Timeline
                  ...roadmaps[selectedIndex]['timeline'].map<Widget>((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 30), // More spacing
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline indicator
                          Column(
                            children: [
                              Container(
                                width: 25, // Larger indicator
                                height: 25,
                                decoration: BoxDecoration(
                                  color: roadmaps[selectedIndex]['color'], // Themed color
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2), // White border
                                ),
                              ),
                              Container(
                                width: 4, // Thicker line
                                height: 140, // Longer line
                                color: roadmaps[selectedIndex]['color'].withOpacity(0.5), // Themed transparent color
                              ),
                            ],
                          ),

                          const SizedBox(width: 20), // More spacing

                          // Content Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20), // More padding
                              decoration: BoxDecoration(
                                color: _lightCardBackground, // Parchment-like background
                                borderRadius: BorderRadius.circular(15), // More rounded
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['year'],
                                    style: TextStyle(
                                      fontSize: 20, // Larger year
                                      fontWeight: FontWeight.bold,
                                      color: roadmaps[selectedIndex]['color'], // Themed color
                                      fontFamily: 'HarryPotterFont', // Apply custom font
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['subtitle'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _darkText.withOpacity(0.7), // Themed color
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  ...item['points'].map<Widget>((point) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8), // More spacing
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('• ', style: TextStyle(
                                            fontSize: 18, // Larger bullet
                                            color: roadmaps[selectedIndex]['color'], // Themed color
                                            fontWeight: FontWeight.bold,
                                          )),
                                          Expanded(
                                            child: Text(
                                              point,
                                              style: TextStyle(fontSize: 14, color: _darkText), // Themed text
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 30),

                  // Useful Websites section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _lightCardBackground, // Parchment-like background
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enchanted Scrolls & Portals', // Themed title
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _hogwartsBlue, // Themed color
                            fontFamily: 'HarryPotterFont', // Apply custom font
                          ),
                        ),
                        const SizedBox(height: 15),
                        ...websites.map<Widget>((website) {
                          return GestureDetector(
                            onTap: () => _launchURL(website['url']!),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(15), // More padding
                              decoration: BoxDecoration(
                                color: Colors.white, // White background for individual links
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _agedParchment, width: 1), // Aged parchment border
                                boxShadow: [ // Subtle inner shadow
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.webhook, // A more mystical/portal-like icon
                                    color: roadmaps[selectedIndex]['color'], // Themed color
                                    size: 24,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      website['name']!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: _darkText, // Themed text
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: _darkText.withOpacity(0.6), // Themed arrow color
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}